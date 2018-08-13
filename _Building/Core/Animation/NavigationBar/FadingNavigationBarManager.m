//
//  NavigationBarManagerX.m
//  student
//
//  Created by fallen.ink on 06/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_Foundation.h"
#import "FadingNavigationBarManager.h"
#import "Masonry.h"
#import "TLYDelegateProxy.h"
#import "_pragma_push.h"

static const CGFloat kDefaultFullOffset    = 200.0f;
static const float   kMaxAlphaValue        = 0.995f;
static const float   kMinAlphaValue        = 0.0f;
static const float   kDefaultAnimationTime = 0.35f;

@interface FadingNavigationBarManager ()

@property (nonatomic, strong) UINavigationBar *selfNavigationBar;
@property (nonatomic, strong) UINavigationController *selfNavigationController;

@property (nonatomic, strong) UIImage *saveImage;
@property (nonatomic, strong) UIColor *saveColor;
@property (nonatomic, strong) UIColor *saveTintColor;
@property (nonatomic, strong) NSDictionary *saveTitleAttribute;
@property (nonatomic, assign) UIStatusBarStyle saveBarStyle;

@property (nonatomic, assign) BOOL setFull;
@property (nonatomic, assign) BOOL setZero;
@property (nonatomic, assign) BOOL setChange;

@property (nonatomic, strong) TLYDelegateProxy *delegateProxy;

@end

@implementation FadingNavigationBarManager

- (void)dealloc {
    // sanity check
    if (_scrollView.delegate == _delegateProxy) {
        _scrollView.delegate = _delegateProxy.originalDelegate;
    }
}

#pragma mark - property set

- (void)setTintColor:(UIColor *)color {
    _tintColor = color;
    self.selfNavigationBar.tintColor = color;
    [self setTitleColorWithColor:color];
}

