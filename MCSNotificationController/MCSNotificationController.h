//
//  MCSNotificationController.h
//  MCSNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import <Foundation/Foundation.h>

#import "NSObject+MCSNotificationController.h"

//! Project version number for MCSNotificationController.
FOUNDATION_EXPORT double MCSNotificationControllerVersionNumber;

//! Project version string for MCSNotificationController.
FOUNDATION_EXPORT const unsigned char MCSNotificationControllerVersionString[];


NS_ASSUME_NONNULL_BEGIN

@interface MCSNotificationController : NSObject

@property (nonatomic, strong, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, weak, readonly) id observer;

- (instancetype)init __attribute__((unavailable("This method is not available. Please use -initWithObserver: instead.")));
+ (instancetype)new __attribute__((unavailable("This method is not available. Please use -initWithObserver: instead.")));

- (instancetype)initWithObserver:(id)observer;
- (instancetype)initWithObserver:(id)observer notificationCenter:(NSNotificationCenter *)notificationCenter NS_DESIGNATED_INITIALIZER;

- (BOOL)addObserverForName:(NSString *)name
                usingBlock:(void (^)(NSNotification *note))block;
- (BOOL)addObserverForName:(NSString *)name
                    sender:(nullable id)sender
                     queue:(nullable NSOperationQueue *)queue
                usingBlock:(void (^)(NSNotification *note))block;

- (BOOL)removeObserverForName:(NSString *)name;
- (BOOL)removeObserverForName:(NSString *)name sender:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END