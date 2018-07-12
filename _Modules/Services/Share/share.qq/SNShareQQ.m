//
//  SNShareQQ.m
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "SNShareQQ.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "ImageUtil.h"
#import "_building_application.h"
#import "_vendor_lumberjack.h"

@interface  SNShareQQ () <TencentApiInterfaceDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation SNShareQQ

@def_singleton( SNShareQQ )

- (void)configure {
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.config.appId andDelegate:nil];
}

- (BOOL)supported {
    return [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi] && self.config.supported;
}

- (BOOL)share:(ShareParamBuilder *)paramBuilder onViewController:(UIViewController *)viewController {
    if (![self supported]) {
        [self showToastWithText:localized(@"分享.当前QQ的版本不支持.Toast提示")];

        return YES;
    }

    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:paramBuilder.url]
                                                        title:paramBuilder.title
                                                  description:paramBuilder.detail
                                             previewImageData:[ImageUtil compressThumbImage:paramBuilder.image]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    if (paramBuilder.type == SNShareQQ_Friends) {
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    } else {
        [newsObj setCflag: kQQAPICtrlFlagQZoneShareOnStart];
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        [self handleSendResult:sent];
    }
    
    return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    if ([[url scheme] isEqualToString:self.config.appId]) {
        [TencentOAuth HandleOpenURL:url];
    }
}

#pragma mark - QQDelegate

/**
 * 请求获得内容 当前版本只支持第三方相应腾讯业务请求
 */
- (BOOL)onTencentReq:(TencentApiReq *)req {
    return YES;
}

/**
 * 响应请求答复 当前版本只支持腾讯业务相应第三方的请求答复
 */
- (BOOL)onTencentResp:(TencentApiResp *)resp {
    return YES;
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    switch (sendResult) {
        case EQQAPIAPPNOTREGISTED:
        {
            DDLogError(@"QQ分享错误：App未注册");
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            DDLogError(@"QQ分享错误：发送参数错误");
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            DDLogError(@"QQ分享错误：未安装手Q");
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            DDLogError(@"QQ分享错误：API接口不支持");
            break;
        }
        case EQQAPISENDFAILD:
        {
            DDLogError(@"QQ分享错误：发送失败");
            break;
        }
        default:
        {
            break;
        }
    }
}


@end
