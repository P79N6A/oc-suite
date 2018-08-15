//
//  AppVersioner.m
//  consumer
//
//  Created by fallen.ink on 18/10/2016.
//
//

#import "_AppVersioner.h"
//#import "_base_net_command.h"
//#import "_building_ui_component.h"
#import "_AppAppearance.h"

/**
 
 // 是否显示更新
 *  IgnoredVersion >= UpdatedVersion : 不显示
 */
static NSString *IgnoredVersionKey = @"IgnoredVersionKey";

#pragma mark -
//{
//    "id": 1,
//    "appName": "发咖",
//    "platform": 1,
//    "versionSerial": 1,
//    "version": "安卓1.0",
//    "comment": "1.XXX 2.XXX",
//    "minVersionSerial": 1,
//    "downloadUrl": "www.faka.com",
//    "createTime": 1476945721000,
//    "status": 1
//}
@interface VersionDetail : NSObject

@property (nonatomic, assign) int32_t id;

@property (nonatomic, strong) NSString *appName;

@property (nonatomic, assign) int32_t platform;

@property (nonatomic, assign) int32_t versionSerial;

@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, assign) int32_t minVersionSerial;

@property (nonatomic, strong) NSString *downloadUrl;

@property (nonatomic, assign) int64_t createTime;

@property (nonatomic, assign) int32_t status;

@end

@implementation VersionDetail


@end

#if 0

@interface VersionRequest : NSObject

@property (nonatomic, strong) NSString *appName; // 哪几个？？

@property (nonatomic, assign) int32_t platform; // 平台(1:android 2:ios)

@end

@implementation VersionRequest

//impl_net_request_sim(@"/extra/version/load-new-version", @"VersionResponse")

@end

@interface VersionResponse : _BaseResponse

@property (nonatomic, strong) VersionDetail *appVersion;

@end

@implementation VersionResponse

impl_embed_class_JSONTransformer(appVersion, VersionDetail)

@end

#endif

#pragma mark -

@implementation AppVersioner

- (void)checkUpdate {
#if 0
    
    VersionRequest *request = [VersionRequest new];
    request.appName = app_identifier;
    request.platform = 2;
    
    TODO("http://blog.csdn.net/fallenink/article/details/53085067，还要check应用商店的version。。")
    
    
    [self requestWith:request success:^(id obj) {
        VersionResponse *response = obj;
        
        if (!response.appVersion) return;
        
        NSURL *downloadUrl = [NSURL URLWithString:response.appVersion.downloadUrl];
        NSString *titleString = [NSString stringWithFormat:@"发现新版本（%@）", response.appVersion.version];
        NSString *commentString = [response.appVersion.comment replaceAll:@"###" with:@"\n"]; // 很特殊
        NSAttributedString *messageString = [[NSAttributedString alloc] initWithString:commentString];
        
        
        // 1. 当前是最新版本
        if (app_version_serial >= response.appVersion.versionSerial) {
            return;
        }
        
        if ([_cache_[IgnoredVersionKey] intValue] >= response.appVersion.versionSerial) {
            return; // 当前版本，被用户忽略了
        }
        
        // 2. 当前是旧版本，但不强制更新
        if (app_version_serial >= response.appVersion.minVersionSerial) {
            AlertView *alertView = [[AlertView alloc] initWithTitle:titleString
                                                             titleColor:font_gray_2
                                                      attributedMessage:messageString
                                                      cancelButtonTitle:nil
                                                 cancelButtonTitleColor:nil];
            
            [alertView addButtonWithTitle:@"以后再说" titleColor:font_gray_2 style:AlertActionStyleCancel handler:^(AlertView *alertView, AlertButtonItem *buttonItem) {
                _cache_[IgnoredVersionKey] = @(response.appVersion.versionSerial);
                
                [alertView dismiss];
            }];
            [alertView addButtonWithTitle:@"立即更新" titleColor:[UIColor blueColor] style:AlertActionStyleDefault handler:^(AlertView *alertView, AlertButtonItem *buttonItem) {
                [[UIApplication sharedApplication] openURL:downloadUrl];
                
                [alertView dismiss];
            }];
            
            [alertView show];
            
            return;
        }
        
        // 3. 当前是旧版本，要强制更新
        if (app_version_serial < response.appVersion.minVersionSerial) {
            if (app_version_serial >= response.appVersion.minVersionSerial) {
                AlertView *alertView = [[AlertView alloc] initWithTitle:titleString
                                                                 titleColor:font_gray_2
                                                          attributedMessage:messageString
                                                          cancelButtonTitle:nil
                                                     cancelButtonTitleColor:nil];
                [alertView addButtonWithTitle:@"取消" titleColor:font_gray_2 style:AlertActionStyleCancel handler:^(AlertView *alertView, AlertButtonItem *buttonItem) {
                    [self exitApplication];
                }];
                [alertView addButtonWithTitle:@"立即更新" titleColor:[UIColor blueColor] style:AlertActionStyleDefault handler:^(AlertView *alertView, AlertButtonItem *buttonItem) {
                    [[UIApplication sharedApplication] openURL:downloadUrl];
                    
                    [alertView dismiss];
                }];
                
                [alertView show];
                
                return;
            }
            return;
        }
        
    } failure:^(NSError *error) {
        
    }];
    
#endif
}

#pragma mark - exit animation

- (void)exitApplication {
    if (self.window) {
        [UIView beginAnimations:@"exitApplication" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.window cache:NO];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        self.window.bounds = CGRectMake(0, 0, 0, 0);
        [UIView commitAnimations];
    }
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
}

+ (int)compareVersion:(NSString *)firstVersion version:(NSString *)secondVersion {
    int result = 0;
    NSArray *firstVersionItems = [firstVersion componentsSeparatedByString:@"."];
    NSArray *secondVersionItems = [secondVersion componentsSeparatedByString:@"."];
    for (int i = 0; i<[firstVersionItems count] || i< [secondVersionItems count]; i++) {
        int firstItem = 0;
        int secondItem = 0;
        if (i<[firstVersionItems count]) {
            firstItem = [[firstVersionItems objectAtIndex:i] intValue];
        }
        if (i<[secondVersionItems count]) {
            secondItem = [[secondVersionItems objectAtIndex:i] intValue];
        }
        
        if (firstItem != secondItem) {
            result = (firstItem<secondItem)?-1:1;
            break;
        }
    }
    
    return result;
}

@end
