//
//  AliPayService.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "PayService.h"
#import "AliPayOrder.h"
#import "AliPayConfig.h"
#import "AliPayAutoOrder.h"
#import "AliPayManualOrder.h"

typedef NS_ENUM(NSInteger, AliPayServiceErrorCode) {
    // 支付成功
    AliPayServiceErrorCodeSucceed = 9000,
    // 支付订单正在处理中
    AliPayServiceErrorCodeDealing = 8000,
    // 支付失败
    AliPayServiceErrorCodeFailed = 4000,
    // 支付订单被取消
    AliPayServiceErrorCodeCancel = 6001,
    // 网络连接失败
    AliPayServiceErrorCodeNetError = 6002,
};

@interface AliPayService : PayService

@singleton( AliPayService )

/**
 @brief 用户来生成order，使用AliPayAutoOrder或者AliPayManualOrder
 */
@prop_instance(AliPayOrder, order)
@prop_instance(AliPayConfig, config)

#pragma mark - Error

@error( err_AliSucceed )
@error( err_AliDealing )
@error( err_AliFailure )
@error( err_AliCancel )
@error( err_AliNetError )

#pragma mark -

- (BOOL)pay;
- (void)process:(id)data;

- (void)parse:(NSURL *)url;

@end

#pragma mark -

@namespace( service , alipay, AliPayService )
