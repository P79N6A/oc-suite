//
//  ALSPayImpl.m
//  NewStructure
//
//  Created by 7 on 26/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALSPayImpl.h"

@implementation ALSPayImpl
@synthesize isBusy;
@synthesize param;
@synthesize config;

- (void)payWithSuccess:(void (^)(void))successHandler failure:(void (^)(NSError *))failureHandler {
#if __has_ALSPayment
    ALSFument *pay = [ALSFument new];
    pay.map = self.param.payload;
    pay.platform = _PaymentPlatformWechat;
    
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
