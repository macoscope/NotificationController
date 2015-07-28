//
//  MCSCounter.m
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import "MCSCounter.h"

#import "MCSNotificationController.h"


NSString * const MCSCounterNotificationName = @"MCSCounterNotificationName";


@implementation MCSCounter

- (instancetype)init
{
  self = [super init];
  if (self) {
    __weak typeof(self) weakSelf = self;
    [self.mcs_notificationController addObserverForName:MCSCounterNotificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {
      weakSelf.count++;
    }];
  }

  return self;
}

@end
