//
//  AlertView.m
//  AlertView
//
//  Created by YXLONG on 16/7/21.
//  Copyright © 2016年 yxlong. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <objc/runtime.h>
#import "_precompile.h"
#import "_foundation.h"
#import "AlertView.h"
#import "AlertModalBackgroundView.h"

static CGFloat const kDefaultContainerWidth = 280.;
static CGFloat const kTitleMessageSpace = 12;
static CGFloat const kAlertContentViewMinHeight = 80.0;
static CGFloat const kAlertButtonHeight = 44.0;
static CGFloat const kMaxMessageHeight = 220;

CGFloat kDefaultCornerRadius = 8;

#define kAlertLineSpace 0.5
#define kButtonTitleColor [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f]
#define kDestructiveButtonTitleColor [UIColor colorWithRed:0.988 green:0.239 blue:0.224 alpha:1.00]
#define kDefaultAnimationDuration 0.25
#define kDefaultCustomViewSize CGSizeMake(280, 240)

CGSize __AlertView_SizeOfLabel(NSString *text, UIFont *font, CGSize constraintSize){
    NSDictionary *attrs = @{NSFontAttributeName:font};
    CGSize aSize = [text boundingRectWithSize:constraintSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attrs
                                      context:nil].size;
    return CGSizeMake(aSize.width, aSize.height+2);
}

#define SIZE_LABEL(text, font, constraintSize) __AlertView_SizeOfLabel(text, font, constraintSize)

@interface UIViewController (__backgroundView)

- (AlertModalBackgroundView *)backgroundView;

@end

static void* __backgroundViewKey = &__backgroundViewKey;

@implementation UIViewController (__backgroundView)

