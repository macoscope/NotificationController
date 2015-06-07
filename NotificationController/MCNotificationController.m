//
//  MCNotificationController.m
//  MCNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import "MCNotificationController.h"


@interface MCNotificationController ()

@property (nonatomic, strong) NSMutableDictionary *mapNotificationNameToBlock;

@end


@implementation MCNotificationController

#pragma mark - Lifecycle

- (instancetype)init
{
  self = [self initWithObserver:nil notificationCenter:nil];
  return self;
}

- (instancetype)initWithObserver:(id)observer
{
  self = [self initWithObserver:observer notificationCenter:[NSNotificationCenter defaultCenter]];
  return self;
}

- (instancetype)initWithObserver:(id)observer notificationCenter:(NSNotificationCenter *)notificationCenter
{
  NSParameterAssert(observer);
  NSParameterAssert(notificationCenter);

  self = [super init];
  if (self) {
    _observer = observer;
    _notificationCenter = notificationCenter;
    _mapNotificationNameToBlock = [NSMutableDictionary new];
  }

  return self;
}

- (void)dealloc
{
  [self.notificationCenter removeObserver:self];
  NSLog(@"notification controller dealloc: %p", self);
}

- (void)addObserverForName:(NSString *)name
                    object:(id)obj
                     queue:(NSOperationQueue *)queue
                usingBlock:(void (^)(NSNotification *note))block
{
  [self.notificationCenter addObserver:self selector:@selector(action:) name:name object:obj];
  NSAssert(!self.mapNotificationNameToBlock[name], nil);

  // TODO: don't ignore `object` and `queue`

  self.mapNotificationNameToBlock[name] = block;
}

- (void)action:(NSNotification *)notification
{
  __strong id observer = self.observer;
  // observer can be nil, because deallocation of an associated object happens after `dealloc` on the source object is called
  if (observer) {
    void (^block)(NSNotification *note) = self.mapNotificationNameToBlock[notification.name];
    NSAssert(block, nil);
    
    block(notification);
  }
}

@end