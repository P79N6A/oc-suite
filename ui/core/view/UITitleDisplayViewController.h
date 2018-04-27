//
//  QQBaseTitleDisplayVC.h
//  QQBaseTitleDisplayVC
//
//  Created by YuanBo on 2016/11/3.
//  Copyright © 2016年 YuanBo. All rights reserved.
//
//  使用说明：
//  FIXME: 

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    QQTitleDisplayAnimationTypeDefault = 0,
    QQTitleDisplayAnimationTypeDelayed,
} QQTitleDisplayAnimationType;


@class QQBaseTitleDisplayVC;
@protocol QQBaseTitleDisplayVCDelegate <NSObject>
@optional

- (void)didSrollToIndex:(NSInteger)index;
- (void)didSrollToVC:(__kindof UIViewController *)vc;

@end


@interface QQBaseTitleDisplayVC : UIViewController


//都有默认值 可以不设置
@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *selectTitleColor;
@property (nonatomic, strong) UIColor *titleSplitColor;
@property (nonatomic, assign) CGFloat indicatorWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (assign, nonatomic) BOOL allowBounce;
@property (assign, nonatomic) QQTitleDisplayAnimationType animationType;
@property (nonatomic, assign) CGFloat topMargin;
@property (assign, nonatomic) NSInteger pageIndex;

@property (weak, nonatomic) id<QQBaseTitleDisplayVCDelegate> delegate;



//一定要调用这个方法 调用完以后才会开始布局
- (void)commitChildVC;

//0的话隐藏 负数显示红点 正数显示具体数值
//请先调用commitChildVC 再调用该方法
- (void)setBadgeNumber:(NSInteger)count ForVC:(__kindof UIViewController *)vc;
- (void)setBadgeNumber:(NSInteger)count ForIndex:(NSInteger)index;

//设置新的new标志
- (void)setNewTagShow:(BOOL)show ForVC:(__kindof UIViewController *)vc;
- (void)setNewTagShow:(BOOL)show ForIndex:(NSInteger)index;

- (void)setSelectIndex:(NSInteger)index withAnimation:(BOOL)animation;

- (CGFloat)getTotalHeightWithContentHeight:(CGFloat)contentHeight;

@end
