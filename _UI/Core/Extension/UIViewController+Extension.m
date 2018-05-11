//
//  UIViewController+StatusBar.m
//  component
//
//  Created by fallen.ink on 4/28/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "UIViewController+Extension.h"
#import "_precompile.h"
#import "_foundation.h"
#import "_frame.h"
#import "UIView+Extension.h"
#import "UIButton+Extension.h"
#import "NSString+Size.h"

#pragma mark -

@implementation UIViewController ( TopMost )

- (UIViewController *)topmostViewController {
    if (self.presentedViewController) {
        return self.presentedViewController.topmostViewController;
    }
    
    return self;
}

@end

#pragma mark -

static const CGFloat kNavigationItemFontSize = 16.0f;
static CGFloat kNavigationBarDefaultHeight    = 0.f;

@implementation UIViewController ( UINavigationBar )

+ (void)initialize {
    kNavigationBarDefaultHeight = navigation_bar_height;
}

#pragma mark - Getters & Setters

- (void)setNavBarColor:(UIColor *)navBarColor {
    self.navigationController.navigationBar.barTintColor = navBarColor;
}

- (UIColor*)navBarColor {
    return self.navigationController.navigationBar.barTintColor;
}

- (void)setNavTitleColor:(UIColor *)navTitleColor {
    if (!navTitleColor) {
        navTitleColor = [UIColor darkTextColor];
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:navTitleColor}];
    NSArray* titleLabels = [self.navigationItem.titleView allViewOfClass:[UILabel class]];
    for (UILabel* label in titleLabels) {
        label.textColor = navTitleColor;
    }
    
    NSArray* allButtons = [self.navigationItem.titleView allViewOfClass:[UIButton class]];
    for (UIButton* tmpButton in allButtons) {
        [tmpButton setTitleColor:navTitleColor forState:UIControlStateNormal];
    }
}

- (UIColor*)navTitleColor {
    UIColor* titleColor = [self.navigationController.navigationBar.titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    if (titleColor == nil) {
        UILabel* titleLabel = (UILabel*)[self.navigationItem.titleView firstSubviewOfClass:[UILabel class]];
        if (titleLabel) {
            titleColor = titleLabel.textColor;
        }
    }
    return titleColor;
}

- (void)setNavLeftItemNormalTitleColor:(UIColor *)navItemTitleColor {
    if (!navItemTitleColor) return;
    
    for (UIBarButtonItem* item in self.navigationItem.leftBarButtonItems) {
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName:navItemTitleColor} forState:UIControlStateNormal];
        NSArray* allButtons = [item.customView allViewOfClass:[UIButton class]];
        for (UIButton* tmpButton in allButtons) {
            [tmpButton setTitleColor:navItemTitleColor forState:UIControlStateNormal];
        }
    }
}

- (UIColor*)navLeftItemNormalTitleColor {
    NSArray* buttonItems = self.navigationItem.leftBarButtonItems;
    if (buttonItems.count > 0) {
        UIBarButtonItem* item = [buttonItems firstObject];
        return [[item titleTextAttributesForState:UIControlStateNormal] objectForKey:NSForegroundColorAttributeName];
    } else {
        return nil;
    }
}

- (void)setNavRightItemNormalTitleColor:(UIColor *)navItemTitleColor {
    for (UIBarButtonItem* item in self.navigationItem.rightBarButtonItems) {
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName:navItemTitleColor} forState:UIControlStateNormal];
        NSArray* allButtons = [item.customView allViewOfClass:[UIButton class]];
        for (UIButton* tmpButton in allButtons) {
            [tmpButton setTitleColor:navItemTitleColor forState:UIControlStateNormal];
        }
    }
}

- (UIColor*)navRightItemNormalTitleColor {
    NSArray* buttonItems = self.navigationItem.rightBarButtonItems;
    if (buttonItems.count > 0) {
        UIBarButtonItem* item = [buttonItems firstObject];
        return [[item titleTextAttributesForState:UIControlStateNormal] objectForKey:NSForegroundColorAttributeName];
    } else {
        return nil;
    }
}

