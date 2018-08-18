//
//  ALSPaymentInfo.h
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/4.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  enum{
    ALSTKPaymentPlatformAlipay,
    ALSTKPaymentPlatformWechat,
    ALSTKPaymentPlatfomIAP
}ALSTKPaymentPlatform;

@interface ALSThirdPartyPaymentInfitInfo:NSObject
{
    
}

@property ( nonatomic, assign ) ALSTKPaymentPlatform platform;
@property( nonatomic, strong ) NSString* appKey;
@property( nonatomic, strong ) NSString* appSecret;
@property( nonatomic, strong ) NSString* urlSecheme;
@end

/**
 用来实现初支付初始化的回调函数
 */
@protocol ALSThirdPartyPaymentInitDelegate
- (ALSThirdPartyPaymentInfitInfo*)thirdPartyPaymentInitInfoPlatform:(ALSTKPaymentPlatform)platform;
@end
