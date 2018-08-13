//
//  ALSPayImpl.m
//  NewStructure
//
//  Created by 7 on 26/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSPayImpl.h"
#if __has_ALSPayment
#import <ALSInterfaceSdk/ALSTransactionKit.h>
#import "ALSPaymentProtocol.h"
#import <ALSInterfaceSdk/NetHelp.h>
#endif

@implementation ALSPayImpl
@synthesize isBusy;
@synthesize param;
@synthesize config;

- (void)payWithSuccess:(void (^)(void))successHandler failure:(void (^)(NSError *))failureHandler {
#if __has_ALSPayment
    ALSPayment *pay = [ALSPayment new];
    pay.map = self.param.payload;
    pay.platform = ALSTKPaymentPlatformWechat;
    
    [ALS_PAYMENT_WECHAT startPayment:pay callback:^(ENUMPayCode Code, NSString *resultStr, NSError *error) {
        
        if (error) {
            failureHandler(error);
        } else {
            successHandler();
        }
        
    } ];
#endif
}

@end
