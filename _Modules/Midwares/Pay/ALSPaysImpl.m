//
//  ALSPaysImpl.m
//  NewStructure
//
//  Created by 7 on 26/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALSPaysImpl.h"

@interface ALSPaysImpl ()
#if __has_ALSPayment
<ALSThirdPartyPaymentInitDelegate>
#endif

@end

@implementation ALSPaysImpl

@synthesize wechat;
@synthesize alipay;
@synthesize iap;

@synthesize debugMode;

// MARK: -

- (instancetype)init {
    if (self = [super init]) {

        self.debugMode = NO;
    }
    
    return self;
}

// MARK: -

- (void)launch {
#if __has_ALSPayment
    
#if DEBUG
    
    [ALSTransactionKit shareManager].isDebug = self.debugMode;
    
#else
    
    [ALSTransactionKit shareManager].isDebug = NO;
    
#endif
    
    [[ALSTransactionKit shareManager] asyncInit:@"" callback:nil];
    
    [ALS_PAYMENT_IAP setInitDelegate:self];
//    [ALS_PAYMENT_WECHAT setInitDelegate:self];
//    [ALS_PAYMENT_ALIPAY setInitDelegate:self];
    
#if DEBUG
    [ALS_PAYMENT_IAP SetMsgCallback:^(ENUMPayCode code, NSString *resultStr, NSError *error) {
        INFO(@"[iap]code = %@, result = %@, error = %@", @(code), resultStr, error);
    }];
#endif
#endif
}

// MARK: -

- (BOOL)handleOpenURL:(NSURL *)url {
    BOOL result = YES;
    
#if __has_ALSPayment
    if ([url.host isEqualToString:@"pay"])
        result = [ALS_PAYMENT_WECHAT handleThirdPartyPaymentCallback:url];
    else
        result = [ALS_PAYMENT_ALIFU handleThirdPartyPaymentCallback:url];
#endif
    
    return result;
}

////////
- (NSDictionary *)signedDictBy:(NSDictionary *)param key:(NSString *)key keyvalue:(NSString *)keyvalue {
#if __has_ALSPayment
    return [NetHelp signedDictionaryForParameter:param key:key keyvalue:keyvalue];
#else
    return nil;
#endif
}

#if __has_ALSPayment

// MARK: - ALSThirdPartyPaymentInitDelegate

- (ALSThirdPartyPaymentInfitInfo *)thirdPartyPaymentInitInfoPlatform:(_PaymentPlatformType)platform {
    ALSThirdPartyPaymentInfitInfo* info = [ALSThirdPartyPaymentInfitInfo new];
    info.platform = platform;
    
    // 写入支付宝字段
    if ( platform == _PaymentPlatformAlipay ) {
        info.appKey = self.alipay.config.key;
        info.appSecret = self.alipay.config.secret;
        info.urlSecheme = self.alipay.config.scheme;
    }
    
    // 微信字段信息
    if ( platform == _PaymentPlatformWechat ) {
        info.appKey = self.wechat.config.key;
        info.appSecret = self.wechat.config.secret;
        info.urlSecheme = self.wechat.config.scheme;
    }
    
    return info;
}

#endif

@end
