//
//  ALSFumentServiceConformer.m
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/1.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALSFumentServiceConformer.h"
#import "ALSThirdPartyPaymentInfitInfo.h"
#import "ALSTransactionKit.h"
#import "ALSTransactionDef.h"

#if __has_include("ALSPayManager.h")
#define ALS_IAP_MANAGER
#import "ALSPayManager.h"
#endif

#import "NetHelp.h"

@interface ALSFumentServiceConformer()

@property (nonatomic, strong) ALSThirdPartyPaymentInfitInfo* payinfo;
@property (nonatomic, strong) ALSThirdPartyPaymentInfitInfo* weixinInfo;
@property (nonatomic, strong) id<ALSThirdPartyPaymentInitDelegate> thirdPartDelegate;

@end

@implementation ALSFumentServiceConformer

#ifdef ALS_IAP_MANAGER
- (void)setInitDelegate:(id)alsthirdpartypaymentInitDelegate {
    self.thirdPartDelegate = alsthirdpartypaymentInitDelegate;
    // 初始化 支付宝 和 微信
    if ( self.thirdPartDelegate ) {
        {
            self.payinfo = [self.thirdPartDelegate thirdPartyPaymentInitInfoPlatform:_PaymentPlatformAlipay];
            /*
            if ( self.payinfo ){
                NSDictionary* dic = @{  ALI_PAY_NAME: self.payinfo.urlSecheme};
                [ALS_PAY registerPay:dic];
            }*/
        }
        
        {
            self.weixinInfo = [self.thirdPartDelegate thirdPartyPaymentInitInfoPlatform:_PaymentPlatformWechat];
            /*
            if ( self.weixinInfo  ){
                NSDictionary* dic = @{  WEI_XIN: self.weixinInfo.urlSecheme};
                [ALS_PAY registerPay:dic];
            }*/
        }
        
        [[ALSPayManager sharedInstance] registerPay];
    }
}

- (bool)supportPlatform:(_PaymentPlatformType)platform {
    if ( platform == _PaymentPlatformIAP )
        return NO;
    
    if ( platform == _PaymentPlatformWechat )
        return [[ALSPayManager sharedInstance] isAppInstalled:Enum_WEI_XIN];
    
    if ( platform == _PaymentPlatformAlipay )
        return [[ALSPayManager sharedInstance] isAppInstalled:Enum_ALI_PAY];
    
    return NO;
}