- (UIView *)backgroundView {
    AlertModalBackgroundView *v = objc_getAssociatedObject(self, __backgroundViewKey);
    if(!v){
        v = [[AlertModalBackgroundView alloc] initWithFrame:self.view.bounds];
        v.autoresizingMask = self.view.autoresizingMask;
        [self.view addSubview:v];
        
        objc_setAssociatedObject(self, __backgroundViewKey, v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return v;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Private classes headers

@interface BlurSupportedBackgroundView : UIView

@property(nonatomic, strong) UIView *backgroundView;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

@property(nonatomic, strong) UIVisualEffectView *blurView;

#endif

@property(nonatomic, assign) BOOL blurEnabled;

- (void)prepareViews;

+ (BOOL)canBlur;

- (void)applyBlurEffect;

- (void)disableBlurEffect;

@end

@interface AlertButtonItem : UIButton

@property(nonatomic, weak) AlertView *alertView;
@property(nonatomic, strong) BlurSupportedBackgroundView *backgroundView;
@property(nonatomic, copy) void(^actionHanlder)(AlertView *alertView, AlertButtonItem *buttonItem);

@end

@interface AlertContentView : BlurSupportedBackgroundView

@property(nonatomic, weak) AlertView *alertView;
@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, strong, readonly) UILabel *messageLabel;
@property(nonatomic, assign) CGSize preferredFrameSize;
@property(nonatomic, assign) UIEdgeInsets contentInsets;

- (void)setTitle:(NSString *)title message:(NSString *)message;

- (void)setTitle:(NSString *)title attributedMessage:(NSAttributedString *)message;

- (CGSize)getFitSize;

@end

@interface AlertViewController : UIViewController

@property (nonatomic, weak) AlertView *alertView;
@property (nonatomic, assign) BOOL rootViewControllerPrefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle rootViewControllerPreferredStatusBarStyle;

@end

@interface AlertViewQueue : NSObject

@property(nonatomic, strong) AlertView *currentAlertView;
@property(nonatomic, assign, getter=isAnimating) BOOL animating;

+ (instancetype)sharedQueue;

- (BOOL)contains:(AlertView *)alertView;

- (AlertView *)dequeue;

- (void)enqueue:(AlertView *)alertView;

- (void)remove:(AlertView *)alertView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface AlertView () {
    AlertContentView *_contentView;
}

@property(nonatomic, strong) NSMutableArray *buttons;
@property(nonatomic, strong) UIWindow *lastKeyWindow;
@property(nonatomic, strong) UIWindow *currentKeyWindow;
@property(nonatomic, assign, getter = isVisible) BOOL visible;
@property(nonatomic, assign) BOOL customViewVisible;
@property(nonatomic, assign) CustomViewPresentationStyle customViewPresentationStyle;

@end

@implementation AlertView

#pragma mark - Initialize

+ (void)initialize {
    if (self == [AlertView class]) {
        [AlertView appearance].titleColor = [UIColor blackColor];
        [AlertView appearance].messageColor = [UIColor blackColor];
        [AlertView appearance].titleFont = [UIFont boldSystemFontOfSize:17.0];
        [AlertView appearance].messageFont = [UIFont systemFontOfSize:14.0];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f){
                kDefaultCornerRadius = 12;
            }
        });
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self=[super initWithFrame:frame]){
        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = kDefaultCornerRadius;
        self.clipsToBounds = YES;
        
        _buttons = @[].mutableCopy;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle {
    if(self = [self initWithFrame:CGRectZero]) {
        
        self.customViewVisible = NO;
        
        _contentView = [[AlertContentView alloc] initWithFrame:CGRectZero];
        _contentView.alertView = self;
        _contentView.contentInsets = UIEdgeInsetsMake(20, 15, 20, 15);
        [self addSubview:_contentView];
        [_contentView setTitle:[title copy] message:[message copy]];
        
        if(cancelButtonTitle&&cancelButtonTitle.length>0){
            [self addButtonWithTitle:cancelButtonTitle style:AlertActionStyleCancel handler:^(AlertView *alertView, AlertButtonItem *buttonItem) {
                [alertView dismiss];
            }];
        }
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor attributedMessage:(NSAttributedString *)message cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonTitleColor:(UIColor *)cancelButtonTitleColor {
    if(self = [self initWithFrame:CGRectZero]) {
        
        // 不使用定制
        self.customViewVisible = NO;
        
        //
        _contentView = [[AlertContentView alloc] initWithFrame:CGRectZero];
        _contentView.alertView = self;
        _contentView.contentInsets = UIEdgeInsetsMake(20, 15, 20, 15);
        
        [_contentView setTitle:[title copy] attributedMessage:[message copy]];
        
        _contentView.titleLabel.textColor = titleColor;
        
        [self addSubview:_contentView];
        
        if(is_string_present(cancelButtonTitle)) {
            [self addButtonWithTitle:cancelButtonTitle
                          titleColor:cancelButtonTitleColor
                               style:AlertActionStyleCancel
                             handler:^(AlertView *alertView, AlertButtonItem *buttonItem) {
                                 [alertView dismiss];
                             }];
        }
    }
    return self;
}

- (instancetype)initWithCustomView:(UIView *)customView {
    if(self = [self initWithCustomView:customView withPresentationStyle:Default]) {
        
    }
    return self;
}

- (instancetype)initWithCustomView:(UIView *)customView withPresentationStyle:(CustomViewPresentationStyle)style {
    if(self = [self initWithFrame:CGRectZero]) {
        self.customViewPresentationStyle = style;
        self.customViewVisible = YES;
        
        _contentView = [[AlertContentView alloc] initWithFrame:CGRectZero];
        _contentView.alertView = self;
        [self addSubview:_contentView];
        if(CGSizeEqualToSize(customView.frame.size, CGSizeZero)){
            _contentView.preferredFrameSize = kDefaultCustomViewSize;
        } else {
            _contentView.preferredFrameSize = customView.frame.size;
        }
        _contentView.frame = CGRectMake(0, 0, _contentView.preferredFrameSize.width, _contentView.preferredFrameSize.height);
        [_contentView addSubview:customView];
        customView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark - Configure

- (void)addButtonWithTitle:(NSString *)title style:(AlertActionStyle)style handler:(void(^)(AlertView *alertView, AlertButtonItem *buttonItem))handler {
    [self addButtonWithTitle:title titleColor:kButtonTitleColor style:style handler:handler];
}

- (void)addButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor style:(AlertActionStyle)style handler:(void (^)(AlertView *, AlertButtonItem *))handler {
    if (self.customViewVisible) {
        return;
    }
    
    AlertButtonItem *button = [[AlertButtonItem alloc] initWithFrame:CGRectZero];
    button.alertView = self;
    button.actionHanlder = handler;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [self addSubview:button];
    
    switch (style) {
        case AlertActionStyleCancel:
            button.titleLabel.font = [UIFont boldSystemFontOfSize:button.titleLabel.font.pointSize];
            break;
        case AlertActionStyleDestructive:
            [button setTitleColor:kDestructiveButtonTitleColor forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    [_buttons addObject:button];
    
    [self updateUILayouts];
}

- (void)addDefaultStyleButtonWithTitle:(NSString *)title handler:(void(^)(AlertView *alertView, AlertButtonItem *buttonItem))handler
{
    [self addButtonWithTitle:title style:AlertActionStyleDefault handler:handler];
}

#pragma mark - Update

- (void)updateUILayouts
{
    if(self.customViewVisible){
        return;
    }
    
    CGSize size = [_contentView getFitSize];
    _contentView.frame = CGRectMake(0, 0, kDefaultContainerWidth, size.height);
    
    if(_buttons.count==1){
        AlertButtonItem *button = _buttons[0];
        button.frame = CGRectMake(0, CGRectGetMaxY(_contentView.frame)+kAlertLineSpace, kDefaultContainerWidth, kAlertButtonHeight);
    }
    else if(_buttons.count==2){
        
        CGFloat originY = CGRectGetMaxY(_contentView.frame)+kAlertLineSpace;
        
        NSInteger leftItemWidth = (kDefaultContainerWidth-kAlertLineSpace)/2;
        AlertButtonItem *button = _buttons[0];
        button.frame = CGRectMake(0, originY, leftItemWidth, kAlertButtonHeight);
        
        CGFloat originX = leftItemWidth + kAlertLineSpace;
        CGFloat rightItemWidth = kDefaultContainerWidth-originX;
        button = _buttons[1];
        button.frame = CGRectMake(originX, originY, rightItemWidth, kAlertButtonHeight);
    }
    else if(_buttons.count>2){
        
        UIView *lastView = _contentView;
        
        for(int i=0;i<_buttons.count;i++){
            AlertButtonItem *button = _buttons[i];
            button.frame = CGRectMake(0, CGRectGetMaxY(lastView.frame)+kAlertLineSpace, kDefaultContainerWidth, kAlertButtonHeight);
            lastView = button;
        }
    }
    
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    if(self.customViewVisible){
        return _contentView.frame.size;
    }
    
    CGFloat maxHeight;
    CGSize size = [_contentView getFitSize];
    maxHeight = size.height;
    
    if(_buttons.count<3) {
        maxHeight += kAlertButtonHeight+kAlertLineSpace;
    } else {
        maxHeight += _buttons.count*(kAlertLineSpace+kAlertButtonHeight);
    }
    return CGSizeMake(kDefaultContainerWidth, maxHeight);
}

- (void)applyBlurEffect {
    [_contentView applyBlurEffect];
    for(AlertButtonItem *item in _buttons){
        [item.backgroundView applyBlurEffect];
    }
}

- (void)disableBlurEffect {
    [_contentView disableBlurEffect];
    for(AlertButtonItem *item in _buttons){
        [item.backgroundView disableBlurEffect];
    }
}

- (void)showWithAnimation:(BOOL)animated completion:(dispatch_block_t)completion {
    if(animated) {
        NSTimeInterval _duration = kDefaultAnimationDuration;
        if(self.currentKeyWindow.rootViewController.view){
            self.currentKeyWindow.rootViewController.backgroundView.alpha = 0;
        }
        if(self.customViewVisible){
            
            if(self.customViewPresentationStyle==Default){
                self.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }
            else if(self.customViewPresentationStyle==MoveUp){
                _duration = 0.35;
                self.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
            }
            else if (self.customViewPresentationStyle==MoveDown){
                _duration = 0.35;
                self.transform = CGAffineTransformMakeTranslation(0, -[UIScreen mainScreen].bounds.size.height);
            }
        } else {
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }
        
        [UIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if(self.customViewVisible){
                if(self.customViewPresentationStyle==Default){
                    
                }
                else if(self.customViewPresentationStyle==MoveUp){
                    
                }
            }
            self.transform = CGAffineTransformIdentity;
            if(self.currentKeyWindow.rootViewController.view){
                self.currentKeyWindow.rootViewController.backgroundView.alpha = 1;
            }
        } completion:^(BOOL finished) {
            if(completion){
                completion();
            }
        }];
    } else {
        if(completion) {
            completion();
        }
    }
}

- (void)hideWithAnimation:(BOOL)animated completion:(dispatch_block_t)completion {
    [[AlertViewQueue sharedQueue] remove:self];
    self.visible = NO;
    
    // remove the cropped area.
    self.currentKeyWindow.rootViewController.backgroundView.cropSize = CGSizeZero;
    
    if(animated){
        [AlertViewQueue sharedQueue].animating = YES;
        NSTimeInterval _duration = kDefaultAnimationDuration;
        if(self.customViewVisible){
            if(self.customViewPresentationStyle==Default){
                
            }
            else if(self.customViewPresentationStyle==MoveUp){
                _duration = 0.35;
            }
            else if (self.customViewPresentationStyle==MoveDown){
                _duration = 0.35;
            }
        } else {
            [self disableBlurEffect];
        }
        
        [UIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if(self.customViewVisible){
                if(self.customViewPresentationStyle==Default){
                    self.alpha = 0;
                    self.transform = CGAffineTransformMakeScale(0.75,0.75);
                }
                else if(self.customViewPresentationStyle==MoveUp){
                    self.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
                }
                else if (self.customViewPresentationStyle==MoveDown){
                    self.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
                }
            }
            else{
                self.alpha = 0;
                self.transform = CGAffineTransformMakeScale(0.8,0.8);
            }
            if(self.currentKeyWindow.rootViewController.view){
                self.currentKeyWindow.rootViewController.backgroundView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            [AlertViewQueue sharedQueue].animating = NO;
            [AlertViewQueue sharedQueue].currentAlertView = nil;
            if(completion){
                completion();
            }
        }];
    } else {
        self.alpha = 0;
        [AlertViewQueue sharedQueue].animating = NO;
        [AlertViewQueue sharedQueue].currentAlertView = nil;
        if(completion){
            completion();
        }
    }
}

#pragma mark - Show & dismiss

- (void)show {
    if(_buttons.count==0 && !self.customViewVisible){
        [self addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:AlertActionStyleCancel handler:^(AlertView *alertView, AlertButtonItem *buttonItem) {
            [alertView dismiss];
        }];
    }
    
    if(![[AlertViewQueue sharedQueue] contains:self]){
        [[AlertViewQueue sharedQueue] enqueue:self];
    }
    
    if([AlertViewQueue sharedQueue].isAnimating){
        return;
    }
    
    if(self.isVisible){
        return;
    }
    
    if([AlertViewQueue sharedQueue].currentAlertView.isVisible){
        return;
    }
    
    self.visible = YES;
    [AlertViewQueue sharedQueue].currentAlertView = self;
    [AlertViewQueue sharedQueue].animating = YES;
    
    self.lastKeyWindow = [UIApplication sharedApplication].keyWindow;
    AlertViewController *viewController = [[AlertViewController alloc] initWithNibName:nil bundle:nil];
    viewController.alertView = self;
    if ([self.lastKeyWindow.rootViewController respondsToSelector:@selector(prefersStatusBarHidden)]) {
        // Little tips, if view controller has 'launch', ignore prefersStatusBarHidden
        NSString *tips = NSStringFromClass(self.lastKeyWindow.rootViewController.class);
        if ([tips contains:@"Launch"] || [tips contains:@"launch"]) {
            // do nothing
        } else {
            viewController.rootViewControllerPrefersStatusBarHidden = self.lastKeyWindow.rootViewController.prefersStatusBarHidden;
            viewController.rootViewControllerPreferredStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        }
    }
    if (!self.currentKeyWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        self.currentKeyWindow = window;
    }
    self.currentKeyWindow.frame = [UIScreen mainScreen].bounds;
    [self.currentKeyWindow makeKeyAndVisible];
    
    // Fix UI issue that the size of alert is less than the size of the cropped area.
    dispatch_block_t refreshUI = ^{
        [self updateUILayouts];
        self.currentKeyWindow.rootViewController.backgroundView.cropSize = self.intrinsicContentSize;
    };
    
    refreshUI();
    
    [self showWithAnimation:YES completion:^{
        
        refreshUI();
        
        [AlertViewQueue sharedQueue].animating = NO;
        
        [self applyBlurEffect];
        
    }];
}

- (void)dismiss {
    [self hideWithAnimation:YES completion:^{
        
        [self removeFromSuperview];
        self.currentKeyWindow.hidden = YES;
        self.currentKeyWindow.rootViewController = nil;
        
        [self.currentKeyWindow removeFromSuperview];
        self.currentKeyWindow = nil;
        
        AlertView *nextAlertView = [[AlertViewQueue sharedQueue] dequeue];
        if(nextAlertView){
            [nextAlertView show];
        }
    }];
    
    [self.lastKeyWindow makeKeyAndVisible];
    self.lastKeyWindow.hidden = NO;
}

#pragma mark - AlertView (Appearance)

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if(_contentView){
        _contentView.titleLabel.textColor = _titleColor;
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if(_contentView){
        _contentView.titleLabel.font = _titleFont;
        
        [_contentView setNeedsUpdateConstraints];
        [_contentView invalidateIntrinsicContentSize];
    }
    [self setNeedsUpdateConstraints];
    [self invalidateIntrinsicContentSize];
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    if(_contentView){
        _contentView.messageLabel.textColor = _messageColor;
    }
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    if(_contentView){
        _contentView.messageLabel.font = _messageFont;
        
        [_contentView setNeedsUpdateConstraints];
        [_contentView invalidateIntrinsicContentSize];
    }
    [self setNeedsUpdateConstraints];
    [self invalidateIntrinsicContentSize];
}

@end

#pragma mark - AlertContentView impl

@implementation AlertContentView {
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    NSMutableArray *_constraints;
    BOOL needResize;
    CGSize contentSize;
    
    BOOL _useAttributedMessage;
    BOOL _useAttributedTitle;
}

@synthesize titleLabel=_titleLabel;
@synthesize messageLabel=_messageLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        self.blurEnabled = [AlertContentView canBlur];
        
        _constraints = @[].mutableCopy;
        _preferredFrameSize = CGSizeZero;
        
        _useAttributedMessage = NO;
        _useAttributedTitle = NO;
    }
    
    return self;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [AlertView appearance].titleFont?:[UIFont boldSystemFontOfSize:17.0f];
        [self addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if(!_messageLabel){
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [AlertView appearance].messageFont?:[UIFont systemFontOfSize:15.0f];
        [self addSubview:_messageLabel];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_messageLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    }
    return _messageLabel;
}

- (void)setTitle:(NSString *)title message:(NSString *)message {
    _useAttributedMessage = NO;
    _useAttributedTitle = NO;
    
    if(![self.titleLabel.text isEqualToString:title] ||
       ![self.messageLabel.text isEqualToString:message]) {
        needResize = YES;
    }
    
    if(is_string_empty(title)) {
        if(is_string_present(message)){
            self.titleLabel.text = message;
            self.titleLabel.textColor = [AlertView appearance].messageColor ? [AlertView appearance].messageColor : [UIColor blackColor];
        }
    } else {
        self.titleLabel.text = title;
        self.titleLabel.textColor = [AlertView appearance].messageColor ? [AlertView appearance].messageColor : [UIColor blackColor];
        
        self.messageLabel.text = message;
        self.messageLabel.textColor = [AlertView appearance].messageColor ? [AlertView appearance].messageColor : [UIColor blackColor];
    }
    
    [self setNeedsUpdateConstraints];
    
    [self invalidateIntrinsicContentSize];
}

- (void)setTitle:(NSString *)title attributedMessage:(NSAttributedString *)message {
    _useAttributedMessage = YES;
    
    if(![self.titleLabel.text isEqualToString:title] ||
       ![self.messageLabel.text isEqualToString:message.string]) {
        needResize = YES;
    }
    
    if(is_string_empty(title)) {
        if(is_string_present(message)){
            _useAttributedTitle = YES;
            
            self.titleLabel.attributedText = message;
            self.titleLabel.textColor = [AlertView appearance].messageColor ? [AlertView appearance].messageColor : [UIColor blackColor];
        }
    } else {
        _useAttributedTitle = NO;
        
        self.titleLabel.text = title;
        self.titleLabel.textColor = [AlertView appearance].messageColor ? [AlertView appearance].messageColor : [UIColor blackColor];
        
        self.messageLabel.attributedText = message;
        self.messageLabel.textColor = [AlertView appearance].messageColor ? [AlertView appearance].messageColor : [UIColor blackColor];
    }
    
    [self setNeedsUpdateConstraints];
    
    [self invalidateIntrinsicContentSize];
}

- (BOOL)isCustomContentView {
    return !CGSizeEqualToSize(self.preferredFrameSize, CGSizeZero);
}

- (CGSize)intrinsicContentSize {
    if([self isCustomContentView]){
        return [super intrinsicContentSize];
    }
    
    return [self getFitSize];
}

// 判断message是否用了attributedString
- (CGSize)getFitSize {
    if(!needResize){
        return contentSize;
    }
    
    CGFloat resHeight = 0;
    CGSize aSize;
    CGFloat preferredTextWidth = kDefaultContainerWidth-self.contentInsets.left-self.contentInsets.right;
    
    NSString *titleString = nil;
    NSString *messageString = nil;
    
    if (_useAttributedTitle) {
        titleString = self.titleLabel.attributedText.string;
    } else {
        titleString = self.titleLabel.text;
    }
    
    if (_useAttributedMessage) {
        messageString = self.messageLabel.attributedText.string;
    } else {
        messageString = self.messageLabel.text;
    }
    
    if(is_string_present(titleString)) {
        aSize = SIZE_LABEL(titleString, self.titleLabel.font, CGSizeMake(preferredTextWidth, MAXFLOAT));
        resHeight += aSize.height;
    }
    
    if(is_string_present(messageString)) {
        aSize = SIZE_LABEL(messageString, self.messageLabel.font, CGSizeMake(preferredTextWidth, MAXFLOAT));
        if(aSize.height>kMaxMessageHeight){
            aSize.height = kMaxMessageHeight;
        }
        resHeight += aSize.height;
    }
    
    
    if(is_string_present(titleString) && is_string_present(messageString)) {
        resHeight += kTitleMessageSpace;
    }
    
    resHeight += self.contentInsets.top + self.contentInsets.bottom;
    
    if(resHeight < kAlertContentViewMinHeight) {
        resHeight = kAlertContentViewMinHeight;
    }
    // The resHeight must be rounded, or else it may cause UI issue.
    contentSize = CGSizeMake(kDefaultContainerWidth, round(resHeight));
    
    return contentSize;
}

- (void)setNeedsUpdateConstraints {
    if([self isCustomContentView]) {
        return [super setNeedsUpdateConstraints];
    }
    
    if(_constraints.count > 0) {
        [self removeConstraints:_constraints];
    }
    
    [_constraints removeAllObjects];
    
    [super setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if([self isCustomContentView]) {
        return [super updateConstraints];
    }
    
    if (_constraints.count > 0) {
        [super updateConstraints];
        return;
    }
    
    NSString *titleString = nil;
    NSString *messageString = nil;
    
    if (_useAttributedTitle) {
        titleString = self.titleLabel.attributedText.string;
    } else {
        titleString = self.titleLabel.text;
    }
    
    if (_useAttributedMessage) {
        messageString = self.messageLabel.attributedText.string;
    } else {
        messageString = self.messageLabel.text;
    }
    
    if(is_string_present(titleString)) {
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1
                                                              constant:self.contentInsets.left]];
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:-self.contentInsets.right]];
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:self.contentInsets.top]];
        
        if(_messageLabel.text.length>0){
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:-kTitleMessageSpace]];
        } else {
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:-self.contentInsets.bottom]];
        }
    }
    
    if(is_string_present(messageString)) {
        if(is_string_present(titleString)) {
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:kTitleMessageSpace]];
        } else {
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:self.contentInsets.top]];
        }
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1
                                                              constant:self.contentInsets.left]];
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:-self.contentInsets.right]];
        
        CGFloat preferredTextWidth = kDefaultContainerWidth-self.contentInsets.left-self.contentInsets.right;
        CGSize aSize = SIZE_LABEL(_messageLabel.text, _messageLabel.font, CGSizeMake(preferredTextWidth, MAXFLOAT));
        if(aSize.height > kMaxMessageHeight){
            aSize.height = kMaxMessageHeight;
        }
        
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:aSize.height]];
    }
    
    [self addConstraints:_constraints];
    [super updateConstraints];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BlurSupportedBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareViews];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self prepareViews];
    }
    return self;
}