- (void)setBackgroundImage:(UIImage *)image {
    [self.selfNavigationBar setBackgroundImage:image
                                 forBarMetrics:UIBarMetricsDefault];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)style {
    _statusBarStyle = style;
    
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

- (void)setMinAlphaValue:(float)value {
    value = value < kMinAlphaValue ? kMinAlphaValue : value;
    _minAlphaValue = value;
}

- (void)setMaxAlphaValue:(float)value {
    value = value > kMaxAlphaValue ? kMaxAlphaValue : value;
    _maxAlphaValue = value;
}

- (void)reStoreToSystemNavigationBar {
    [self.selfNavigationController setValue:[UINavigationBar new] forKey:@"navigationBar"];
    [self.selfNavigationController.navigationBar setTranslucent:NO];
}

#pragma mark - Public Method

- (void)managerWithController:(UIViewController *)viewController {
    UINavigationBar *navigationBar = viewController.navigationController.navigationBar;
    
    self.selfNavigationController = viewController.navigationController;
    self.selfNavigationBar = navigationBar;
    
    /**
     *  @knowledge 怎么让self.view的Y从navigationBar下面开始计算: http://blog.csdn.net/zww1984774346/article/details/51730357
     *  iOS7以上系统
     *  1. translucent == NO, 不需要设置 edgesForExtendedLayout
     *  2. translucent == YES, 设置 UIRectEdgeNone 则 从nav bar 下面开始算起；设置 UIRectEdgeAll 则 从nav bar 上面开始算起
     */
    viewController.edgesForExtendedLayout = viewController.edgesForExtendedLayout | UIRectEdgeTop;
    /**
     * [记录UITableviewWrapperView 距离上面有空白问题](http://blog.csdn.net/xinkongqishf/article/details/68067802)
     */
    viewController.automaticallyAdjustsScrollViewInsets = false;
    [self.selfNavigationController.navigationBar setTranslucent:YES];
    
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
}

- (void)changeAlphaWithCurrentOffset:(CGFloat)currentOffset {
//    INFO(@"current offset = %@", @(currentOffset));
    
    float currentAlpha = [self curretAlphaForOffset:currentOffset];
    
    if (![self.barColor isEqual:[UIColor clearColor]]) {
        if (!self.continues) {
            if (currentAlpha == self.minAlphaValue) {
                [self setNavigationBarColorWithAlpha:self.minAlphaValue];
            } else if (currentAlpha == self.maxAlphaValue) {
                [UIView animateWithDuration:kDefaultAnimationTime animations:^{
                    [self setNavigationBarColorWithAlpha:self.maxAlphaValue];
                }];
                self.setChange = YES;
            } else {
                if (self.setChange) {
                    [UIView animateWithDuration:kDefaultAnimationTime animations:^{
                        [self setNavigationBarColorWithAlpha:self.minAlphaValue];
                    }];
                    self.setChange = NO;
                }
            }
        } else {
            [self setNavigationBarColorWithAlpha:currentAlpha];
        }
    } else { // 透明色
        
    }
    
    if (self.allChange) [self changeTintColorWithOffset:currentAlpha];
}


#pragma mark - calculation
- (float)curretAlphaForOffset:(CGFloat)offset {
    float currentAlpha = (offset - self.zeroAlphaOffset) / (float)(self.fullAlphaOffset - self.zeroAlphaOffset);
    currentAlpha = currentAlpha < self.minAlphaValue ? self.minAlphaValue : (currentAlpha > self.maxAlphaValue ? self.maxAlphaValue : currentAlpha);
    currentAlpha = self.reversal ? self.maxAlphaValue + self.minAlphaValue - currentAlpha : currentAlpha;
    return currentAlpha;
}

- (void)changeTintColorWithOffset:(float)currentAlpha {
    if (currentAlpha >= self.maxAlphaValue && self.fullAlphaTintColor != nil) {
        if (self.setFull) {
            self.setFull = NO;
            self.setZero  = YES;
        } else {
            if (self.reversal) {
                self.setFull = YES;
            }
            return;
        }
        self.selfNavigationBar.tintColor = self.fullAlphaTintColor;
        [self setTitleColorWithColor:self.fullAlphaTintColor];
        [self setUIStatusBarStyle:self.fullAlphaBarStyle];
    } else if (self.tintColor != nil) {
        if (self.setZero) {
            self.setZero = NO;
            self.setFull = YES;
        } else {
            return;
        }
        self.selfNavigationBar.tintColor = self.tintColor;
        [self setTitleColorWithColor:self.tintColor];
        [self setUIStatusBarStyle:self.statusBarStyle];
    }
}

#pragma mark - private method

- (void)initBaseData {
    self.delegateProxy = [[TLYDelegateProxy alloc] initWithMiddleMan:self];
    
    self.maxAlphaValue = kMaxAlphaValue;
    self.minAlphaValue = kMinAlphaValue;
    self.fullAlphaOffset = kDefaultFullOffset;
    self.zeroAlphaOffset = -navigation_bar_height;
    self.setZero = YES;
    self.setFull = YES;
    self.allChange = YES;
    self.continues = YES;
}

- (void)setTitleColorWithColor:(UIColor *)color {
    NSMutableDictionary *textAttr = [NSMutableDictionary dictionaryWithDictionary:self.selfNavigationBar.titleTextAttributes];
    [textAttr setObject:color forKey:NSForegroundColorAttributeName];
    
    // 暂时用适配方案
    if (IOS11_OR_LATER) {
        [textAttr setObject:[UIColor clearColor] forKey:NSBackgroundColorAttributeName];
    }
    
    self.selfNavigationBar.titleTextAttributes = textAttr;
}

- (void)setNavigationBarColorWithAlpha:(float)alpha {
    [self setBackgroundImage:[self imageWithColor:[self.barColor colorWithAlphaComponent:alpha]]];
}

- (void)setUIStatusBarStyle:(UIStatusBarStyle)style {
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *imgae = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgae;
}

#pragma mark - UIScrollViewDelegate

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    
    if (_scrollView.delegate != self.delegateProxy)
    {
        self.delegateProxy.originalDelegate = _scrollView.delegate;
        _scrollView.delegate = (id)self.delegateProxy;
    }
    
    [self scrollViewDidScroll:_scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self changeAlphaWithCurrentOffset:scrollView.contentOffset.y];
}


@end

@implementation UIViewController ( FadingNavigationBarManager )

- (FadingNavigationBarManager *)fadingNavigationBarManager {
    id instance = [self getAssociatedObjectForKey:"fadingNavigationBarManager"];
    if (!instance) {
        instance = [FadingNavigationBarManager new];
        
        [instance initBaseData];
        
        [self retainAssociatedObject:instance forKey:"fadingNavigationBarManager"];
    }
    
    return instance;
}

@end

#import "_pragma_pop.h"
