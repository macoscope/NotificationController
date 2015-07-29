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


static NSString * const kNotificationName =  @"SomeNotification";
static NSString * const kDifferentNotificationName =  @"DifferentNotification";

static void PostNotification(NSString *__nonnull name, id sender)
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
  [notificationController addObserverForName:kNotificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {
    count++;
  }];

  PostNotification(kNotificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(kNotificationName, [NSObject new]);
  XCTAssertEqual(count, 1);

  PostNotification(kDifferentNotificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(kDifferentNotificationName, nil);
  XCTAssertEqual(count, 1);

  [notificationController removeObserverForName:kNotificationName sender:sender];

  PostNotification(kNotificationName, sender);
  XCTAssertEqual(count, 1);
}

- (void)testWorksCorrectlyWithNilSender
{
  __block NSInteger count = 0;
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:kNotificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {
    count++;
  }];

  PostNotification(kNotificationName, nil);
  XCTAssertEqual(count, 1);

  PostNotification(kNotificationName, [NSObject new]);
  XCTAssertEqual(count, 2);

  PostNotification(kDifferentNotificationName, nil);
  XCTAssertEqual(count, 2);

  PostNotification(kDifferentNotificationName, [NSObject new]);
  XCTAssertEqual(count, 2);

  [notificationController removeObserverForName:kNotificationName sender:nil];

  PostNotification(kNotificationName, nil);
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

  PostNotification(kNotificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(kNotificationName, [NSObject new]);
  XCTAssertEqual(count, 1);

  PostNotification(kNotificationName, nil);
  XCTAssertEqual(count, 1);

  [notificationController removeObserverForName:nil sender:sender];

  PostNotification(kNotificationName, sender);
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

  PostNotification(kNotificationName, sender);
  XCTAssertEqual(count, 1);

  PostNotification(kNotificationName, [NSObject new]);
  XCTAssertEqual(count, 2);

  PostNotification(kNotificationName, nil);
  XCTAssertEqual(count, 3);

  [notificationController removeObserverForName:nil sender:nil];

  PostNotification(kNotificationName, sender);
  XCTAssertEqual(count, 3);
}

- (void)testWorksAfterObjectDeallocation
{
  __block NSInteger count = 0;

  // we want to force notificationController to get deallocated; autoreleasepool is used because there're some differences between iOS 8 and 9
  @autoreleasepool {
    MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
    [notificationController addObserverForName:kNotificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {
      count++;
    }];
    
    PostNotification(kNotificationName, nil);
    XCTAssertEqual(count, 1);

    notificationController = nil;
  }

  PostNotification(kNotificationName, nil);
  XCTAssertEqual(count, 1);
}

- (void)testWorksWithSelectorBasedObservers
{
  MCSCounter *counter = [MCSCounter new];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:counter];
  [notificationController addObserverForName:kNotificationName sender:nil selector:@selector(increment)];

  PostNotification(kNotificationName, nil);
  XCTAssertEqual(counter.count, 1);

  PostNotification(kNotificationName, nil);
  XCTAssertEqual(counter.count, 2);

  [notificationController removeObserverForName:kNotificationName sender:nil];

  PostNotification(kNotificationName, nil);
  XCTAssertEqual(counter.count, 2);
}


#pragma mark - Queues

- (void)testWorksCorrectlyOnMainQueue
{
  __block NSInteger count = 0;
  NSOperationQueue *queue = [NSOperationQueue mainQueue];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Works on queue"];

  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:kNotificationName sender:nil queue:queue usingBlock:^(NSNotification *note) {
    count++;
    [expectation fulfill];
  }];

  PostNotification(kNotificationName, nil);

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
  [notificationController addObserverForName:kNotificationName sender:nil queue:queue usingBlock:^(NSNotification *note) {
    count++;
    [expectation fulfill];
  }];

  PostNotification(kNotificationName, nil);

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

- (void)testIsThreadSafe2
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:kNotificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {}];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [notificationController removeObserverForName:kNotificationName sender:nil];
  });

  PostNotification(kNotificationName, nil);
}


#pragma mark - Adding observers

- (void)testInformsAboutSuccessOfAddingObserverWithoutSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];

  BOOL result1 = [notificationController addObserverForName:kNotificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController addObserverForName:kNotificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertFalse(result2);
}

- (void)testInformsAboutSuccessOfAddingObserverWithSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  id sender = [NSObject new];

  BOOL result1 = [notificationController addObserverForName:kNotificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController addObserverForName:kNotificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {}];
  XCTAssertFalse(result2);
}


#pragma mark - Removing observers

- (void)testInformsAboutSuccessOfRemovingObserverWithoutSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  [notificationController addObserverForName:kNotificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {}];

  BOOL result1 = [notificationController removeObserverForName:kNotificationName sender:nil];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController removeObserverForName:kNotificationName sender:nil];
  XCTAssertFalse(result2);
}

- (void)testInformsAboutSuccessOfRemovingObserverWithSender
{
  MCSNotificationController *notificationController = [[MCSNotificationController alloc] initWithObserver:self];
  id sender = [NSObject new];
  [notificationController addObserverForName:kNotificationName sender:sender queue:nil usingBlock:^(NSNotification *note) {}];

  BOOL result1 = [notificationController removeObserverForName:kNotificationName sender:sender];
  XCTAssertTrue(result1);
  BOOL result2 = [notificationController removeObserverForName:kNotificationName sender:sender];
  XCTAssertFalse(result2);
}

@end
