//
//  UIView+Debug.h
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Debug)

/**
 显示指定颜色的外边框
 
 @param color 颜色
 */
- (void)showOutlineWithColor:(UIColor *)color;

/**
 显示随机颜色的外边框
 */
- (void)showRandomColorOutline;

/**
 显示随机颜色的外边框与背景色
 */
- (void)showRandomColorOutlineAndBackgroundColor;

@end
