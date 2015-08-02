//
//  MCSNotificationController.m
//  MCSNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import "MCSNotificationController.h"
#import "MCSNotificationKey.h"


@interface MCSNotificationController ()

@property (nonatomic, strong) NSMutableDictionary *mapNotificationKeyToToken;
@property (nonatomic, strong) dispatch_queue_t mapAccessQueue;

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
    _mapNotificationKeyToToken = [NSMutableDictionary new];
    _mapAccessQueue = dispatch_queue_create("com.macoscope.notification-controller.map-queue", NULL);
  }

  return self;
}

- (void)dealloc
{
  for (MCSNotificationKey *key in _mapNotificationKeyToToken) {
    id<NSObject> token = _mapNotificationKeyToToken[key];
    [self.notificationCenter removeObserver:token];
  }
}


#pragma mark - Public

- (BOOL)addObserverForName:(nullable NSString *)name
                    sender:(nullable id)sender
                     queue:(nullable NSOperationQueue *)queue
                usingBlock:(void (^)(NSNotification *note))block;
{
  NSParameterAssert(block);

  __block BOOL observerAdded = NO;

  dispatch_sync(self.mapAccessQueue, ^{
    id<NSCopying> key = [[MCSNotificationKey alloc] initWithNotificationName:name sender:sender];

    if (!self.mapNotificationKeyToToken[key]) {
      __weak typeof(self) weakSelf = self;
      
      id<NSObject> token = [self.notificationCenter addObserverForName:name object:sender queue:queue usingBlock:^(NSNotification *note) {
        if (weakSelf.observer) {
          block(note);
        }
      }];
      
      self.mapNotificationKeyToToken[key] = token;
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

  dispatch_sync(self.mapAccessQueue, ^{
    for (MCSNotificationKey *key in self.mapNotificationKeyToToken.allKeys) {

      if ([key matchedForRemovingByNotificationName:name sender:sender]) {
        id<NSObject> token = self.mapNotificationKeyToToken[key];

        [self.notificationCenter removeObserver:token];
        [self.mapNotificationKeyToToken removeObjectForKey:key];

        observerRemoved = YES;
      }
    }
  });

  return observerRemoved;
}

@end
