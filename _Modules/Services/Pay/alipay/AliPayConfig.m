//
//  AliPayConfig.m
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "AliPayConfig.h"

@implementation AliPayConfig

@def_singleton( AliPayConfig )

- (NSString *)showURL {
    return _showURL ? _showURL : @"m.alipay.com";
}

- (NSString *)service {
    return _service ? _service : @"mobile.securitypay.pay";
}

- (NSString *)paymentType {
    return _paymentType ? _paymentType : @"1";
}

- (NSString *)inputCharset {
    return _inputCharset ? _inputCharset : @"utf-8";
}

@end
