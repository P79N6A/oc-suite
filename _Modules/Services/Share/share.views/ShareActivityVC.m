//
//  ShareActivityVC.m
//  component
//
//  Created by  on 15/12/2.
//  Copyright © 2015年 OpenTeam. All rights reserved.
//

#import "ShareActivityVC.h"
#import "CenterAlignView.h"
#import "SNShareService.h"
#import "SNShareLink.h"
#import "SNShareQQ.h"
#import "SNShareEmail.h"
#import "SNShareSms.h"
#import "SNShareSina.h"
#import "SNShareWechat.h"
#import "_building_precompile.h"
#import "_app_appearance.h"
#import "ABShareView.h"
//static const float kTitleIconSpace = 8.0;

@interface ShareActivityVC ()<
    CenterAlignViewDelegate
>

// 分享参数
@property (nonatomic, strong) NSString *objectID;//微博分享使用唯一标识
@property (nonatomic, strong) NSString *sharePhone;//短信分享的电话
@property (nonatomic, strong) NSString *shareEmail;//邮件分享的邮箱
@property (nonatomic, strong) NSString *shareTitle;//分享链接的Title
@property (nonatomic, strong) NSString *shareDetail;//分享链接的description
@property (nonatomic, strong) NSString *shareURL;//分享链接的URL
@property (nonatomic, strong) NSString *shareShortURL; //最终分享的短链接 
@property (nonatomic, strong) UIImage *shareImage;//分享链接的image
@property (nonatomic, strong) NSString *shareFrom;//区别两个端
@property (nonatomic, strong) NSString *viewTitle;//shareView上的Title

@property (nonatomic, strong) UIWindow *originalKeyWindow;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, strong) ShareParamBuilder *paramBuilder;

@end

@implementation ShareActivityVC

@def_singleton( ShareActivityVC )

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}


#pragma mark - Pulbic methods

- (void)shareWithWithParamBuilder:(ShareParamBuilder *)paramBuilder shareViewTitle:(NSString *)title {
    self.paramBuilder   = paramBuilder;
    
    // 沿用
    _shareTitle     = paramBuilder.title;
    _shareDetail    = paramBuilder.detail;
    _shareURL       = paramBuilder.url;
    _shareImage     = paramBuilder.image;
    _objectID       = paramBuilder.objectId;
    _viewTitle      = title;
    
    self.viewTitle      = title;

    ABShareView *shareView = [[ABShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:shareView];
    shareView.clickBlock = ^(NSString *title) {
        [self didClickOnCenterAlignViewTitle:title];
    };
//    [self showSharePopup];
}

- (void)showSharePopup {
    static BOOL isInAnimation = NO;
    
    if (isInAnimation) {
        return;
    }
    
    isInAnimation = YES;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }

    self.originalKeyWindow = [UIApplication sharedApplication].keyWindow;
    [ShareActivityVC sharedInstance].statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.window.rootViewController = [ShareActivityVC sharedInstance];
    [ShareActivityVC sharedInstance].view.alpha = 1;
    self.window.hidden = NO;
    [self.window makeKeyAndVisible];
}

- (void)dismissSharePopup {
    self.shareTitle = nil;
    self.shareShortURL = nil;
    self.shareDetail = nil;
    self.shareImage = nil;
    self.shareURL = nil;
    
    if (self.window.rootViewController.presentedViewController) {
        [self.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
            self.window.rootViewController = nil;
            self.window.hidden = YES;
            [self.window resignKeyWindow];
            [self.originalKeyWindow makeKeyAndVisible];
            self.window = nil;
            self.view.alpha = 1;
        }];
    } else {
        self.window.rootViewController = nil;
        self.window.hidden = YES;
        [self.window resignKeyWindow];
        [self.originalKeyWindow makeKeyAndVisible];
        self.window = nil;
        self.view.alpha = 1;
    }
}

#pragma mark - Getters & Setters

- (UIWindow *)window {
    if (!_window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.windowLevel = UIWindowLevelNormal + 5;
    }
    
    return _window;
}

#pragma mark - IBActions


- (void)didClickOnCenterAlignViewTitle:(NSString *)title {
    void (^shareEventHandle)(void) = ^{
        if ([title isEqualToString:@"微信"]) {
            self.paramBuilder.type = SNShareWechat_Friends;
            
            [[SNShareService sharedInstance].wechat share:self.paramBuilder onViewController:self];
            
             [self dismissSharePopup];
        } else if ([title isEqualToString:@"朋友圈"]) {
            self.paramBuilder.type = SNShareWechat_CircleFriends;
            
            [[SNShareService sharedInstance].wechat share:self.paramBuilder onViewController:self];
            
            [self dismissSharePopup];
        } else if ([title isEqualToString:@"QQ好友"]) {
            self.paramBuilder.type = SNShareQQ_Friends;
            
            [[SNShareService sharedInstance].qq share:self.paramBuilder onViewController:self];
            
            [self dismissSharePopup];
        } else if ([title isEqualToString:@"QQ空间"]) {
            self.paramBuilder.type = SNShareQQ_Zone;
           
            [[SNShareService sharedInstance].qq share:self.paramBuilder onViewController:self];
            
            [self dismissSharePopup];
        } else if ([title isEqualToString:@"新浪微博"]) {
            [self sendSinaWeiBoMessage];
            
        } else if ([title isEqualToString:@"短信"]) {
            [self sendSMS];
            
        } else if ([title isEqualToString:@"邮件"]) {
            [self sendEmail];
            
        } else if ([title isEqualToString:@"复制链接"]) {
            [self pasteboardCopy];
            
        }
    };
    
    shareEventHandle();
}

#pragma mark - 新浪微博

- (void)sendSinaWeiBoMessage {
    [[SNShareService sharedInstance].sina share:self.paramBuilder onViewController:self];
    
    [self dismissSharePopup];
}

#pragma mark - 短信

- (void)sendSMS {
    [[SNShareService sharedInstance].sms share:self.paramBuilder onViewController:self];
    
    [self dismissSharePopup];
}

#pragma mark - 邮件

- (void)sendEmail {
    [[SNShareService sharedInstance].email share:self.paramBuilder onViewController:self];

    [self dismissSharePopup];
}

#pragma mark - 拷贝链接

- (void)pasteboardCopy {
    [[SNShareService sharedInstance].link share:self.paramBuilder onViewController:self];
    
    [self dismissSharePopup];
}

@end