- (void)setNavItemHighlightedTitleColor:(UIColor *)navItemTitleColor {
    for (UIBarButtonItem* item in self.navigationItem.leftBarButtonItems) {
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName:navItemTitleColor} forState:UIControlStateHighlighted];
        NSArray* allButtons = [item.customView allViewOfClass:[UIButton class]];
        for (UIButton* tmpButton in allButtons) {
            [tmpButton setTitleColor:navItemTitleColor forState:UIControlStateHighlighted];
        }
    }
    
    for (UIBarButtonItem* item in self.navigationItem.rightBarButtonItems) {
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName:navItemTitleColor} forState:UIControlStateHighlighted];
        NSArray* allButtons = [item.customView allViewOfClass:[UIButton class]];
        for (UIButton* tmpButton in allButtons) {
            [tmpButton setTitleColor:navItemTitleColor forState:UIControlStateHighlighted];
        }
    }
    
    NSArray* titleAllButtons = [self.navigationItem.titleView allViewOfClass:[UIButton class]];
    for (UIButton* tmpButton in titleAllButtons) {
        [tmpButton setTitleColor:navItemTitleColor forState:UIControlStateHighlighted];
    }
}

- (UIColor *)navItemHighlightedTitleColor {
    NSArray* leftButtonItems = self.navigationItem.leftBarButtonItems;
    if (leftButtonItems.count > 0) {
        UIBarButtonItem* item = [leftButtonItems firstObject];
        return [[item titleTextAttributesForState:UIControlStateHighlighted] objectForKey:NSForegroundColorAttributeName];
    } else {
        NSArray* rightButtonItems = self.navigationItem.rightBarButtonItems;
        if (rightButtonItems.count > 0) {
            UIBarButtonItem* item = [rightButtonItems firstObject];
            return [[item titleTextAttributesForState:UIControlStateHighlighted] objectForKey:NSForegroundColorAttributeName];
        } else {
            return nil;
        }
    }
}

#pragma mark - Navigation bar

- (void)setNavigationBarHeight:(CGFloat)height withOriginalPosition:(BOOL)bOriginalPosition {
    CGRect rect = self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(rect.origin.x, rect.origin.y, rect. size.width, height);
    
    if (bOriginalPosition) {
        [self setNavigationBarTitleVerticalPositionAdjustmentOffset:kNavigationBarDefaultHeight-height];
        
        [self setNavigationBarBackButtonVerticalPositionAdjustmentOffset:kNavigationBarDefaultHeight-height];
    }
    
    [self.navigationController.navigationBar setNeedsDisplay];
    [self.navigationController.navigationBar setNeedsLayout];
}

/**
 *  默认做法，保持原有控件的位置
 */
- (void)setNavigationBarHeight:(CGFloat)height {
    [self setNavigationBarHeight:height withOriginalPosition:YES];
}

- (void)setNavigationBarHeightDefault {
    [self setNavigationBarHeight:kNavigationBarDefaultHeight]; //fallenink:  总是44么？
    
    [self setNavigationBarTitleVerticalPositionAdjustmentOffsetDefault];
    
    [self setNavigationBarBackButtonVerticalPositionAdjustmentOffsetDefault];
}

#pragma mark - Middle

- (NSString *)navTitleString {
    return self.navigationItem.title ? self.navigationItem.title : self.title;
}

- (void)setNavTitleString:(NSString *)titleString {
    UIColor *navigationBarTintColor = [[[UINavigationBar appearance] tintColor] copy];
    
    //自定义标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize: 18.0];
    titleLabel.textColor = navigationBarTintColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = titleString;
    self.navigationItem.titleView = titleLabel;
}

- (UIView *)navTitleView {
    return self.navigationItem.titleView;
}

- (void)setNavTitleView:(UIView *)view {
    [self setNavigationBarTitle:view];
}

- (void)setNavigationBarTitle:(id)content {
    if (content) {
        if ([content isKindOfClass:[NSString class]]) {
            self.navigationItem.titleView = nil;
            self.navigationItem.title = content;
        } else if ([content isKindOfClass:[UIImage class]]) {
            UIImageView * imageView = [[UIImageView alloc] initWithImage:content];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            
            self.navigationItem.titleView = imageView;
        } else if ( [content isKindOfClass:[UIView class]]) {
            UIView *view = content;
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            view.autoresizesSubviews = YES;
            view.x = self.view.bounds.size.width/2;
            
            self.navigationItem.titleView = content;
        } else if ( [content isKindOfClass:[UIViewController class]]) {
            self.navigationItem.titleView = ((UIViewController *)content).view;
        }
    }
}

