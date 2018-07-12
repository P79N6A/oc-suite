//
//  SNShareWechat.m
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_building_precompile.h"
#import "_building_application.h"
#import "_vendor_lumberjack.h"
#import "WechatPayService.h"
#import "SNShareWechat.h"
#import "WXApi.h"
#import "ImageUtil.h"

@interface SNShareWechat () <WXApiDelegate>

@end

@implementation SNShareWechat

@def_singleton( SNShareWechat )

- (void)configure {
    [WXApi registerApp:self.config.appId];
}

- (BOOL)supported {
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi] && self.config.supported;
}

- (BOOL)share:(ShareParamBuilder *)paramBuilder onViewController:(UIViewController *)viewController {
    if (![self supported]) {
        [self showToastWithText:localized(@"分享.当前微信的版本不支持.Toast提示")];
        return NO;
    }
    
    int sceneType = 0;
    switch (paramBuilder.type) {
        case SNShareWechat_Friends: {
            sceneType = WXSceneSession;
        }
            break;
        case SNShareWechat_CircleFriends: {
            sceneType = WXSceneTimeline;
        }
            break;
        default:
            break;
    }
    
    /**
     *  url 有，则是分享链接＋图片；url 无，则是分享图片.
     */
    if (is_string_empty(paramBuilder.url)) {
        WXImageObject *ext = [WXImageObject object];
        ext.imageData  = UIImagePNGRepresentation(paramBuilder.image);
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.mediaObject = ext;
        
        //图片缩略图
        CGFloat width = 240.f;
        CGFloat height = width * paramBuilder.image.size.height / paramBuilder.image.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [paramBuilder.image drawInRect:(CGRectMake(0, 0, width, height))];
        [message setThumbImage:(UIGraphicsGetImageFromCurrentImageContext())];
        UIGraphicsEndImageContext();
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText   = NO;
        req.message = message;
        req.scene   = sceneType;
        
        [WXApi sendReq:req];
        
        return YES;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = paramBuilder.title;
    message.description = paramBuilder.detail;
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = paramBuilder.url;
    message.mediaObject = webObj;
    
    if (paramBuilder.image) {
        message.thumbData = [ImageUtil compressThumbImage:paramBuilder.image];
    }
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    
    req.scene = sceneType;
    req.bText = NO;
    req.message = message;

    BOOL ret = [WXApi sendReq:req];
    if (ret == NO) {
        [self showToastWithText:localized(@"分享.分享失败.Toast提示")];
    }
    
    return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    if ([[url scheme] isEqualToString:self.config.appId]) {
        [WXApi handleOpenURL:url delegate:self];
    }
}

#pragma mark - WXApiDelegate

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq *)req {
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp 具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:SendMessageToWXResp.class])
    { // 分享
        switch (resp.errCode) {
            case WXSuccess:
                DDLogInfo(@"微信分享成功");
                break;
            case WXErrCodeCommon:
                DDLogError(@"微信分享错误：普通错误类型");
                break;
            case WXErrCodeUserCancel:
                DDLogError(@"微信分享错误：用户点击取消并返回");
                break;
            case WXErrCodeSentFail:
                DDLogError(@"微信分享错误：发送失败");
                break;
            case WXErrCodeAuthDeny:
                DDLogError(@"微信分享错误：授权失败");
                break;
            case WXErrCodeUnsupport:
                DDLogError(@"微信分享错误：微信不支持");
                break;
            default:
                break;
        }
    }
}


@end
