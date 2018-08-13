//
//  ALSPayParamProtocol.h
//  Pay-inner
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import "ALSProtocol.h"

// -------------------------------------------
// Type Definition
// -------------------------------------------

typedef enum : NSUInteger {
    ALSPaymentPlatformAlipay = 0,
    ALSPaymentPlatformWechat,
    ALSPaymentPlatformIAP,
} ALSPaymentPlatformType;

// -------------------------------------------
// Protocol Definition
// -------------------------------------------

@protocol ALSPayParamProtocol <ALSProtocol>

// 通用
@property (nonatomic, strong) id payload;

// 阿里支付
// ...

// 微信支付
// ...

// 应用内支付
@property(nonatomic, strong) NSString *paymentInfo;
@property(nonatomic, strong) NSArray *products; // ipa 用于查询商品
@property(nonatomic, strong) NSString *userid; // 用户标识，可以区分不同用户

@end