- (void)prepareViews {
    self.backgroundColor = [UIColor whiteColor];
    
    _blurEnabled = YES;
    
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.alpha = 1;
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backgroundView];
    }
}

+ (BOOL)canBlur {
    id class = NSClassFromString(@"UIVisualEffectView");
    return class ? YES:NO;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    _blurView.frame = self.bounds;
#endif
    _backgroundView.frame = self.bounds;
}

- (void)setBlurEnabled:(BOOL)enabled {
    _blurEnabled = enabled;
    if(_backgroundView) {
        _backgroundView.alpha = _blurEnabled?0.00:0.98;
    }
}

- (void)applyBlurEffect {
    self.backgroundColor = [UIColor clearColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(!_blurView){
        _blurView = [[UIVisualEffectView alloc] initWithFrame:self.bounds];
        _blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        [self addSubview:_blurView];
        [self sendSubviewToBack:_blurView];
    }
#endif
    self.blurEnabled = [[self class] canBlur];
}

- (void)disableBlurEffect {
    _backgroundView.alpha = 0.98;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(_blurView){
        [_blurView removeFromSuperview];
        _blurView = nil;
    }
#endif
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AlertButtonItem

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        _backgroundView = [[BlurSupportedBackgroundView alloc] initWithFrame:self.bounds];
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];
        _backgroundView.blurEnabled = [BlurSupportedBackgroundView canBlur];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if(highlighted) {
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:0.65];
        _backgroundView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    } else {
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    }
}

