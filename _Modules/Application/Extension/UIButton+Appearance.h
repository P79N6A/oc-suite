//
//  UIButton+Theme.h
// fallen.ink
//
//  Created by 李杰 on 4/20/15.
//
//

#import "UIButton+Extension.h"

@interface UIButton (Appearance)

- (void)liningStyled:(UIColor *)color; // 线条风格

- (void)liningStyledWithTitleColor:(UIColor *)color borderColor:(UIColor *)bordercolor;

- (void)colorlumpStyled:(UIColor *)color; // 色块风格

/**
 * 主题特化
 */
- (void)thematized DEPRECATED_ATTRIBUTE;

- (void)liningThematized:(UIColor *)color DEPRECATED_ATTRIBUTE; // 线条风格

- (void)liningThematizedWithTextColor:(UIColor *)color borderColor:(UIColor *)bordercolor DEPRECATED_ATTRIBUTE;// 分别定制 线条 和 字体 颜色

- (void)colorlumpThematized:(UIColor *)color DEPRECATED_ATTRIBUTE; // 色块风格

/**
 * 主题特化,指定背景颜色
 */
- (void)thematizedWithBackgroundColor:(UIColor*)backgroundColor DEPRECATED_ATTRIBUTE;

@end
