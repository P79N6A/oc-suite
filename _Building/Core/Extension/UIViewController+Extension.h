//
//  UIViewController+StatusBar.h
//  component
//
//  Created by fallen.ink on 4/28/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 

@interface UIViewController ( TopMost )

@property (nonatomic, readonly) UIViewController *topmostViewController;

@end

#pragma mark -

@interface UIViewController ( UINavigationBar )

@property (nonatomic, strong) NSString *navTitleString;
@property (nonatomic, strong) UIView *navTitleView;

@property (nonatomic, strong) UIColor *navBarColor;     //改变导航栏背景颜色
@property (nonatomic, strong) UIColor *navTitleColor;   //改变导航栏标题颜色
@property (nonatomic, strong) UIColor *navLeftItemNormalTitleColor;     //改变导航栏左边按钮的Normal状态标题颜色
@property (nonatomic, strong) UIColor *navRightItemNormalTitleColor;    //改变导航栏右边按钮的Normal状态标题颜色
@property (nonatomic, strong) UIColor *navItemHighlightedTitleColor;    //改变导航栏左边按钮、右边按钮的Highlighted状态标题颜色

- (void)clearNavLeftItem;
- (void)setNavLeftItemWithImage:(NSString *)image target:(id)target action:(SEL)action;
- (void)setNavLeftItemWithName:(NSString *)name target:(id)target action:(SEL)action;
- (void)setNavLeftItemWithName:(NSString *)name font:(UIFont *)font target:(id)target action:(SEL)action;

- (void)setNavRightItemWithImage:(NSString *)image target:(id)target action:(SEL)action;
- (void)setNavRightItemWithName:(NSString *)name target:(id)target action:(SEL)action;
- (void)setNavRightItemWithName:(NSString *)name font:(UIFont *)font target:(id)target action:(SEL)action;

- (void)setNavLeftItemWithButton:(UIButton *)button target:(id)target action:(SEL)action;
- (void)setNavRightItemWithButton:(UIButton *)button target:(id)target action:(SEL)action;

- (void)setNavLeftItemWithView:(UIView *)view target:(id)target action:(SEL)action;
- (void)setNavRightItemWithView:(UIView *)view target:(id)target action:(SEL)action;

// 属性设置

- (void)setNavLeftItemHidden:(BOOL)hidden animate:(BOOL)animate;
- (void)setNavRightItemHidden:(BOOL)hidden animate:(BOOL)animate;

// frame 修改

- (void)setNavigationBarTitleVerticalPositionAdjustmentOffset:(CGFloat)verticalOffset;
- (void)setNavigationBarTitleVerticalPositionAdjustmentOffsetDefault;

- (void)setNavigationBarBackButtonVerticalPositionAdjustmentOffset:(CGFloat)verticalOffset;
- (void)setNavigationBarBackButtonVerticalPositionAdjustmentOffsetDefault;

/**
 *  设置导航栏高度，一般在viewWillAppear中调用
 */
- (void)setNavigationBarHeight:(CGFloat)height;
- (void)setNavigationBarHeightDefault;

@end

#pragma mark - 

@interface UIViewController ( Present )

- (void)presentViewControllerTransparently:(UIViewController *)viewControllerToPresent completion:(void (^)(void))completion;

@end

#pragma mark - 

@interface UIViewController ( RecursiveDescription )

/**
 *  @brief  视图层级
 *
 *  @return 视图层级字符串
 */
- (NSString *)recursiveDescription;

@end

@interface UIViewController (LJ_AlertViewController)

-(void)lj_alertViewController:(NSString*)title message:(NSString*)message cancle:(void (^ __nullable)(UIAlertAction *action))cancleHandler confirm:(void (^ __nullable)(UIAlertAction *action))confirmHandler;

@end


