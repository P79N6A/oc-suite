//
//  UIColor+theme.m
// fallen.ink
//
//  Created by 李杰 on 1/22/15.
//
//

#import "_foundation.h"
#import "UIColor+Appearance.h"
#import "UIColor+Extension.h"

@implementation UIColor (Appearance)

#pragma mark - 颜色规范
#pragma mark - 基准色

// ===============================================
// 全局用色：灰色系

// Use 000, just because one '0', is too short.
// ===============================================

+ (UIColor *)gray000Color {
    return [UIColor colorWithRGBHex:0xffffff];
}

+ (UIColor *)gray001Color {
    return [UIColor colorWithRGBHex:0xf7f7f7];
}

+ (UIColor *)gray002Color {
    return [UIColor colorWithRGBHex:0xf0f0f0];
}

+ (UIColor *)gray003Color {
    return [UIColor colorWithRGBHex:0xebebeb];
}

+ (UIColor *)gray004Color {
    return [UIColor colorWithRGBHex:0xcccccc];
}

+ (UIColor *)gray005Color {
    return [UIColor colorWithRGBHex:0x999999];
}

+ (UIColor *)gray006Color {
    return [UIColor colorWithRGBHex:0x666666];
}

+ (UIColor *)gray007Color {
    return [UIColor colorWithRGBHex:0x333333];
}

+ (UIColor *)gray008Color {
    return [UIColor colorWithHexString:@"979797"];
}

// ===============================================
// 全局用色：主题色、辅助色

// mfs：发型师
// gk：消费者
// ===============================================

+ (UIColor *)mfsYellowColor {
    return [UIColor colorWithRGBHex:0xcda367];
}

+ (UIColor *)dsRedColor {
    return [UIColor colorWithRGBHex:0xf5414a];
}

+ (UIColor *)gkRedColor {
    return [UIColor colorWithRGBHex:0xb30022];
}

+ (UIColor *)gkGreenColor {
    return [UIColor colorWithRGBHex:0x17AF9F];
}

// ===============================================
// 背景用色
// ===============================================

+ (UIColor *)bgGray000Color {
    return [UIColor colorWithRGBHex:0xffffff];
}

+ (UIColor *)bgGray001Color {
    return [UIColor colorWithRGBHex:0xf7f7f7];
}

+ (UIColor *)bgGray002Color {
    return [UIColor colorWithRGBHex:0xf0f0f0];
}

+ (UIColor *)bgGreenColor {
    return [UIColor colorWithRGBHex:0x54ae37];
}

// ===============================================
// 分割线用色
// ===============================================

+ (UIColor *)lineGray000Color {
    return [UIColor colorWithRGBHex:0xd7d7d7];
}

+ (UIColor *)lineGray001Color {
    return [UIColor colorWithRGBHex:0xcccccc];
}

// ===============================================
// 文字用色
// ===============================================

+ (UIColor *)fontGray001Color {
    return [UIColor colorWithRGBHex:0xc8c8c8];
}

+ (UIColor *)fontGray002Color {
    return [UIColor colorWithRGBHex:0x5e5e5e];
}

+ (UIColor *)fontGray003Color {
    return [UIColor colorWithRGBHex:0x1e1e1e];
}

+ (UIColor *)fontGray004Color {
    return [UIColor colorWithRGBHex:0x000000];
}

+ (UIColor *)fontWhiteColor {
    return [UIColor gray000Color];
}

+ (UIColor *)fontBlackColor {
    return [UIColor colorWithRGBHex:0x333333];
}

+ (UIColor *)fontGreenColor {
    return [UIColor colorWithRGBHex:0x54ae37];
}

+ (UIColor *)fontOrangeColor {
    return [UIColor colorWithRGBHex:0xff6600];
}

+ (UIColor *)fontRedColor {
    return [UIColor colorWithHexString:@"f95965"];
}

+ (UIColor *)fontDeepBlackColor {
    return [UIColor colorWithHexString:@"1b1b1b"];
}

+ (UIColor *)buttonRed001Color {
    return [UIColor colorWithHexString:@"f95965"];
}

+ (UIColor *)fontGray_one_Color_deprecated {
    return [UIColor gray007Color];
}

+ (UIColor *)fontGray_two_Color_deprecated {
    return [UIColor gray006Color];
}

+ (UIColor *)fontGray_three_Color_deprecated {
    return [UIColor gray005Color];
}
+ (UIColor *)fontGray_four_Color_deprecated {
    return [UIColor gray004Color];
}

@end