- (void)setNavigationBarTitleVerticalPositionAdjustmentOffset:(CGFloat)verticalOffset {
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:verticalOffset
                                                                  forBarMetrics: UIBarMetricsDefault];
}

- (void)setNavigationBarTitleVerticalPositionAdjustmentOffsetDefault {
    [self setNavigationBarTitleVerticalPositionAdjustmentOffset:0.f];
}

#pragma mark - Left

- (void)clearNavLeftItem {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.navigationItem setLeftBarButtonItems:nil];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
    [self.navigationItem setHidesBackButton:YES];
}

- (void)setNavLeftItemWithImage:(NSString *)image target:(id)target action:(SEL)action {
    // 左边按钮
    UIImage *nimg = [UIImage imageNamed:image];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, nimg.size.width, nimg.size.height)];
    [btn setImage:nimg forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
}

- (void)setNavLeftItemWithName:(NSString *)name target:(id)target action:(SEL)action {
    [self setNavLeftItemWithName:name font:[UIFont systemFontOfSize:kNavigationItemFontSize] target:target action:action];
}

- (void)setNavLeftItemWithName:(NSString *)name font:(UIFont *)font target:(id)target action:(SEL)action {
    UIColor *navigationBarTintColor = [[[UINavigationBar appearance] tintColor] copy];
    NSString *leftTitle = name;
    UIFont *titleLabelFont = font;
    CGSize titleSize = [leftTitle sizeWithFont:titleLabelFont constrainedToSize:CGSizeMake(100, 1000) lineBreakMode:NSLineBreakByWordWrapping];  //一行宽度最大为 100 高度1000
    UIButton *t = [UIButton buttonWithType:UIButtonTypeCustom];
    t.titleLabel.font = titleLabelFont;
    [t setFrame:CGRectMake(0, 0, titleSize.width, self.navigationController.navigationBar.frame.size.height)];
    [t setTitle:leftTitle forState:UIControlStateNormal];
    [t setTitleColor:navigationBarTintColor];
    [t addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [t setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithCustomView:t];
    
    [self.navigationItem setLeftBarButtonItem:leftBtn];
}

/**
 *  注意，7.0，7.0之后，处理不一样！
 
 *  警告：：：：
 
 *  这里依赖上面设置的页面体系 hierichy！！！！！！fallen：屌爆了！
 
 *
 */
- (void)setNavigationBarBackButtonVerticalPositionAdjustmentOffset:(CGFloat)verticalOffset {
    UIBarButtonItem *backButtonItem = [self.navigationItem.leftBarButtonItems lastObject];
    UIView *leftButtonHolderView = (UIView *)backButtonItem.customView;
    UIButton *backButon = (UIButton *)leftButtonHolderView;
    
    [backButon setContentEdgeInsets:UIEdgeInsetsMake(verticalOffset, 0, -verticalOffset, 0)];
}

- (void)setNavigationBarBackButtonVerticalPositionAdjustmentOffsetDefault {
    [self setNavigationBarTitleVerticalPositionAdjustmentOffset:0.f];
}

- (void)setNavLeftItemWithButton:(UIButton *)button target:(id)target action:(SEL)action {
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setLeftBarButtonItem:rightBtn];
}

#pragma mark - Right

- (void)setNavRightItemWithImage:(NSString *)image target:(id)target action:(SEL)action {
    UIImage *nimg = [UIImage imageNamed:image];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, nimg.size.width*2, nimg.size.height*2)];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn setImage:nimg forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.navigationItem setRightBarButtonItem:rightBtn];
}

- (void)setNavRightItemWithButton:(UIButton *)button target:(id)target action:(SEL)action {
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:rightBtn];
}

- (void)setNavLeftItemWithView:(UIView *)view target:(id)target action:(SEL)action {
    UITapGestureRecognizer *reg = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    if (target) view.userInteractionEnabled = YES;
    [view addGestureRecognizer:reg];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithCustomView:view];
    [self.navigationItem setLeftBarButtonItem:leftBtn];
}

- (void)setNavRightItemWithView:(UIView *)view target:(id)target action:(SEL)action {
    UITapGestureRecognizer *reg = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    if (target) view.userInteractionEnabled = YES;
    [view addGestureRecognizer:reg];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:view];
    [self.navigationItem setRightBarButtonItem:rightBtn];
}

