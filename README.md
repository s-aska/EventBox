# EventBox

[![Build Status](https://www.bitrise.io/app/761888ec89ddf48a.svg?token=0bbaMz2vELeV3rreYasSUw&branch=master)](https://www.bitrise.io/app/761888ec89ddf48a)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![](http://img.shields.io/badge/iOS-8.0%2B-brightgreen.svg?style=flat)]()

Provides an interface for use the `addObserverForName` safely and easily.

## Features

- [x] Comprehensive Unit Test Coverage
- [x] Carthage support
- [x] Thread-safe


## Usage

### Minimum

```swift
EventBox.onMainThread(target, name: "reload") { _ in
    // UI
}

EventBox.onBackgroundThread(target, name:"reload") { _ in
    // API Access
}

EventBox.post("reload")

EventBox.off(target) // Remove all the observers of the target

EventBox.off(target, "reload") // Remove observers of the same name of the target
```

### Sender

```swift
EventBox.onMainThread(target, name:"getStatus") { n in
    // API Access
    let status = n.object as TwitterStatus // sender
}

let status = TwitterStatus()
EventBox.post("getStatus", sender: status)
```

### Handling the keyboard notifications

```swift
// MARK: - View Life Cycle

override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    EventBox.onMainThread(self, name: UIKeyboardWillShowNotification, handler: { n in
        self.keyboardWillChangeFrame(n, showsKeyboard: true) })

    EventBox.onMainThread(self, name: UIKeyboardWillHideNotification, handler: { n in
        self.keyboardWillChangeFrame(n, showsKeyboard: false) })
}

override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    EventBox.off(self)
}

// MARK: - Keyboard Event Notifications

func keyboardWillChangeFrame(notification: NSNotification, showsKeyboard: Bool) {
    let userInfo = notification.userInfo!
    let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
    let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()

    if showsKeyboard {
        let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if (orientation.isLandscape) {
            containerViewButtomConstraint.constant = keyboardScreenEndFrame.size.width
        } else {
            containerViewButtomConstraint.constant = keyboardScreenEndFrame.size.height
        }
    } else {
        containerViewButtomConstraint.constant = 0
    }

    self.view.setNeedsUpdateConstraints()

    UIView.animateWithDuration(animationDuration, delay: 0, options: .BeginFromCurrentState, animations: {
        self.containerView.alpha = showsKeyboard ? 1 : 0
        self.view.layoutIfNeeded()
    }, completion: { finished in
        if !showsKeyboard {
            self.view.hidden = true
        }
    })
}
```


## Requirements

- iOS 8.0+
- Xcode 7.0+

## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/carthage/carthage)

```
github "s-aska/EventBox"
```

#### CocoaPods

Add the following line to your [Podfile](https://guides.cocoapods.org/)

```
use_frameworks!
pod 'EventBox'
```


## License

EventBox is released under the MIT license. See LICENSE for details.
