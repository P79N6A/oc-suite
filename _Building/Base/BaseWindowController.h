//
//  QQingWindowRootViewController.h
//  QQingCommon
//
//  Created by Ben on 15/10/30.
//  Copyright © 2015年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseWindowController : UIViewController

@property (nonatomic, assign) UIStatusBarStyle statusBarStyleToSet;

+ (BaseWindowController *)createWindowControllerWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

@end
