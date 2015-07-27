//
//  MCSNotificationControllerTests.m
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MCSNotificationController.h"
#import "MCSCounter.h"


static NSString * const notificationName =  @"ArbitraryNotification";


@interface MCSNotificationControllerTests : XCTestCase

@property (nonatomic, strong) MCSCounter *counter;

@end

@implementation MCSNotificationControllerTests

- (void)setUp
{
  [super setUp];
  
  self.counter = [MCSCounter new];
}

- (void)testWorksAfterObjectDeallocation
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName usingBlock:^(NSNotification *notification) {
    count++;
  }];

  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
  XCTAssertEqual(count, 1);

  notificationController = nil;

  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
  XCTAssertEqual(count, 1);
}

@end
