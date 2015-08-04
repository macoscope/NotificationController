//
//  MCSNotificationControllerAssociatedObjectTests.m
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "MCSCounter.h"
#import "MCSNotificationController.h"
#import "NSObject+MCSNotificationController.h"


@interface MCSNotificationControllerAssociatedObjectTests : XCTestCase

@property (nonatomic, strong) MCSCounter *counter;

@end


@implementation MCSNotificationControllerAssociatedObjectTests

- (void)setUp
{
  [super setUp];
  
  self.counter = [MCSCounter new];
}

- (void)testAssociatedObjectWorksWhenObserverIsDeallocated
{
  __weak MCSCounter *weakCounter = self.counter;

  @autoreleasepool {
    self.counter = nil;
  }

  XCTAssertNil(weakCounter);
  XCTAssertNoThrow([[NSNotificationCenter defaultCenter] postNotificationName:MCSCounterNotificationName object:nil]);
}

@end
