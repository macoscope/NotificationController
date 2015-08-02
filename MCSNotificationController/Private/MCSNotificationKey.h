//
//  MCSNotificationKey.h
//  MCSNotificationController
//
//  Created by Arkadiusz on 02-08-15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface MCSNotificationKey : NSObject <NSCopying>

@property (nonatomic, copy, readonly, nullable) NSString *notificationName;
@property (nonatomic, weak, readonly, nullable) id<NSObject> sender;

- (nonnull instancetype)initWithNotificationName:(nullable NSString *)notificationName sender:(nullable id)sender;

- (BOOL)matchedForSendingByNotificationName:(NSString *)notificationName sender:(nullable id)sender;
- (BOOL)matchedForRemovingByNotificationName:(nullable NSString *)notificationName sender:(nullable id)sender;

@end


NS_ASSUME_NONNULL_END