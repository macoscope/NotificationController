//
//  NotificationControllerDrewTests.m
//  MCNotificationControllerTests
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "MCNotificationController.h"
#import "NSObject+MCNotificationController.h"


static int globalCounter = 0;
static NSString * const notificationName =  @"ArbitraryNotification";


@interface YourAttempt : NSObject

@property int localCounter;
@property (nonatomic, strong) MCNotificationController *notificationController;

@end


@implementation YourAttempt

- (instancetype)init
{
  if (self = [super init]) {
    __weak typeof(self) weakSelf = self;

    [self.mc_notificationController addObserverForName:notificationName object:nil queue:nil usingBlock:^(NSNotification *note) {
      int oldCounterValue = globalCounter;
      globalCounter++;
      weakSelf.localCounter++;
      NSCAssert(globalCounter == oldCounterValue+1, @"Atomicity guarantee violated.");
    }];
  }

  return self;
}

@end



@interface MCNotificationControllerTests : XCTestCase
@end

@implementation MCNotificationControllerTests

- (void)testExample
{
  for(int i =0; i < 5; i++) {
    YourAttempt *attempt1 = [[YourAttempt alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    XCTAssertEqual(globalCounter, i+1, @"Unexpected value for counter.");
    XCTAssertEqual(1, attempt1.localCounter, @"Unexpected value for localCounter.");
  }
}

@end
