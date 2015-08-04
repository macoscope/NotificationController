//
//  ViewController.m
//  ExampleApp
//
//  Created by Arkadiusz Holko on 30/07/15.
//  Copyright (c) 2015 Macoscope. All rights reserved.
//

#import "ViewController.h"

#import "MCSNotificationController.h"

static NSString * const kNotificationName = @"kNotificationName";


@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *label;

@end


@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.label.text = [NSString string];

  __weak typeof(self) weakSelf = self;
  [self.mcs_notificationController addObserverForName:kNotificationName sender:nil queue:nil usingBlock:^(NSNotification *notification) {
    [weakSelf updateLabelAfterReceivingNotification];
  }];
}

- (void)updateLabelAfterReceivingNotification
{
  self.label.alpha = 1;
  self.label.text = @"Notification received";
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
      self.label.alpha = 0;
    } completion:nil];
  });
}


#pragma mark - Actions

- (IBAction)postNotificationTapped:(UIButton *)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName object:nil];
}

@end