- (void)touchUpInside:(UIButton *)btn {
    if(_actionHanlder){
        _actionHanlder(self.alertView, self);
    }
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.backgroundView.cropSize = self.alertView.intrinsicContentSize;
    [self.view insertSubview:self.alertView aboveSubview:self.backgroundView];
    
    self.alertView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.alertView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.alertView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return _rootViewControllerPrefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _rootViewControllerPreferredStatusBarStyle;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AlertViewQueue {
    NSMutableArray *_allAlerts;
}

+ (instancetype)sharedQueue {
    static AlertViewQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlertViewQueue alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if(self=[super init]){
        _allAlerts = @[].mutableCopy;
    }
    return self;
}

- (BOOL)contains:(AlertView *)alertView
{
    return [_allAlerts containsObject:alertView];
}

- (AlertView *)dequeue
{
    if(_allAlerts.count>0){
        return [_allAlerts firstObject];
    }
    return nil;
}

- (void)enqueue:(AlertView *)alertView
{
    [_allAlerts addObject:alertView];
}

- (void)remove:(AlertView *)alertView
{
    if(_allAlerts.count>0){
        if([self contains:alertView]){
            [_allAlerts removeObject:alertView];
        }
    }
}

@end

@implementation AlertView (Creations)

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    AlertView *alert = [[AlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];
    return alert;
}

+ (instancetype)alertWithCustomView:(UIView *)customView
              withPresentationStyle:(CustomViewPresentationStyle)style
{
    AlertView *alert = [[AlertView alloc] initWithCustomView:customView withPresentationStyle:style];
    [alert show];
    return alert;
}

@end
