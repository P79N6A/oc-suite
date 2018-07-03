//
//  ALSPayInAppPurchaseProtocol.h
//  Pay-inner
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ALSPayProtocol.h"

@protocol ALSPayInAppPurchaseProtocol <ALSPayProtocol>

@optional

// products = @[
//              @"com.alisports.wesg.flower20",
//              @"com.alisports.wesg.flower80",
//              @"com.alisports.wesg.flower100"
// ]
- (void)queryProducts:(NSArray *)products success:(void(^)(NSArray *products, NSArray *invalidProductIdentifiers))successHandler failure:(void (^)(NSError *error))failureHandler;

- (SKProduct *)productForId:(NSString *)productID;

- (NSString *)localizedPriceOfProduct:(SKProduct *)product;

- (void)carryOnUnfinishedVerify;

@end
