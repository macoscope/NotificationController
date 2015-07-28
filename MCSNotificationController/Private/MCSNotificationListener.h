//
//  MCSNotificationListener.h
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

id<NSCopying> MCSNotificationKey( NSString * __nullable notificationName, __nullable id sender);


@interface MCSNotificationListener : NSObject

@property (nonatomic, strong, readonly, nullable) NSOperationQueue *queue;
@property (nonatomic, copy, readonly) void (^block)(NSNotification *note);

- (instancetype)initWithQueue:(nullable NSOperationQueue *)queue block:(void (^)(NSNotification *note))block;
- (void)executeWithNotification:(NSNotification *)note;

@end

NS_ASSUME_NONNULL_END