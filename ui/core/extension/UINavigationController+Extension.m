//
//  UINavigationController+AutomaticallyDismissKeyboard.m
//  component
//
//  Created by fallen.ink on 4/7/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "UINavigationController+Extension.h"
#import "UIViewController+Extension.h"

@implementation UINavigationController (AutomaticallyDismissKeyboard)

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

@end

@implementation UINavigationController (Finder)

- (UIViewController *)topmostViewController {
    if (self.presentedViewController) {
        return self.presentedViewController.topmostViewController;
    }
    
    return self.viewControllers.lastObject.topmostViewController ?: self;
}

- (UIViewController *)viewControllerForClass:(Class)class_ {
    for (id vc in self.viewControllers) {
        if ([vc isKindOfClass:class_]) {
            return vc;
        }
    }
    
    return nil;
}

@end
