//
//  AliPayService.m
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import <AlipaySDK/AlipaySDK.h>

#import "AliPayService.h"

@implementation AliPayService

@def_singleton( AliPayService )

@def_prop_instance(AliPayOrder, order)
@def_prop_instance(AliPayConfig, config)

@def_error( err_AliSucceed, AliPayServiceErrorCodeSucceed, @"支付宝支付成功" )
@def_error( err_AliDealing, AliPayServiceErrorCodeDealing, @"")
@def_error( err_AliFailure, AliPayServiceErrorCodeFailed, @"支付宝支付失败" )
@def_error( err_AliCancel, AliPayServiceErrorCodeCancel, @"支付宝 支付订单取消" )
@def_error( err_AliNetError, AliPayServiceErrorCodeNetError, @"")

- (BOOL)pay {
    //    NSError *error = nil;
    
    NSString *appSchema = [greats.device urlSchemaWithName:@"alipay"];
    if (! appSchema) {
        appSchema = [greats.device urlSchema];
        if (! appSchema) {
            self.errorCode = PayServiceErrorCodeInvalidData;
            self.errorDesc = @"订单数据无效";
            
            [self notifyFailed:self.error];
            
            return NO;
        }
    }
    
    NSError *error = nil;
    NSString *orderString = [[self order] generate:&error];
    if (! orderString) {
        self.errorCode = PayServiceErrorCodeInvalidData;
        self.errorDesc = @"订单数据无效";
        
        [self notifyFailed:self.error];
        
        return NO;
    }
    
    AlipaySDK *sdk = [AlipaySDK defaultService];
    if (! sdk) {
        self.errorCode = PayServiceErrorCodeUninstalled;
        self.errorDesc = @"请先安装支付宝";
        
        [self notifyFailed:self.error];
        
        return NO;
    }
    
    [sdk payOrder:orderString
       fromScheme:appSchema
         callback:^(NSDictionary *resultDic) {
//             TODO("为什么两个都有？？而这里不回调了，新的sdk，搞毛!!")
             [self process:resultDic];
         }];
    
    [self notifyWaiting:@(0)];
    
    return YES;
}

- (void)process:(id)data {
    NSDictionary *resultDict    = data;
    __unused NSString *memo     = [resultDict objectForKey:@"memo"];
    __unused NSString *result   = [resultDict objectForKey:@"result"];
    NSNumber *status            = [resultDict objectForKey:@"resultStatus"];
    
    self.errorCode = [status intValue];
    
    switch ([status intValue]) {
        case AliPayServiceErrorCodeSucceed: {
            self.errorDesc = @"支付宝支付成功";
            
            [self notifySucceed:self];
        }
            break;
            
        case AliPayServiceErrorCodeDealing: {
            self.errorDesc = @"支付订单正在处理中";
            
            [self notifyWaiting:@(50)];
        }
            break;
            
        case AliPayServiceErrorCodeFailed: {
            self.errorDesc = @"支付宝支付失败";
            
            [self notifyFailed:self.error];
        }
            break;
            
        case AliPayServiceErrorCodeCancel: {
            self.errorDesc = @"支付宝 支付订单取消";
            
            [self notifyFailed:self.error];
        }
            break;
            
        case AliPayServiceErrorCodeNetError: {
            self.errorDesc = @"网络连接失败";
            
            [self notifyFailed:self.error];
        }
            
        default: {
            self.errorDesc = @"unknown";
            
            [self notifyFailed:self.error];
        }
            break;
    }
}

#pragma mark - Parse

- (void)parse:(NSURL *)url {
    if (url != nil && [[url host] compare:@"safepay"] == 0) { // AlixPayment result
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url
                                         standbyCallback:^(NSDictionary *resultDic) {
                                             LOG(@"result = %@",resultDic);
                                             // 解析 auth code
                                             NSString *result = resultDic[@"result"];
                                             NSString *authCode = nil;
                                             if (result.length>0) {
                                                 NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                                                 for (NSString *subResult in resultArr) {
                                                     if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                                                         authCode = [subResult substringFromIndex:10];
                                                         break;
                                                     }
                                                 }
                                             }
                                             LOG(@"授权结果 authCode = %@", authCode?:@"");
                                         }];
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      LOG(@"result = %@",resultDic);
                                                      
                                                      [self process:resultDic];
                                                  }];
    }
}

#pragma mark - Property

- (NSError *)error {
    NSError *err    = [NSError errorWithDomain:@"alipay" code:self.errorCode userInfo:@{@"desc":self.errorDesc}];
    
    if ([err is:self.err_AliCancel]) {
        return self.err_Cancel;
    } else if ([err is:self.err_AliSucceed]) {
        return self.err_Succeed;
    } else {
        return self.err_Failure;
    }
}

@end

#pragma mark -

@def_namespace( service, alipay, AliPayService )