- (void)setNavRightItemWithName:(NSString *)name target:(id)target action:(SEL)action {
    [self setNavRightItemWithName:name font:[UIFont systemFontOfSize:kNavigationItemFontSize] target:target action:action];
}

- (void)setNavRightItemWithName:(NSString *)name font:(UIFont *)font target:(id)target action:(SEL)action {
    // 右边按钮
    NSString *rightTitle = name;
    UIFont *titleLabelFont = font;
    CGSize titleSize = [rightTitle sizeWithFont:titleLabelFont constrainedToSize:CGSizeMake(100, 1000) lineBreakMode:NSLineBreakByWordWrapping];  //一行宽度最大为 100 高度1000
    UIButton *t = [UIButton buttonWithType:UIButtonTypeCustom];
    t.titleLabel.font = titleLabelFont;
    [t setFrame:CGRectMake(0, 0, titleSize.width, self.navigationController.navigationBar.frame.size.height)];
    [t setTitle:rightTitle forState:UIControlStateNormal];
    
    UIColor *navigationBarTintColor = [[[UINavigationBar appearance] tintColor] copy];
    [t setTitleColor:navigationBarTintColor];
    [t addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [t setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:t];
    [self.navigationItem setRightBarButtonItem:rightBtn animated:NO];
}

#pragma mark - 属性设置

- (void)setNavItem:(UIView *)item hidden:(BOOL)hidden animate:(BOOL)animate {
//    if (animate) {
//        @weakify(item)
//        POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
//        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
//            @strongify(item)
//            
//            item.userInteractionEnabled = !hidden;
//        };
//        anim.toValue = hidden ? @(0.0) : @(1.0);
//        [item pop_addAnimation:anim forKey:@"alpha"];
//    } else {
//        item.hidden = hidden;
//        item.userInteractionEnabled = !hidden;
//    }
}

- (void)setNavLeftItemHidden:(BOOL)hidden animate:(BOOL)animate {
    UIBarButtonItem *navLeftButtonItem = [self.navigationItem leftBarButtonItem];
    
    [self setNavItem:navLeftButtonItem.customView hidden:hidden animate:animate];
}

- (void)setNavRightItemHidden:(BOOL)hidden animate:(BOOL)animate {
    UIBarButtonItem *navRightButtonItem = [self.navigationItem rightBarButtonItem];
    
    [self setNavItem:navRightButtonItem.customView hidden:hidden animate:animate];
}

@end

#pragma mark - 

@implementation UIViewController ( Present )

- (void)presentViewControllerTransparently:(UIViewController *)viewControllerToPresent completion:(void (^)(void))completion {
    UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:viewControllerToPresent];
    if (system_version_iOS8_or_later) {
        na.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    } else {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    
    [self presentViewController:na animated:YES completion:completion];
}

@end

#pragma mark - 

@implementation UIViewController ( RecursiveDescription )

/**
 *  @brief  视图层级
 *
 *  @return 视图层级字符串
 */
- (NSString *)recursiveDescription {
    NSMutableString *description = [NSMutableString stringWithFormat:@"\n"];
    [self addDescriptionToString:description indentLevel:0];
    return description;
}

- (void)addDescriptionToString:(NSMutableString*)string indentLevel:(NSInteger)indentLevel {
    NSString *padding = [@"" stringByPaddingToLength:indentLevel withString:@" " startingAtIndex:0];
    [string appendString:padding];
    [string appendFormat:@"%@, %@",[self debugDescription],NSStringFromCGRect(self.view.frame)];
    
    for (UIViewController *childController in self.childViewControllers) {
        [string appendFormat:@"\n%@>",padding];
        [childController addDescriptionToString:string indentLevel:indentLevel + 1];
    }
}


@end

@implementation UIViewController (LJ_AlertViewController)

-(void)lj_alertViewController:(NSString*)title message:(NSString*)message cancle:(void (^ __nullable)(UIAlertAction *action))cancleHandler confirm:(void (^ __nullable)(UIAlertAction *action))confirmHandler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancalAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        cancleHandler(action);
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        confirmHandler(action);
    }];
    
    [alertVC addAction:cancalAction];
    [alertVC addAction:confirmAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end

