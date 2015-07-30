//
//  NotificationControllerDrewTests.m
//  MCSNotificationControllerTests
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "MCSNotificationController.h"
#import "NSObject+MCSNotificationController.h"


static NSInteger globalCounter = 0;
static NSString * const notificationName =  @"ArbitraryNotification";


@interface YourAttempt : NSObject

@property (nonatomic, assign) NSInteger localCounter;

@end


@implementation YourAttempt

- (instancetype)init
{
  if (self = [super init]) {
    __weak typeof(self) weakSelf = self;

    // This test is based on Drew Crawford's article: http://sealedabstract.com/code/nsnotificationcenter-with-blocks-considered-harmful/

    [self.mcs_notificationController addObserverForName:notificationName sender:nil queue:nil usingBlock:^(NSNotification *note) {
      NSInteger oldCounterValue = globalCounter;
      globalCounter++;
      // changing "weakSelf" to "self" or "NSCAssert" to "NSAssert" will lead to a compiler warning: Capturing 'self' strongly in this block is likely to lead to a retain cycle
      weakSelf.localCounter++;
      NSCAssert(globalCounter == oldCounterValue+1, @"Atomicity guarantee violated.");
    }];
  }

  return self;
}

@end


@interface MCSNotificationControllerDrewTests : XCTestCase

@end


@implementation MCSNotificationControllerDrewTests

- (void)testExample
{
  for (NSInteger i = 0; i < 5; i++) {
    // autoreleasepool is used to force attempt1 deallocation exactly at the end of each iteration
    @autoreleasepool {
      YourAttempt *attempt1 = [[YourAttempt alloc] init];
      [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
      XCTAssertEqual(globalCounter, i + 1, @"Unexpected value for counter.");
      XCTAssertEqual(1, attempt1.localCounter, @"Unexpected value for localCounter.");
    }
  }
}

@end
