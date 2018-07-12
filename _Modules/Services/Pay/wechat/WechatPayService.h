//
//  WechatPayService.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "_greats.h"
#import "PayService.h"
#import "WechatPayOrder.h"
#import "WechatPayConfig.h"

@interface WechatPayService : PayService

@singleton( WechatPayService ) // @singleton\prop_instance\error等作为模板

@prop_instance(WechatPayOrder, order)
@prop_instance(WechatPayConfig, config)

#pragma mark - Error

@error( err_WechatSucceed )
@error( err_WechatFailure )
@error( err_WechatCancel )
@error( err_WechatSentFail )
@error( err_WechatAuthDeny )
@error( err_WechatUnsupport )

#pragma mark -

+ (BOOL)supported;

- (BOOL)pay;

- (void)process:(id)data;

@end

#pragma mark - 

@namespace( service, wechatpay, WechatPayService )

