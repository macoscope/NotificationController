//
//  MCSNotificationController.m
//  MCSNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import "MCSNotificationController.h"
#import "MCSNotificationListener.h"


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
  }

  return self;
}

- (void)dealloc
{
  [self.notificationCenter removeObserver:self];
}


#pragma mark - Public

- (void)addObserverForName:(NSString *)name
                usingBlock:(void (^)(NSNotification *note))block
{
  [self addObserverForName:name
                    sender:nil
                     queue:nil
                usingBlock:block];
}

- (void)addObserverForName:(NSString *)name
                    sender:(nullable id)sender
                     queue:(nullable NSOperationQueue *)queue
                usingBlock:(void (^)(NSNotification *note))block;
{
  NSParameterAssert(name);
  NSParameterAssert(block);

  dispatch_sync(self.mapQueue, ^{
    id<NSCopying> key = MCSNotificationKey(name, sender);
    NSAssert2(!self.mapNotificationKeyToListener[key], @"You shouldn't add observer for notification name: %@ with the same sender: %@ twice!", name, sender);
    
    self.mapNotificationKeyToListener[key] = [[MCSNotificationListener alloc] initWithQueue:queue block:block];
    [self.notificationCenter addObserver:self selector:@selector(action:) name:name object:sender];
  });
}

- (void)removeObserverForName:(NSString *)name
{
  [self removeObserverForName:name sender:nil];
}

- (void)removeObserverForName:(NSString *)name sender:(nullable id)sender
{
  dispatch_sync(self.mapQueue, ^{
    id<NSCopying> key = MCSNotificationKey(name, sender);
    
    [self.mapNotificationKeyToListener removeObjectForKey:key];
    [self.notificationCenter removeObserver:self name:name object:sender];
  });
}


#pragma mark - Private

- (void)action:(NSNotification *)notification
{
  id observer = self.observer;

  // observer can be nil, because deallocation of an associated object happens after `dealloc` on the source object is called
  if (observer) {
    __block MCSNotificationListener *listener = nil;

    dispatch_sync(self.mapQueue, ^{
      id<NSCopying> key = MCSNotificationKey(notification.name, notification.object);
      listener = self.mapNotificationKeyToListener[key];
    });
    NSAssert2(listener, @"Listener for notification name: %@ with sender: %@ doesn't exist!", notification.name, notification.object);

    [listener executeWithNotification:notification];
  }
}

@end
