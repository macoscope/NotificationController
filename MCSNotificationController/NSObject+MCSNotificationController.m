//
//  NSObject+MCSNotificationController.m
//  MCSNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import "NSObject+MCSNotificationController.h"

#import "MCSNotificationController.h"
#import <objc/runtime.h>


static void * NSObjectNotificationControllerKey = &NSObjectNotificationControllerKey;


@implementation NSObject (MCSNotificationController)

@dynamic mcs_notificationController;

- (MCSNotificationController *)mcs_notificationController
{
  MCSNotificationController *controller = objc_getAssociatedObject(self, NSObjectNotificationControllerKey);

  if (!controller) {
    controller = [[MCSNotificationController alloc] initWithObserver:self];
    self.mcs_notificationController = controller;
  }

  return controller;
}

- (void)setMcs_notificationController:(MCSNotificationController *)mcs_notificationController
{
  objc_setAssociatedObject(self, NSObjectNotificationControllerKey, mcs_notificationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
