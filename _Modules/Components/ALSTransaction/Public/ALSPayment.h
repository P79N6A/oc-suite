//
//  ALSPayment.h
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/4.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSThirdPartyPaymentInfitInfo.h"

typedef NS_ENUM(NSInteger,ENUMPayCode){
    PayCodeSuccess=200100, // 成功
    PayCodeFailure, // 失败
    PayCodeCancel, // 取消
    PayquerySuccess, // 查询成功
    PayqueryFailure, // 查询失败
    PayBuySuccess, // 购买apple购买成功,但到服务器的认证还没有运行
    PayBuyFailure, // 购买apple 失败,到服务器的认证还没有运行
    Paydeferred, // deferred 商品状态
    PayLocalVerifySuccess, // 本地认证成功
    PayLocalVerifyFailure, // 本地认证失败
    PayLocalVerifyRefreshSuccess,
    PayLocalVerifyRefreshFailure,
    PayRestoreSuccess,
    PayRestoreFailure,
    PayRemoteVerifySuccess,
    PayRemoteVerifyFailure,
    PayAppleApiSuccess,
    PayAppleApiFailure,
};

typedef void(^ALSPayCompleteCallBack)(ENUMPayCode Code,NSString *resultStr, NSError* error );
typedef void (^IAPProductsRequestSuccessBlock)(NSArray *products, NSArray *invalidIdentifiers);
typedef void (^IAPStoreFailureBlock)(NSError *error);

@interface ALSPayment : NSObject
{
    
}

@property( nonatomic, assign ) ALSTKPaymentPlatform  platform;
@property( nonatomic, strong ) NSString* paymentInfo;
@property( nonatomic, strong) NSDictionary* map;
@property( nonatomic, strong) NSArray * products; // ipa 用于查询商品
@property( nonatomic, strong) NSString* userid; // 用户标识，可以区分不同用户

@end
