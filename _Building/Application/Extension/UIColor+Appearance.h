
//
//  UIColor+theme.h
// fallen.ink
//
//  Created by 李杰 on 1/22/15.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Appearance)

#pragma mark - 颜色规范
#pragma mark - 基准色

// ===============================================
// 全局用色：灰色系

// Use 000, just because one '0', is too short.
// ===============================================
+ (UIColor *)gray000Color;
+ (UIColor *)gray001Color;
+ (UIColor *)gray002Color;
+ (UIColor *)gray003Color;
+ (UIColor *)gray004Color;
+ (UIColor *)gray005Color;
+ (UIColor *)gray006Color;
+ (UIColor *)gray007Color;

+ (UIColor *)gray008Color;

// ===============================================
// 背景用色
// ===============================================

+ (UIColor *)bgGray000Color;
+ (UIColor *)bgGray001Color;
+ (UIColor *)bgGray002Color;
+ (UIColor *)bgGreenColor;

// ===============================================
// 分割线用色
// ===============================================

+ (UIColor *)lineGray000Color;
+ (UIColor *)lineGray001Color;

// ===============================================
// 文字用色
// 暂时不区分 端
// ===============================================

+ (UIColor *)fontGray001Color; // gray000 white font 1
+ (UIColor *)fontGray002Color; // gray005       font 2
+ (UIColor *)fontGray003Color; // gray006       font 3
+ (UIColor *)fontGray004Color; // gray007       font 4

+ (UIColor *)fontWhiteColor;
+ (UIColor *)fontBlackColor; // title
+ (UIColor *)fontGreenColor;    //              font 5
+ (UIColor *)fontOrangeColor;   //              font 6
+ (UIColor *)fontRedColor;

/**
 *  hair cut
 *
 *  @return UIColor *
 */
+ (UIColor *)fontDeepBlackColor;

// ===============================================
// 按钮特殊用色
// 暂时不区分 端
// ===============================================

+ (UIColor *)buttonRed001Color;

/**
 * 字体灰 1-4 颜色递减
 */
+ (UIColor *)fontGray_one_Color_deprecated; // gray007Color
+ (UIColor *)fontGray_two_Color_deprecated; // gray006
+ (UIColor *)fontGray_three_Color_deprecated; // gray005
+ (UIColor *)fontGray_four_Color_deprecated; // gray004

@end
