//
//  ALSPayInAppPurchaseImpl.m
//  Pay-inner
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSPayInAppPurchaseImpl.h"
#import "ALSErrorImpl.h"

#if __has_ALSPayment
#import <ALSInterfaceSdk/ALSTransactionKit.h>
#import "ALSPaymentProtocol.h"
#import <ALSInterfaceSdk/NetHelp.h>
#import "ALSInAppPurchase.h"
#endif

@implementation ALSPayInAppPurchaseImpl

- (void)payWithSuccess:(void (^)(void))successHandler failure:(void (^)(NSError *))failureHandler {
#if __has_ALSPayment
    ALSPayment* pay = [ALSPayment new];
    pay.map = self.param.payload;
    pay.platform = ALSTKPaymentPlatfomIAP;
    
    // @[
    //   @"com.alisports.wesg.flower20",
    //   @"com.alisports.wesg.flower80",
    //   @"com.alisports.wesg.flower100"
    //  ];
    
    pay.products = self.param.products;
    pay.paymentInfo = self.param.paymentInfo;

    // 1. code 为6打头：6+交易中心返回的error code
    [ALS_PAYMENT_IAP startPayment:pay callback:^(ENUMPayCode code, NSString *resultStr, NSError *error) {
        
        INFO(@"[iap pay]code = %@, result = %@, error = %@", @(code), resultStr, error);
        
        on_main(^{
            if (code != 0) {
                
                NSError *error_ = error;
                
                error_ = error_ ? error_ : [NSError withCode:(int64_t)code message:resultStr];
                
                if (failureHandler) failureHandler(error);
            } else {
                if (successHandler) successHandler();
            }
        })
    }];
    
#endif
}

- (BOOL)available {
#if __has_ALSPayment
    return [ALSRMStore canMakePayments];
#else
    return NO;
#endif
}

////////////
- (void)queryProducts:(NSArray *)products success:(void(^)(NSArray *products, NSArray *invalidProductIdentifiers))successHandler failure:(void (^)(NSError *error))failureHandler {
#if __has_ALSPayment
    NSSet *productset = [NSSet setWithArray:products];
    
    [ALS_PAYMENT_IAP
     requestProducts:productset
     success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
         if (successHandler) successHandler(products, invalidProductIdentifiers);
     }
     
     failure:^(NSError *error) {
        if (failureHandler) failureHandler(error);
     }];
#endif
}

- (SKProduct *)productForId:(NSString *)productID {
#if __has_ALSPayment
    return [[ALSRMStore defaultStore] productForIdentifier:productID];
#else
    return nil;
#endif
}

- (NSString *)localizedPriceOfProduct:(SKProduct *)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.locale = product.priceLocale;
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    return formattedString;
}

- (void)carryOnUnfinishedVerify {
#if __has_ALSPayment
    [ALS_PAYMENT_IAP carryOnUnfinishedVerify:^(ENUMPayCode Code, NSString *resultStr, NSError *error) {
        
    }];
#endif
}

@end
