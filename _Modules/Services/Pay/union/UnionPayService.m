//
//  UnionPayService.m
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "UnionPayService.h"
#import "UnionPayOrder.h"
#import "UPPayPluginPro.h"

@interface UnionPayService () <UPPayPluginDelegate>

/**
 *  银联结果状态返回用的是，常量字符串，你敢信？-_-#
 */
@nsstring( str_SUCCESS )
@nsstring( str_FAIL )
@nsstring( str_CANCEL )

@end

@implementation UnionPayService

@def_nsstring( str_SUCCESS, @"success" )
@def_nsstring( str_FAIL, @"fail" )
@def_nsstring( str_CANCEL, @"cancel" )

@def_singleton( UnionPayService )

@def_prop_instance( UnionPayOrder, order )

#pragma mark -

- (BOOL)pay {
    /**
     
     提供测试使用卡号、手机号信息(此类信息仅供测试,不会发生正式交易)招商银行预付费卡:卡号:6226 4401 2345 6785密码:111101
     
     */
    
    [UPPayPluginPro startPay:self.order.tn
                        mode:self.order.tnMode
              viewController:self.order.context
                    delegate:self];
    
    return YES;
}

- (void)process:(id)data {
    NSString *result = data;
    
    if ([result is:self.str_SUCCESS]) {
        [self notifySucceed:self.err_Succeed];
    } else if ([result is:self.str_FAIL]) {
        [self notifyFailed:self.err_Failure];
    } else if ([result is:self.str_CANCEL]) {
        [self notifyFailed:self.err_Cancel];
    } else {
        [self notifyUnknown];
    }
}

+ (BOOL)supported {
    return NO;
}

#pragma mark - UPPayPluginDelegate

- (void)UPPayPluginResult:(NSString *)result {
    [main_queue queueBlock:^{
        [self process:result];
    }];
}

@end

#pragma mark -

@def_namespace( service , unionpay, UnionPayService )
