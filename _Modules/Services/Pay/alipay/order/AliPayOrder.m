//
//  AliPayOrder.m
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "AliPayOrder.h"

/**
 *  2016-09-19 19:02:28.865 consumer[43233:587374] -canOpenURL: failed for URL: "alipay://" - error: "(null)"
 *  2016-09-19 19:02:28.882 consumer[43233:587374] -canOpenURL: failed for URL: "cydia://" - error: "(null)"
 *  2016-09-19 19:02:28.883 consumer[43233:587374] -canOpenURL: failed for URL: "safepay://" - error: "(null)"
 *  2016-09-19 19:02:28:429 consumer[43233:587374] Notification 'notification.ComponentPayment.WAITTING'
 *  2016-09-19 19:02:29.018 consumer[43233:587374] -canOpenURL: failed for URL: "cydia://" - error: "(null)"
 *  2016-09-19 19:02:29.019 consumer[43233:587374] -canOpenURL: failed for URL: "safepay://" - error: "(null)"
 
 *  真机测试是OK的
 */

@implementation AliPayOrder

- (NSString *)generate:(NSError *__autoreleasing *)ppError {
    
    *ppError = nil;
    
    return nil;
}

- (void)clear {
    
}

#pragma mark - Error

@def_error_2( err_invalidOrderNumber, 1000, @"Invalid order number!" )
@def_error_2( err_invalidProductName, 1001, @"Invalid product name!" )
@def_error_2( err_failedGenerateOrder, 1002, @"failed to generate order string" )

@end