- (void)startPayment:(ALSFument*)payment callback:(ALSFuCompleteCallBack)callback {
    if ( nil == payment )
        return;
    
    NSString* url;
    if ( [ALSTransactionKit shareManager].isDebug )
        url = [ALSTransactionDef sharedInstance].payInfoUrlDaily;
    else
        url = [ALSTransactionDef sharedInstance].payInfoUrlProduct;
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:payment.map];
    [dic setObject:@"MOBILE_SDK" forKey:@"platform"];
    
    if ( payment.platform == _PaymentPlatformWechat ) {
        #ifdef ALS_IAP_WX
        
        if ( NO == [WXApi isWXAppInstalled] ) {
            NSInteger retcode = 100000 + 1000;
            callback( (ENUMPayCode)(retcode), @"没有安装微信!", nil );
        } else if (NO == [WXApi isWXAppSupportApi] ) {
            NSInteger retcode = 100000 + 1001;
            callback( (ENUMPayCode)(retcode), @"微信版本不支持!", nil );
        } else {
            [NetHelp post:url RequestParams:dic FinishBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                 if ( connectionError == nil ){
                     NSError* error = nil;
                     NSDictionary *retdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                     
                     NSString *orderMessage = [retdic objectForKey:@"alisp_data"];
                     NSInteger code = [[retdic objectForKey:@"alisp_code"] integerValue];
                     if ( 200 == code ){
                         NSData * data = [orderMessage dataUsingEncoding:NSUTF8StringEncoding];
                         NSDictionary *newDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                         
                         PayReq* req = [[PayReq alloc] init];
                         
                         req.partnerId  = [newDic objectForKey:@"partnerid"];
                         req.prepayId= [newDic objectForKey:@"prepayid"];
                         req.timeStamp = [[newDic objectForKey:@"timestamp"] intValue];
                         req.package = [newDic objectForKey:@"package"];
                         req.nonceStr= [newDic objectForKey:@"noncestr"];
                         req.sign = [newDic objectForKey:@"sign"];
                         
                         [[ALSPayManager sharedInstance] payWithOrderMessage:req callBack:^(FLErrCode errCode, NSString *errStr) {
                             NSInteger retcode = 9998; // 未知错误
                             switch (errCode) {
                                 case FLErrCodeSuccess:
                                     retcode = 0;
                                     break;
                                 case FLErrCodeFailure:
                                     retcode = 200000+1000;
                                 case FLErrCodeCancel:
                                     retcode = 200000+9999;
                                 default:
                                     retcode = 9998;
                                     break;
                             }
                             
                             if ( callback )
                                 callback( (ENUMPayCode)(retcode), errStr, nil );
                             NSLog(@"errCode = %ld,errStr = %@", (long)errCode, errStr);
                         }];
                     }
                     else{
                         if ( callback ){
                             NSString* str = [@"" stringByAppendingFormat:@"%@%ld",@"6",(long)code];
                             NSString *msg = [retdic objectForKey:@"alisp_msg"];
                             NSString *data = [retdic objectForKey:@"alisp_data"];
                            
                             NSError *error = [NSError errorWithDomain:data code:(NSInteger)-1 userInfo:nil];
                             
                             callback( (ENUMPayCode)[str integerValue], msg, error );
                         }
                     }
                 }
                 else{
                     NSLog( @"error:%ld", (long)connectionError.code );
                     if ( callback ){
                         callback( (ENUMPayCode)(connectionError.code), @"net work error....", nil );
                     }
                 }
             }];
        }
       #endif
    }
    else if ( payment.platform == _PaymentPlatformAlipay ){
#ifdef ALS_IAP_PAY
        [NetHelp post:url RequestParams:dic FinishBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
             if ( connectionError == nil ){
                 NSError* error;
                 NSDictionary *retdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                 
                 NSString *orderMessage = [retdic objectForKey:@"alisp_data"];
                 NSInteger code = [[retdic objectForKey:@"alisp_code"] integerValue];
                 if ( 200 == code ){
                     [ALS_PAY payWithOrderMessage:orderMessage callBack:^(FLErrCode errCode, NSString *errStr) {
                         NSInteger retcode = 9998; // 未知错误
                         switch (errCode) {
                             case FLErrCodeSuccess:
                                 retcode = 0;
                                 break;
                             case FLErrCodeFailure:
                                 retcode = 200000+1000;
                             case FLErrCodeCancel:
                                 retcode = 200000+9999;
                             default:
                                 retcode = 9998;
                                 break;
                         }
                         if ( callback )
                             callback( (ENUMPayCode)(retcode), errStr, nil );
                         NSLog(@"errCode = %zd,errStr = %@",errCode,errStr);
                     }];
                 }
                 else{
                     if ( callback ) {
                         // yangzm
                         NSString* str = [@"" stringByAppendingFormat:@"%@%ld",@"6",(long)code];
                         NSString *msg = [retdic objectForKey:@"alisp_msg"];
                         NSString *data = [retdic objectForKey:@"alisp_data"];

                         NSError *error = [NSError errorWithDomain:data code:(NSInteger)-1 userInfo:nil];
        
                         callback( (ENUMPayCode)[str integerValue], msg, error );
                     }
                 }
             } else {
                 if ( callback )
                     callback( (ENUMPayCode)connectionError.code, @"net work error...", connectionError );
                 NSLog( @"error:%ld", (long)connectionError.code );
             }
         }];
#endif
    }
}

/**
 这个要服务器实现才可以返回

 @param orderid <#orderid description#>
 @param callback <#callback description#>
 */
- (void)queryPaymentWithOrderId: (NSString*)orderid  callback:(ALSFuCompleteCallBack)callback {
    if ( callback )
        callback( 0, @"这个要以后服务器实现才可以返回结果", nil );
}

- (BOOL)handleThirdPartyPaymentCallback:(NSURL*)url {
    if ( url )
        return [[ALSPayManager sharedInstance] handleUrl: url];
    
    return NO;
}

- (void)getPaymentInfor:(ALSFument*)payment callback:(ALSFuCompleteCallBack)back {
    
}
#endif

@end
