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

/**
 *  @abstract MCSNotificationController makes using NSNotificationCenter easier and less error-prone.
 */
@interface MCSNotificationController : NSObject

/// NSNotificationCenter instance used with the controller.
@property (nonatomic, strong, readonly) NSNotificationCenter *notificationCenter;
/// The object notified about new notifications (when used with selectors).
@property (nonatomic, weak, readonly) id observer;

- (instancetype)init __attribute__((unavailable("This method is not available. Please use -initWithObserver: instead.")));
+ (instancetype)new __attribute__((unavailable("This method is not available. Please use -initWithObserver: instead.")));

/**
 *  Instantiates a new MCSNotificationController with an observer. Notifications stop being handled after the observer is deallocated.
 *
 *  @param observer Observer notified about new notifications. MCSNotificationController works until observer is deallocated.
 *
 *  @return New instance of MCSNotificationController.
 */

- (instancetype)initWithObserver:(id)observer;
/**
 *  Instantiates a new MCSNotificationController with an observer and a notification center. Notifications stop being handled after the observer is deallocated.
 *
 *  @param observer Observer notified about new notifications.
 *  @param notificationCenter Notification center instance to be used with the controller.
 *
 *  @return New instance of MCSNotificationController.
 */

- (instancetype)initWithObserver:(id)observer notificationCenter:(NSNotificationCenter *)notificationCenter NS_DESIGNATED_INITIALIZER;

/**
 *  Register the block to be executed when the notification matching the provided parameters is received.
 *
 *  @param name The name of the notification for which to register the observer. If you pass nil, the notification controller accepts a notification with any name.
 *  @param sender The object whose notifications you want to add the block to the operation queue. If you pass nil, the notification controller accepts a notification with any sender.
 *  @param queue The operation queue to which block should be added. If you pass nil, the block is run synchronously on the posting thread.
 *  @param block The block to be executed when the notification is received.
 *
 *  @return YES if adding an observer succeeded. NO can be returned when you're already registered for this pair of notification name and sender.
 */
- (BOOL)addObserverForName:(nullable NSString *)name
                    sender:(nullable id)sender
                     queue:(nullable NSOperationQueue *)queue
                usingBlock:(void (^)(NSNotification *note))block;

/**
 *  Register the selector to be performed when the notification matching the provided parameters is received. The selector is performed on observer object.
 *
 *  @param name The name of the notification for which to register the observer. If you pass nil, the notification controller accepts a notification with any name.
 *  @param sender The object whose notifications the observer wants to receive. If you pass nil, the notification controller accepts a notification with any sender.
 *  @param notificationSelector Selector that specifies the message the receiver sends observer to notify it of the notification posting. The method specified by notificationSelector must have one and only one argument (an instance of NSNotification).
 *
 *  @return YES if adding an observer succeeded. NO can be returned when you're already registered for this pair of notification name and sender.
 */
- (BOOL)addObserverForName:(nullable NSString *)name
                    sender:(nullable id)sender
                  selector:(SEL)notificationSelector;

/**
 *  Removes the observer for the specified name and sender.
 *
 *  @param name The name of the notification from which to unregister the observer.
 *  @param sender The name of the object from which to unregister the observer.
 *
 *  @return YES if removing the observer succeeded. NO can be returned when you aren't registered for this pair of notification name and sender.
 */
- (BOOL)removeObserverForName:(nullable NSString *)name sender:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
