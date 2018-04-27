//
//  UIButton+Factory.h
//  teacher
//
//  Created by fallen.ink on 03/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @knowledge
 *
 *  1. adjustsImageWhenHighlighted, 默认情况下，当按钮高亮的情况下，图像的颜色会被画深一点，如果这下面的这个属性设置为no，那么可以去掉这个功能
 *  2. showsTouchWhenHighlighted, 下面的这个属性设置为yes的状态下，按钮按下会发光
 *  3. adjustsImageWhenDisabled, 默认情况下，当按钮禁用的时候，图像会被画得深一点，设置NO可以取消设置
 *  4. button type:
        typedef enum {
            UIButtonTypeCustom = 0,          自定义风格
            UIButtonTypeRoundedRect,         圆角矩形
            UIButtonTypeDetailDisclosure,    蓝色小箭头按钮，主要做详细说明用
            UIButtonTypeInfoLight,           亮色感叹号
            UIButtonTypeInfoDark,            暗色感叹号
            UIButtonTypeContactAdd,          十字加号按钮
        } UIButtonType;
 *  5. button state
        enum {
            UIControlStateNormal       = 0,         常规状态显现
            UIControlStateHighlighted  = 1 << 0,    高亮状态显现
            UIControlStateDisabled     = 1 << 1,    禁用的状态才会显现
            UIControlStateSelected     = 1 << 2,    选中状态
            UIControlStateApplication  = 0x00FF0000, 当应用程序标志时
            UIControlStateReserved     = 0xFF000000  为内部框架预留，可以不管他
        };
 */

@interface UIButton (Factory)

+ (instancetype)buttonWithType:(UIButtonType)type title:(NSString *)title target:(id)target action:(SEL)action;

+ (instancetype)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

- (void)setNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle;

@end
