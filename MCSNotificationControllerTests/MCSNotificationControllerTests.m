//
//  MCSNotificationControllerTests.m
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>
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

#pragma mark - Base

- (void)testWorksCorrectlyInSimplestCase
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification();
  XCTAssertEqual(count, 1);

  [notificationController removeObserverForName:notificationName sender:nil];
  PostNotification();

  XCTAssertEqual(count, 1);
}

- (void)testWorksAfterObjectDeallocation
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification();
  XCTAssertEqual(count, 1);

  notificationController = nil;

  PostNotification();
  XCTAssertEqual(count, 1);
}

- (void)testWorksWithSelectorBasedObservers
{
  MCSCounter *counter = [MCSCounter new];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:counter];
  [notificationController addObserverForName:notificationName sender:nil selector:@selector(increment)];

  PostNotification(nil, notificationName);
  XCTAssertEqual(counter.count, 1);

  PostNotification(nil, notificationName);
  XCTAssertEqual(counter.count, 2);

  [notificationController removeObserverForName:notificationName sender:nil];

  PostNotification(nil, notificationName);
  XCTAssertEqual(counter.count, 2);
}


#pragma mark - Senders

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

  [notificationController removeObserverForName:notificationName sender:sender];
  PostNotification(sender);

  XCTAssertEqual(count, 1);
}

- (void)testIgnoresNotificationsWithTwoDifferentSenders
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


#pragma mark - Queues

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


#pragma mark - Thread safety

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

      [notificationController addObserverForName:name sender:nil queue:nil usingBlock:^(NSNotification *notification) {
        OSAtomicIncrement32(&count);
      }];

      PostNotification(nil, name);
      [notificationController removeObserverForName:name sender:nil];

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


#pragma mark - Adding observers

- (void)testInformsAboutSuccessOfAddingObserverWithoutSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];

  BOOL result1 = [notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertFalse(result2);
}

- (void)testInformsAboutSuccessOfAddingObserverWithSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  id sender = [NSObject new];

  BOOL result1 = [notificationController addObserverForName:notificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController addObserverForName:notificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertFalse(result2);
}


#pragma mark - Removing observers

- (void)testInformsAboutSuccessOfRemovingObserverWithoutSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {}];

  BOOL result1 = [notificationController removeObserverForName:notificationName sender:nil];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController removeObserverForName:notificationName sender:nil];
  XCTAssertFalse(result2);
}

- (void)testInformsAboutSuccessOfRemovingObserverWithSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  id sender = [NSObject new];
  [notificationController addObserverForName:notificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {}];

  BOOL result1 = [notificationController removeObserverForName:notificationName sender:sender];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController removeObserverForName:notificationName sender:sender];
  XCTAssertFalse(result2);
}

@end
