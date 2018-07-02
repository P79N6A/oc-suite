//
//  WindowRootViewController.m
//  QQingCommon
//
//  Created by Ben on 15/10/30.
//  Copyright © 2015年 QQingiOSTeam. All rights reserved.
//

#import "WindowRootViewController.h"

@implementation WindowRootViewController

+ (WindowRootViewController *)createRootViewControllerWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    WindowRootViewController *rootVC = [[WindowRootViewController alloc] init];
    rootVC.statusBarStyleToSet = statusBarStyle;
    return rootVC;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyleToSet;
}

@end
