//
//  NSObject+MCNotificationController.m
//  MCNotificationController
//
//  Created by Arkadiusz on 03-06-15.
//
//

#import "NSObject+MCNotificationController.h"

#import <objc/runtime.h>


static void *NSObjectNotificationControllerKey = &NSObjectNotificationControllerKey;


@implementation NSObject (MCNotificationController)
@dynamic mc_notificationController;

- (MCNotificationController *)mc_notificationController
{
  MCNotificationController *controller = objc_getAssociatedObject(self, NSObjectNotificationControllerKey);

  if (!controller) {
    controller = [[MCNotificationController alloc] initWithObserver:self];
    self.mc_notificationController = controller;
  }

  return controller;
}

- (void)setMc_notificationController:(MCNotificationController *)mc_notificationController
{
  objc_setAssociatedObject(self, NSObjectNotificationControllerKey, mc_notificationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
