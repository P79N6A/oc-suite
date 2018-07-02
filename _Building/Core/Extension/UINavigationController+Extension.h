//
//  UINavigationController+AutomaticallyDismissKeyboard.h
//  component
//
//  Created by fallen.ink on 4/7/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (AutomaticallyDismissKeyboard)

@end

@interface UINavigationController (Finder)

@property (nonatomic, readonly) UIViewController *topmostViewController;

- (UIViewController *)viewControllerForClass:(Class)class_;

@end