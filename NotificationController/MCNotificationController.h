//
//  MCNotificationController.h
//  MCNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import <UIKit/UIKit.h>

//! Project version number for MCNotificationController.
FOUNDATION_EXPORT double MCNotificationControllerVersionNumber;

//! Project version string for MCNotificationController.
FOUNDATION_EXPORT const unsigned char MCNotificationControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MCNotificationController/PublicHeader.h>


@interface MCNotificationController : NSObject

@property (nonatomic, strong, readonly) NSNotificationCenter *notificationCenter;
@property (atomic, weak, readonly) id observer;

- (instancetype)initWithObserver:(id)observer;
- (instancetype)initWithObserver:(id)observer notificationCenter:(NSNotificationCenter *)notificationCenter NS_DESIGNATED_INITIALIZER;

- (void)addObserverForName:(NSString *)name
                    object:(id)obj
                     queue:(NSOperationQueue *)queue
                usingBlock:(void (^)(NSNotification *note))block;

@end