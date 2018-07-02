//
//  ZYBannerView.h
//
//  Created by 张志延 on 15/10/17.
//  Copyright (c) 2015年 tongbu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYBannerFooter.h"

@protocol ZYBannerViewDataSource, ZYBannerViewDelegate;

@interface ZYBannerView : UIView

/** 是否需要循环滚动, 默认为 NO */
@property (nonatomic, assign) IBInspectable BOOL shouldLoop;

/** 是否显示footer, 默认为 NO (此属性为YES时, shouldLoop会被置为NO) */
@property (nonatomic, assign) IBInspectable BOOL showFooter;

/** 是否自动滑动, 默认为 NO */
@property (nonatomic, assign) IBInspectable BOOL autoScroll;

/** 是否显示指示器, 默认为 YES */
@property (nonatomic, assign) IBInspectable BOOL showIndicator;

/** 自动滑动间隔时间(s), 默认为 3.0 */
@property (nonatomic, assign) IBInspectable CGFloat scrollInterval;

/** pageControl, 可自由配置其属性 */
@property (nonatomic, strong, readonly) UIPageControl *pageControl;
@property (nonatomic, assign, readwrite)  CGRect pageControlFrame;

@property (nonatomic, weak) IBOutlet id<ZYBannerViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<ZYBannerViewDelegate> delegate;

- (void)reloadData;

- (void)startTimer;
- (void)stopTimer;

@end

@protocol ZYBannerViewDataSource <NSObject>
@required

- (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner;
- (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index;

@optional

- (NSString *)banner:(ZYBannerView *)banner titleForFooterWithState:(ZYBannerFooterState)footerState;

@end

@protocol ZYBannerViewDelegate <NSObject>
@optional

- (void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index;
- (void)bannerFooterDidTrigger:(ZYBannerView *)banner;

@end

/**
 * Usage
 
 - (void)setupBanner
 {
 // 初始化
 self.banner = [[ZYBannerView alloc] init];
 self.banner.dataSource = self;
 self.banner.delegate = self;
 [self.view addSubview:self.banner];
 
 // 设置frame
 self.banner.frame = CGRectMake(0,
 kNavigationBarHeight,
 kScreenWidth,
 kBannerHeight);
 }
 
 #pragma mark - ZYBannerViewDataSource
 
 // 返回 Banner 需要显示 Item(View) 的个数
 - (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner
 {
 return self.dataArray.count;
 }
 
 // 返回 Banner 在不同的 index 所要显示的 View (可以是完全自定义的v iew, 且无需设置 frame)
 - (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index
 {
 // 取出数据
 NSString *imageName = self.dataArray[index];
 
 // 创建将要显示控件
 UIImageView *imageView = [[UIImageView alloc] init];
 imageView.image = [UIImage imageNamed:imageName];
 imageView.contentMode = UIViewContentModeScaleAspectFill;
 
 return imageView;
 }
 
 // 返回 Footer 在不同状态时要显示的文字
 - (NSString *)banner:(ZYBannerView *)banner titleForFooterWithState:(ZYBannerFooterState)footerState
 {
 if (footerState == ZYBannerFooterStateIdle) {
 return @"拖动进入下一页";
 } else if (footerState == ZYBannerFooterStateTrigger) {
 return @"释放进入下一页";
 }
 return nil;
 }
 
 #pragma mark - ZYBannerViewDelegate
 
 // 在这里实现点击事件的处理
 - (void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index
 {
 NSLog(@"点击了第%ld个项目", index);
 }
 
 // 在这里实现拖动 Footer 后的事件处理
 - (void)bannerFooterDidTrigger:(ZYBannerView *)banner
 {
 NSLog(@"触发了footer");
 
 NextViewController *vc = [[NextViewController alloc] init];
 [self.navigationController pushViewController:vc animated:YES];
 }

 
 */
