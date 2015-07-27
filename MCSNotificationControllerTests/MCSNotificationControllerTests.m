//
//  MCSNotificationControllerTests.m
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <libkern/OSAtomic.h>

#import "MCSNotificationController.h"
#import "MCSCounter.h"


static NSString * const notificationName =  @"ArbitraryNotification";

__attribute__((overloadable)) static void PostNotification(void);
__attribute__((overloadable)) static void PostNotification(id object);
__attribute__((overloadable)) static void PostNotification(id object, NSString *__nonnull name);

__attribute__((overloadable)) static void PostNotification(void)
{
  PostNotification(nil);
}

__attribute__((overloadable)) static void PostNotification(id object)
{
  PostNotification(object, notificationName);
}

__attribute__((overloadable)) static void PostNotification(id object, NSString *name)
{
  [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
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
  XCTestExpectation *expectation = [self expectationWithDescription:@"Works on queue"];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:queue usingBlock:^(NSNotification *note) {
    count++;
    [expectation fulfill];
  }];

  PostNotification();

  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *error) {
    XCTAssertEqual(count, 1);
    XCTAssertNil(error);
  }];
}

- (void)testWorksCorrectlyOnBackgroundQueue
{
  __block NSInteger count = 0;
  NSOperationQueue *queue = [NSOperationQueue new];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Works on queue"];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:queue usingBlock:^(NSNotification *note) {
    count++;
    [expectation fulfill];
  }];

  PostNotification();

  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *error) {
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

- (void)testIsThreadSafe
{
  __block int32_t count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Thread-safe"];

  __block NSInteger ranQueueCount = 0;
  const NSInteger accessCount = 500;

  for (NSInteger i = 0; i < accessCount; i++) {
    dispatch_queue_t queue = i % 2 == 0 ? dispatch_get_main_queue() : dispatch_get_global_queue(0, 0);

    dispatch_async(queue, ^{
      NSString *name = [@(i) stringValue];

      [notificationController addObserverForName:name usingBlock:^(NSNotification *notification) {
        OSAtomicIncrement32(&count);
      }];

      PostNotification(nil, name);
      [notificationController removeObserverForName:name];

      if (++ranQueueCount == accessCount) {
        [expectation fulfill];
      }
    });
  }

  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *error) {
    XCTAssertEqual(count, accessCount);
    XCTAssertNil(error);
  }];
}

@end
