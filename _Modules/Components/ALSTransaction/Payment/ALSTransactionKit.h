//
//  ALSTransactionKit.h
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/4.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSFument.h"
#import "ALSFumentProtocol.h"
#import "ALSThirdPartyPaymentInfitInfo.h"

#define ALS_PAYMENT_WECHAT [[ALSTransactionKit shareManager] getService:_PaymentPlatformWechat]
#define ALS_PAYMENT_ALIFU [[ALSTransactionKit shareManager] getService:_PaymentPlatformAlipay]
#define ALS_PAYMENT_IAP [[ALSTransactionKit shareManager] getService:_PaymentPlatformIAP]
#define ALS_PAYMENT_WEB_FU  [[ALSTransactionKit shareManager] getService:_PaymentPlatformAlipayWeb]

@interface ALSTransactionKit : NSObject

@property ( nonatomic, strong ) id WeChat;
@property ( nonatomic, strong) id AliFu;
@property ( nonatomic, strong) id IAPPay;
@property (nonatomic, strong) id WebFu;


/**
 是否使用调试url 
 */
@property (nonatomic,assign) BOOL isDebug;

+ (instancetype)shareManager;

- (void)asyncInit:(NSString*)appid callback:(ALSFuCompleteCallBack)callback;
- (id)getService:(_PaymentPlatformType)service;
- (void)setService:( id<ALSFumentPlugProtocol> )protocol;

@end
