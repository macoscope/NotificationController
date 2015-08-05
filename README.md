# NotificationController

<!--[![Build Status](https://travis-ci.org/macoscope/NotificationController.svg?branch=master)][travis]-->
<!--[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)][carthage]-->

NotificationController provides a better way to use `NSNotificationCenter` on iOS and Mac.

Features:

- compile-time warnings for retain-cycles in the block-based API
- prevention from registration for the same notification more than once
- automatic unregistration from notifications in `-dealloc`

We encourage you to learn about the underlying implementation from the [blog post][].

  [travis]: https://travis-ci.org/macoscope/NotificationController
  [carthage]: https://github.com/Carthage/Carthage
  [blog post]:  http://macoscope.com/blog/improving-notification-center/

## Usage

Fully working example is as simple as:

```obj-c
__weak typeof(self) weakSelf = self;

self.notificationController = [[MCSNotificationController alloc] initWithObserver:self];
[self.notificationController addObserverForName:MCSNotification sender:nil queue:nil usingBlock:^(NSNotification *note) {
    [weakSelf doSomething];
}];
```

or

```swift
self.notificationController = MCSNotificationController(observer: self)
self.notificationController?.addObserverForName(name, sender: nil, queue: nil, usingBlock: {  [weak self] (_) -> Void in
    self.doSomething()
})
```

Above examples assume that there's a strongly held `notificationController` property on that object.
Deregistration happens automatically on the controller's deallocation.

There's also a category on `NSObject` that creates a lazy-loaded `mcs_notificationController` property for you. So, Objective-C example can get even shorter:

```obj-c
__weak typeof(self) weakSelf = self;

[self.mcs_notificationController addObserverForName:MCSNotification sender:nil queue:nil usingBlock:^(NSNotification *note) {
    [weakSelf doSomething];
}];
```

That's all you have to do to safely use notifications with blocks. You should also see an [example app][] and comments in the [header][].

  [example app]: https://github.com/macoscope/NotificationController/tree/master/ExampleApp
  [header]: https://github.com/macoscope/NotificationController/blob/master/MCSNotificationController/MCSNotificationController.h

## Requirements

 * iOS 7 and above
 * OS X 10.9 and above

## Installation

Install with [Carthage]:

    github "macoscope/NotificationController"

or with [CocoaPods]:

    pod "NotificationController"

Then import with: `#import <NotificationController/MCSNotificationController.h>`

  [Carthage]: https://github.com/Carthage/Carthage
  [CocoaPods]: https://cocoapods.org/

## Copyright

Published under the [MIT License](LICENSE).
Copyright (c) 2015 [Macoscope][] sp. z o.o.

  [Macoscope]: http://macoscope.com

