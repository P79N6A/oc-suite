//
//  ALSViewController.h
//  wesg
//
//  Created by 7 on 28/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Template

@interface UIViewController ( Template )

- (void)initViews; // 初始化视图

- (void)afterViews; // 初始化视图后，做其他初始配置

- (void)updateViews; // 网络回调后 更新视图

- (void)constraintViews; // 给视图加约束

@end

#pragma mark -

@interface ALSViewController : UIViewController

@end
