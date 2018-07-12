//
//  PayService.m
//  consumer
//
//  Created by fallen on 16/8/23.
//
//

#import "_building_precompile.h"
#import "_building_application.h"
#import "PayService.h"

@implementation PayService

@def_singleton( PayService )

@def_error(err_Succeed, PayServiceErrorCodeSucceed, @"订单支付成功")
@def_error(err_Failure, PayServiceErrorCodeFailure, @"订单支付失败")
@def_error(err_Cancel, PayServiceErrorCodeCancel, @"订单支付取消")
@def_error(err_Uninstalled, PayServiceErrorCodeUninstalled, @"指定第三方支付软件未安装正确")

@def_notification( WAITTING )
@def_notification( SUCCEED )
@def_notification( FAILED )

#pragma mark - Supported

+ (BOOL)supported {
    return YES;
}

#pragma mark - State notifier

- (void)notifyWaiting:(NSNumber *)progress {
    [self postNotification:self.WAITTING];
    
    if ( self.waitingHandler ) {
        self.waitingHandler(progress);
        
        self.waitingHandler = nil;
    }
}

- (void)notifySucceed:(id)result {
    [self postNotification:self.SUCCEED];
    
    if ( self.succeedHandler ) {
        self.succeedHandler(result);
        
        self.succeedHandler = nil;
    }
}

- (void)notifyFailed:(NSError *)error {
    [self postNotification:self.FAILED];
    
    if ( self.failedHandler ) {
        self.failedHandler(error);
        
        self.failedHandler = nil;
    }
}

- (void)notifyUnknown {
    [self.class showAlertView:@"注意" message:@"未知错误" cancelButtonName:@"好"];
}

#pragma mark - Declaration

- (BOOL)pay {
    return NO;
}

- (void)process:(id)data {
    
}

#pragma mark -

- (void)parse:(NSURL *)url {
    
}

@end
