//
//  NSObject+MCSNotificationController.h
//  MCSNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import <Foundation/Foundation.h>

@class MCSNotificationController;

NS_ASSUME_NONNULL_BEGIN


@interface NSObject (MCSNotificationController)

/// Lazy-loaded MCSNotificationController for use with any NSObject subclass.
@property (nonatomic, strong) MCSNotificationController *mcs_notificationController;

@end


NS_ASSUME_NONNULL_END