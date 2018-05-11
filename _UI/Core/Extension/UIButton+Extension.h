//
//  UIButton+Adjust.h
//  component
//
//  Created by fallen.ink on 4/9/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Adjust)

/**
 *  重新布局按钮中的图片和文字
 
 *  space 会保持绝对居中，fallenink：还没做到！
 */

- (void)centerImageAndTitle:(float)space;
- (void)centerImageAndTitle;

/**
 *  图片水平居中、居上
 *
 *  @param space 图片与文字的间距
 */
- (void)verticalCenterAndTopImageWithSpace:(CGFloat)space;

/**
 *  图片垂直居中、居左
 *
 *  @param space 图片与文字间距
 */
- (void)horizontalCenterAndLeftImageWithSpace:(CGFloat)space;

/**
 *  图片垂直居中、题目局右
 *
 *  @param space 图片与文字间距
 */
- (void)horizontalCenterAndLeftTitleWithSpace:(CGFloat)space;

@end

@interface UIButton ( Setting )

#pragma mark - Setter

/**
 * 设置颜色
 
 * 状态：默认态、高亮态
 */

- (void)setTitleColor:(UIColor *)color;

- (void)setTitleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor;

/**
 * 设置背景色
 
 * 用image去实现
 */

- (void)setNormalBackgroundColor:(UIColor *)normalColor disableBackgroundColor:(UIColor *)disableColor;

/**
 *  设置不同状态的背景色
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end

#pragma mark - Enlarge - inspire by http://blog.csdn.net/jerry19860710/article/details/22800309

/**
 *  Usage
 
 UIButton* enlargeButton1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 [enlargeButton1 setTitle:@"Enlarge Button" forState:UIControlStateNormal];
 [enlargeButton1 setFrame:CGRectMake(90, 150, 100, 50)];
 [enlargeButton1 addTarget:self action:@selector(onButtonTap:) forControlEvents:UIControlEventTouchUpInside];
 [enlargeButton1 sizeToFit];
 [self.view addSubview:enlargeButton1];
 
 // 增加 button 的點擊範圍
 [enlargeButton1 setEnlargeEdgeWithTop:20 right:20 bottom:20 left:0];
 
 */
@interface UIButton ( Enlarge )

/**
 *  设置按钮额外热区
 */
@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;

/**
 *  扩大button点击区域,4边设置相同值
 */
@property (nonatomic, assign) CGFloat enlargedEdge;

/**
 *  扩大button点击区域,4边分别设置
 */
- (void)setEnlargeEdgeWithTop:(CGFloat)top
                         left:(CGFloat)left
                       bottom:(CGFloat)bottom
                        right:(CGFloat)right;

@end

#pragma mark - 

@interface UIButton ( CountDown )

- (void)startTime:(NSInteger )timeout title:(NSString *)tittle waitTittle:(NSString *)waitTittle;

@end

