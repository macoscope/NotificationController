//
//  MCSNotificationKey.m
//  MCSNotificationController
//
//  Created by Arkadiusz on 02-08-15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import "MCSNotificationKey.h"


@implementation MCSNotificationKey


#pragma mark - Lifecycle

- (nonnull instancetype)initWithNotificationName:(nullable NSString *)notificationName sender:(nullable id)sender
{
  self = [super init];
  if (self) {
    _notificationName = [notificationName copy];
    _sender = sender;
  }
  
  return self;
}


#pragma mark - Public

- (BOOL)matchedForRemovingByNotificationName:(nullable NSString *)notificationName sender:(nullable id)sender
{
  if (notificationName && ![self.notificationName isEqualToString:notificationName]) {
    return NO;
  }

  if (sender && self.sender != sender) {
    return NO;
  }

  return YES;
}


#pragma mark - <NSObject>

- (NSUInteger)hash
{
  return self.notificationName.hash ^ self.sender.hash;
}

- (BOOL)isEqual:(id)otherObject
{
  if (![otherObject isKindOfClass:[MCSNotificationKey class]]) {
    return NO;
  } else {
    return [self isEqualToKey:(MCSNotificationKey *)otherObject];
  }
}

- (BOOL)isEqualToKey:(MCSNotificationKey *)otherKey
{
  BOOL nameEqual = NO;
  if (self.notificationName && otherKey.notificationName) {
    nameEqual = [self.notificationName isEqualToString:otherKey.notificationName];
  } else {
    nameEqual = self.notificationName == otherKey.notificationName;
  }
  
  BOOL senderEqual = self.sender == otherKey.sender;
  
  return nameEqual && senderEqual;
}


#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

@end
