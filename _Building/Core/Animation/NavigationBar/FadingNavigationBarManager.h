//
//  NavigationBarManagerX.h
//  student
//
//  Created by fallen.ink on 06/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_Foundation.h"

@interface FadingNavigationBarManager : NSObject

@prop_strong(UIScrollView *, scrollView)

@property (nonatomic, strong) UIColor *barColor; // 背景色, 默认白色
@property (nonatomic, strong) UIColor *tintColor; // 前景色
@property (nonatomic, strong) UIImage *backgroundImage; //default is nil
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle; // default is UIStatusBarStyleDefault

@property (nonatomic, assign) float zeroAlphaOffset;//color will changed begin this offset, default is -64
@property (nonatomic, assign) float fullAlphaOffset;//color alpha will be 1 in this offset, default is 200
@property (nonatomic, assign) float minAlphaValue;//bar minAlpha, default is 0
@property (nonatomic, assign) float maxAlphaValue;//bar maxAlpha, default is 1

@property (nonatomic, strong) UIColor *fullAlphaTintColor;//if you set this property, the tintColor will changed in fullAlphaOffset
@property (nonatomic, assign) UIStatusBarStyle fullAlphaBarStyle;//if you set this property, the barStyle will changed in fullAlphaOffset

@property (nonatomic, assign) BOOL allChange;//if allchange = yes, the tintColor will changed with the barColor change, default is yes, if you only want to change barColor, set allChange = NO
@property (nonatomic, assign) BOOL reversal;//this will cause that if currentAlpha = 0.3,it will be 1 - 0.3 = 0.7
@property (nonatomic, assign) BOOL continues;//when continues = YES, bar color will changed whenever you scroll, if you set continues = NO,it only be changed in the fullAlphaOffset

- (void)managerWithController:(UIViewController *)viewController;//you should use this method to init MXNavigationManager

- (void)changeAlphaWithCurrentOffset:(CGFloat)currentOffset;// implemention this method in @selectot(scrollView: scrollViewDidScroll)

- (void)reStoreToSystemNavigationBar; // 让导航栏回到初始状态，一般在viewDidDisappear中调用

@end

@interface UIViewController ( FadingNavigationBarManager )

@property (nonatomic, readonly) FadingNavigationBarManager *fadingNavigationBarManager;

@end

/**
 Usage
 
 - (BOOL)navigationBarHiddenWhenAppear {
 return NO;
 }
 
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 
 {   // 初始化导航栏特效
 
 [self.fadingNavigationBarManager managerWithController:self];
 
 [self.fadingNavigationBarManager setBarColor:background_gray];
 [self.fadingNavigationBarManager setTintColor:[UIColor clearColor]];
 [self.fadingNavigationBarManager setStatusBarStyle:UIStatusBarStyleLightContent];
 [self.fadingNavigationBarManager setZeroAlphaOffset:0];
 [self.fadingNavigationBarManager setFullAlphaOffset:64];
 [self.fadingNavigationBarManager setFullAlphaTintColor:[UIColor fontDeepBlackColor]];
 [self.fadingNavigationBarManager setScrollView:orgDetailTableView];
 }
 }
 
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 
 [self.fadingNavigationBarManager reStoreToSystemNavigationBar];
 }

 
 */
