//
//  ShareViewController.m
//  KidsTC
//
//  Created by Altair on 11/20/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "ShareViewController.h"
#import "ALSports.h"

@interface ShareViewController ()

@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (weak, nonatomic) IBOutlet UIView *displayBGView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareScrollContentViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *wechatSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *wechatTimeLineButton;
@property (weak, nonatomic) IBOutlet UIButton *weiboButton;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;
@property (weak, nonatomic) IBOutlet UIButton *qzoneButton;
@property (weak, nonatomic) IBOutlet UIButton *canceButton;

@property (weak, nonatomic) IBOutlet UILabel *wechatSessionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *wechatTimeLineTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *weiboTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *qqTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *qzoneTitleLabel;

@property (strong, nonatomic) void (^ successHandler)(void);
@property (strong, nonatomic) void (^ failureHandler)(NSError *);

- (void)resetShareButtonStatus;

- (IBAction)didClickedShareButton:(id)sender;

- (IBAction)didClickedCancelButton:(id)sender;

@end

@implementation ShareViewController

#pragma mark - Initialize

- (instancetype)initWithSuccess:(void (^)(void))successHandler
                        failure:(void (^)(NSError *error))failureHandler {
    self = [super initWithNibName:@"ShareViewController" bundle:nil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        self.successHandler = successHandler;
        self.failureHandler = failureHandler;
    }
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shareScrollContentViewWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width;
    
//    [self.displayBGView setBackgroundColor:[[AUIThemeManager manager] currentTheme].globalBGColor];
    
    [self.tapView setHidden:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedCancelButton:)];
    [self.tapView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self resetShareButtonStatus];
    
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tapView setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.tapView setHidden:YES];
}

#pragma mark Private methods

- (void)resetShareButtonStatus {
    // 微信好友
    self.wechatSessionButton.tag = ALSharePlatformWechatSession;
    if ([sports.share.utility availableForPlatform:ALSharePlatformWechatSession]) {
        [self.wechatSessionButton setEnabled:YES];
        [self.wechatSessionTitleLabel setAlpha:1];
    } else {
        [self.wechatSessionButton setEnabled:NO];
        [self.wechatSessionTitleLabel setAlpha:0.4];
    }

    // 微信朋友圈
    self.wechatTimeLineButton.tag = ALSharePlatformWechatTimeLine;
    if ([sports.share.utility availableForPlatform:ALSharePlatformWechatTimeLine]) {
        [self.wechatTimeLineButton setEnabled:YES];
        [self.wechatTimeLineTitleLabel setAlpha:1];
    } else {
        [self.wechatTimeLineButton setEnabled:NO];
        [self.wechatTimeLineTitleLabel setAlpha:0.4];
    }
    
    // 微博
    self.weiboButton.tag = ALSharePlatformWeiboCommon;
    if ([sports.share.utility availableForPlatform:ALSharePlatformWeiboCommon]) {
        [self.weiboButton setEnabled:YES];
        [self.weiboTitleLabel setAlpha:1];
    } else {
        [self.weiboButton setEnabled:NO];
        [self.weiboTitleLabel setAlpha:0.4];
    }
    
    // QQ好友
    self.qqButton.tag = ALSharePlatformTencentQQ;
    if ([sports.share.utility availableForPlatform:ALSharePlatformTencentQQ]) {
        [self.qqButton setEnabled:YES];
        [self.qqTitleLabel setAlpha:1];
    } else {
        [self.qqButton setEnabled:NO];
        [self.qqTitleLabel setAlpha:0.4];
    }
    
    // QQ空间
    self.qzoneButton.tag = ALSharePlatformTencentQZone;
    if ([sports.share.utility availableForPlatform:ALSharePlatformTencentQZone]) {
        [self.qzoneButton setEnabled:YES];
        [self.qzoneTitleLabel setAlpha:1];
    } else {
        [self.qzoneButton setEnabled:NO];
        [self.qzoneTitleLabel setAlpha:0.4];
    }
}

- (IBAction)didClickedShareButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    ALSharePlatformType type = (ALSharePlatformType)button.tag;

    [self dismissViewControllerAnimated:YES completion:^{

        sports.share.param.type = type;
        
        [sports.share shareSuccess:^{
            
            self.successHandler();
            
//            [[iToast makeText:@"分享成功"] show];
        } failure:^(NSError *error) {
            
            
            self.failureHandler(error);
            
//            NSString *errMsg = [error.userInfo objectForKey:kErrMsgKey];
//            if ([errMsg length] == 0) {
//                errMsg = @"分享失败";
//            }
//            [[iToast makeText:errMsg] show];
        }];
        
//        [self.shareDelegate shareWithType:type success:^(id obj) {
//            [[iToast makeText:@"分享成功"] show];
//        } failure:^(NSError *error) {
//            NSString *errMsg = [error.userInfo objectForKey:kErrMsgKey];
//            if ([errMsg length] == 0) {
//                errMsg = @"分享失败";
//            }
//            [[iToast makeText:errMsg] show];
//        }];
    }];
}

- (IBAction)didClickedCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
