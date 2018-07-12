//
//  WechatPayService.m
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "WechatPayService.h"
#import "WXApi.h"

@interface WechatPayService () <WXApiDelegate>

@end

@implementation WechatPayService

@def_error( err_WechatSucceed, WXSuccess,             @"微信支付成功" )
@def_error( err_WechatFailure, WXErrCodeCommon,       @"微信支付失败" )
@def_error( err_WechatCancel,  WXErrCodeUserCancel,   @"微信支付订单取消" )
@def_error( err_WechatSentFail, WXErrCodeSentFail,    @"微信支付发送失败" )
@def_error( err_WechatAuthDeny, WXErrCodeAuthDeny,    @"微信支付授权失败" )
@def_error( err_WechatUnsupport, WXErrCodeUnsupport,  @"微信支付不支持")

@def_error(err_Uninstalled, PayServiceErrorCodeUninstalled, @"请安装微信客户端")

@def_prop_instance(WechatPayOrder, order)
@def_prop_instance(WechatPayConfig, config)

@def_singleton( WechatPayService )

#pragma mark - Class method

+ (void)load {
    WechatPayService *wechatPay   = [WechatPayService sharedInstance];
    
    (void)wechatPay;
}

#pragma mark -

+ (BOOL)supported {
    return [WXApi isWXAppInstalled];
}

- (BOOL)pay {
    PayReq *request = [PayReq new];
    
    request.partnerId   = self.config.partnerId;
    request.prepayId    = self.order.prepayId;
    request.nonceStr    = self.order.nonceStr;
    request.timeStamp   = self.order.timeStamp;
    request.package     = self.order.package;
    request.sign        = self.order.sign;
    
    if (![WXApi isWXAppInstalled]) {
        self.errorCode = PayServiceErrorCodeUninstalled;
        self.errorDesc = @"请安装微信客户端";
        
        [self handleError:self.err_Uninstalled];
        
        return NO;
    }
    
    [self notifyWaiting:@(50)];
    
    return [WXApi sendReq:request];;
}

- (void)process:(id)data {
    if ([data isKindOfClass:[PayResp class]]) {
        PayResp *response   = data;
        
        self.errorCode  = response.errCode;
        
        switch (response.errCode) {
            case WXSuccess:
            {
                /**
                 *  如果需要，再次打印错误日志，不去基类中打印
                 */
                
                [self notifySucceed:self.err_Succeed];
                
                self.errorDesc  = self.err_WechatSucceed.message;
            }
                break;
                
            case WXErrCodeCommon:
            case WXErrCodeUserCancel:
            case WXErrCodeSentFail:
            case WXErrCodeAuthDeny:
            case WXErrCodeUnsupport:
            {
                [self handleError:[self errorForCode:response.errCode]];
            }
                break;
                
            default:
            {
                [self notifyUnknown];
            }
                break;
        }
    }
}

- (void)parse:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - Private method

- (void)handleError:(NSError *)error {
    /**
     *  如果需要，再次打印错误日志，不去基类中打印
     */
    self.errorCode  = error.code;
    self.errorDesc  = error.message;
    
    
    if ([error is:self.err_WechatCancel]) {
        [self notifyFailed:self.err_Cancel];
    } else if ([error is:self.err_Uninstalled]) {
        
    }
    else {
        [self notifyFailed:self.err_Failure];
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
 * @param resp nil
 */
- (void)onResp:(BaseResp *)resp {
    [self process:resp];
}


@end

#pragma mark - 

@def_namespace( service, wechatpay, WechatPayService )
