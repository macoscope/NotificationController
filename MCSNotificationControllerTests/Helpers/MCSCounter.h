//
//  MCSCounter.h
//  MCSNotificationController
//
//  Created by Arkadiusz Holko on 27/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>


// `MCSCounter` starts listening to this notification after it's created. Every time this notification is send it should increment its `count` property.
extern NSString * const MCSCounterNotificationName;


@interface MCSCounter : NSObject

@property (nonatomic, assign) NSInteger count;

@end
