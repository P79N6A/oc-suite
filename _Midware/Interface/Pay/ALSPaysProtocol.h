//
//  ALSPaysProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "ALSProtocol.h"
#import "ALSPayProtocol.h"
#import "ALSPayParamProtocol.h"
#import "ALSPayInAppPurchaseProtocol.h"

@protocol ALSPaysProtocol <ALSProtocol>

@property (nonatomic, assign) BOOL debugMode;

@property (nonatomic, strong) id<ALSPayInAppPurchaseProtocol> iap;
@property (nonatomic, strong) id<ALSPayProtocol> alipay;
@property (nonatomic, strong) id<ALSPayProtocol> wechat;

- (void)launch;

//// 最老的版本，最好也写上
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url { return [sports.pay handleOpenURL:url]; }
//// iOS 9.0 之前 会调用
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation { return [sports.pay handleOpenURL:url]; }
//// iOS 9.0 以上（包括iOS9.0）
//- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options { return [sports.pay handleOpenURL:url]; }

- (BOOL)handleOpenURL:(NSURL *)url; // 有可能会挪到 ALSPayProtocol 中

@optional

- (NSDictionary *)signedDictBy:(NSDictionary *)param key:(NSString *)key keyvalue:(NSString *)keyvalue;

@end
