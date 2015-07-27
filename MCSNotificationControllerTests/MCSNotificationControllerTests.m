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

__attribute__((overloadable)) static void PostNotification(void);
__attribute__((overloadable)) static void PostNotification(id object);

__attribute__((overloadable)) static void PostNotification(void)
{
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

__attribute__((overloadable)) static void PostNotification(id object)
{
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object];
}

@interface MCSNotificationControllerTests : XCTestCase

@end

@implementation MCSNotificationControllerTests

- (void)testWorksCorrectlyInSimplestCase
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification();
  XCTAssertEqual(count, 1);

  [notificationController removeObserverForName:notificationName];
  PostNotification();

  XCTAssertEqual(count, 1);
}

- (void)testWorksCorrectlyWithSenderObject
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  id sender = [NSObject new];
  [notificationController addObserverForName:notificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {
    count++;
  }];

  PostNotification(sender);
  XCTAssertEqual(count, 1);

  [notificationController removeObserverForName:notificationName];
  PostNotification(sender);

  XCTAssertEqual(count, 1);
}

- (void)testIgnoresNotificationsWithADifferentSender
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  id sender = [NSObject new];
  [notificationController addObserverForName:notificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {
    count++;
  }];

  PostNotification(sender);
  XCTAssertEqual(count, 1);

  PostNotification([NSObject new]);
  XCTAssertEqual(count, 1);
}

- (void)testWorksCorrectlyOnMainQueue
{
  __block NSInteger count = 0;
  NSOperationQueue *queue = [NSOperationQueue mainQueue];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Works on main queue"];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:queue usingBlock:^(NSNotification *note) {
    count++;
    [expectation fulfill];
  }];

  PostNotification();

  [self waitForExpectationsWithTimeout:0 handler:^(NSError *error) {
    XCTAssertEqual(count, 1);
    XCTAssertNil(error);
  }];
}

- (void)testWorksCorrectlyOnBackgroundQueue
{
  __block NSInteger count = 0;
  NSOperationQueue *queue = [NSOperationQueue new];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Works on main queue"];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:queue usingBlock:^(NSNotification *note) {
    count++;
    [expectation fulfill];
  }];

  PostNotification();

  [self waitForExpectationsWithTimeout:0 handler:^(NSError *error) {
    XCTAssertEqual(count, 1);
    XCTAssertNil(error);
  }];
}

- (void)testWorksAfterObjectDeallocation
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification();
  XCTAssertEqual(count, 1);

  notificationController = nil;

  PostNotification();
  XCTAssertEqual(count, 1);
}

@end
