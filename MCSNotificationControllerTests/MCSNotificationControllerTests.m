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


static NSString * const notificationName =  @"SomeNotification";
static NSString * const differentNotificationName =  @"DifferentNotification";

static void PostNotification( NSString * __nonnull name, id sender)
{
  [[NSNotificationCenter defaultCenter] postNotificationName:name object:sender];
}


@interface MCSNotificationControllerTests : XCTestCase

@end

@implementation MCSNotificationControllerTests

#pragma mark - Base

- (void)testWorksCorrectlyWithNonNilNotificationNameAndSender
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  id sender = [NSObject new];
  [notificationController addObserverForName:notificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {
    count++;
  }];

  PostNotification(notificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(notificationName, [NSObject new]);
  XCTAssertEqual(count, 1);

  PostNotification(differentNotificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(differentNotificationName, nil);
  XCTAssertEqual(count, 1);

  [notificationController removeObserverForName:notificationName sender:sender];

  PostNotification(notificationName, sender);
  XCTAssertEqual(count, 1);
}

- (void)testWorksCorrectlyWithNilSender
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification(notificationName, nil);
  XCTAssertEqual(count, 1);

  PostNotification(notificationName, [NSObject new]);
  XCTAssertEqual(count, 2);

  PostNotification(differentNotificationName, nil);
  XCTAssertEqual(count, 2);

  PostNotification(differentNotificationName, [NSObject new]);
  XCTAssertEqual(count, 2);

  [notificationController removeObserverForName:notificationName sender:nil];

  PostNotification(notificationName, nil);
  XCTAssertEqual(count, 2);
}

- (void)testWorksCorrectlyWithNilNotificationName
{
  __block NSInteger count = 0;
  id sender = [NSObject new];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:nil sender:sender queue:nil usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification(notificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(notificationName, [NSObject new]);
  XCTAssertEqual(count, 1);

  PostNotification(notificationName, nil);
  XCTAssertEqual(count, 1);

  [notificationController removeObserverForName:nil sender:sender];

  PostNotification(notificationName, sender);
  XCTAssertEqual(count, 1);
}

- (void)testWorksCorrectlyWithNilNotificationNameAndNilSender
{
  __block NSInteger count = 0;
  id sender = [NSObject new];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:nil sender:nil queue:nil usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification(notificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(notificationName, [NSObject new]);
  XCTAssertEqual(count, 2);

  PostNotification(notificationName, nil);
  XCTAssertEqual(count, 3);

  [notificationController removeObserverForName:nil sender:nil];

  PostNotification(notificationName, sender);
  XCTAssertEqual(count, 3);
}

- (void)testWorksAfterObjectDeallocation
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification(notificationName, nil);
  XCTAssertEqual(count, 1);

  notificationController = nil;

  PostNotification(notificationName, nil);
  XCTAssertEqual(count, 1);
}

- (void)testWorksWithSelectorBasedObservers
{
  MCSCounter *counter = [MCSCounter new];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:counter];
  [notificationController addObserverForName:notificationName sender:nil selector:@selector(increment)];

  PostNotification(notificationName, nil);
  XCTAssertEqual(counter.count, 1);

  PostNotification(notificationName, nil);
  XCTAssertEqual(counter.count, 2);

  [notificationController removeObserverForName:notificationName sender:nil];

  PostNotification(notificationName, nil);
  XCTAssertEqual(counter.count, 2);
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

  PostNotification(notificationName, nil);

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

  PostNotification(notificationName, nil);

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

      PostNotification(name, nil);
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
