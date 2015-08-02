//
//  MCSNotificationController.m
//  MCSNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import "MCSNotificationController.h"
#import "MCSNotificationListener.h"
#import "MCSNotificationKey.h"


@interface MCSNotificationController ()

@property (nonatomic, strong) NSMutableDictionary *mapNotificationKeyToListener;
@property (nonatomic, strong) dispatch_queue_t mapQueue;

@end


@implementation MCSNotificationController


#pragma mark - Lifecycle

- (instancetype)init
{
  NSAssert2(NO, @"%@ is not a correct initializer for instances of %@.", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
  return nil;
}

- (instancetype)initWithObserver:(id)observer
{
  return [self initWithObserver:observer notificationCenter:[NSNotificationCenter defaultCenter]];
}

- (instancetype)initWithObserver:(id)observer notificationCenter:(NSNotificationCenter *)notificationCenter
{
  NSParameterAssert(observer);
  NSParameterAssert(notificationCenter);

  self = [super init];
  if (self) {
    _observer = observer;
    _notificationCenter = notificationCenter;
    _mapNotificationKeyToListener = [NSMutableDictionary new];
    _mapQueue = dispatch_queue_create("com.macoscope.notification-controller.map-queue", NULL);
    // I don't like this but it leads to the safest implementation. Should probably be improved in the future if there're any issues with the performance.
    [_notificationCenter addObserver:self selector:@selector(action:) name:nil object:nil];
  }

  return self;
}

- (void)dealloc
{
  [self.notificationCenter removeObserver:self];
}


#pragma mark - Public

- (BOOL)addObserverForName:(nullable NSString *)name
                    sender:(nullable id)sender
                     queue:(nullable NSOperationQueue *)queue
                usingBlock:(void (^)(NSNotification *note))block;
{
  NSParameterAssert(block);

  __block BOOL observerAdded = NO;
  
  dispatch_sync(self.mapQueue, ^{
    id<NSCopying> key = [[MCSNotificationKey alloc] initWithNotificationName:name sender:sender];
    
    if (!self.mapNotificationKeyToListener[key]) {
      self.mapNotificationKeyToListener[key] = [[MCSNotificationListener alloc] initWithQueue:queue block:block];
      observerAdded = YES;
    }
  });

  return observerAdded;
}

- (BOOL)addObserverForName:(nullable NSString *)name
                    sender:(nullable id)sender
                  selector:(SEL)notificationSelector
{
  NSParameterAssert(notificationSelector);
  NSAssert([self.observer respondsToSelector:notificationSelector], @"%@ does not recognize %@ selector", self.observer, NSStringFromSelector(notificationSelector));

  __weak id observer = self.observer;
  return [self addObserverForName:name sender:sender queue:nil usingBlock:^(NSNotification *note) {
    // safe because no value is returned and retained
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([NSStringFromSelector(notificationSelector) rangeOfString:@":"].location == NSNotFound) {
      [observer performSelector:notificationSelector];
    } else {
      [observer performSelector:notificationSelector withObject:note];
    }
#pragma clang diagnostic pop
  }];
}

- (BOOL)removeObserver
{
  return [self removeObserverForName:nil sender:nil];
}

- (BOOL)removeObserverForName:(NSString *)name sender:(nullable id)sender
{
  __block BOOL observerRemoved = NO;

  dispatch_sync(self.mapQueue, ^{
    for (MCSNotificationKey *key in self.mapNotificationKeyToListener.allKeys) {
      if ([key matchedForRemovingByNotificationName:name sender:sender]) {
        [self.mapNotificationKeyToListener removeObjectForKey:key];
        observerRemoved = YES;
      }
    }
  });

  return observerRemoved;
}


#pragma mark - Private

- (void)action:(NSNotification *)notification
{
  id observer = self.observer;

  // observer can be nil, because deallocation of an associated object happens after `dealloc` on the source object is called
  if (observer) {
    __block NSArray *listeners = nil;

    dispatch_sync(self.mapQueue, ^{
      NSMutableArray *mutableListeners = [NSMutableArray new];
      for (MCSNotificationKey *key in self.mapNotificationKeyToListener.allKeys) {
        if ([key matchedForSendingByNotificationName:notification.name sender:notification.object]) {
          [mutableListeners addObject:self.mapNotificationKeyToListener[key]];
        }
      }

      listeners = [mutableListeners copy];
    });

    for (MCSNotificationListener *listener in listeners) {
      [listener executeWithNotification:notification];
    }
  }
}

@end
