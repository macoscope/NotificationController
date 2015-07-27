//
//  MCSNotificationListener.m
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import "MCSNotificationListener.h"


id<NSCopying> MCSNotificationKey(NSString *notificationName, __nullable id sender)
{
  NSCParameterAssert(notificationName);
  return [NSString stringWithFormat:@"%@-%p", notificationName, sender];
}


@implementation MCSNotificationListener

- (instancetype)initWithQueue:(nullable NSOperationQueue *)queue block:(void (^)(NSNotification *note))block
{
  NSParameterAssert(block);
  self = [super init];
  if (self) {
    _queue = queue;
    _block = block;
  }

  return self;
}

- (void)executeWithNotification:(NSNotification *)note
{
  if (self.queue) {
    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
      weakSelf.block(note);
    }];

  } else {
    self.block(note);
  }
}

@end
