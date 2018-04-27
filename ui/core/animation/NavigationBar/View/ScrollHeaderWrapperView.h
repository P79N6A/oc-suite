//
//  ScrollHeaderWrapperView.h
//  student
//
//  Created by fallen.ink on 07/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//
//  inspire by https://github.com/sunjinshuai/NavigationBar

/**
 *  Usage:
 
 ScrollHeaderWrapperView *view = [ScrollHeaderWrapperView instanceWithFrame:topView.frame contentView:topView stretchView:topView];
 view = topView.frame;
 self.tableView.tableHeaderView = view;
 
 */

#import <UIKit/UIKit.h>

@interface ScrollHeaderWrapperView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *stretchView;

+ (instancetype)instanceWithFrame:(CGRect)frame contentView:(UIView *)contentView stretchView:(UIView *)stretchView;

@end
