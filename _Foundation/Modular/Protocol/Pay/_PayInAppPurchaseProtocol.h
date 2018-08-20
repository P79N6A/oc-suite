#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "_PayProtocol.h"

@protocol _PayInAppPurchaseProtocol <_PayProtocol>

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
