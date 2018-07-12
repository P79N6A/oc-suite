//
//  ComponentSNShare.h
//  component
//
//  Created by fallen.ink on 4/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <foundation/Foundation.h>
#import "SNShareService_Config.h"
#import "ShareActivityVC.h"
#import "ShareParamBuilder.h"

@class SNShareLink;
@class SNShareQQ;
@class SNShareEmail;
@class SNShareSina;
@class SNShareSms;
@class SNShareWechat;

typedef BOOL (^ SNShareServiceConfigBlock)(SNShareService_Config *config);

@interface SNShareService : NSObject

@singleton( SNShareService )

@prop_instance( SNShareService_Config, wechatConfig )
@prop_instance( SNShareService_Config, qqConfig )
@prop_instance( SNShareService_Config, sinaConfig )
@prop_instance( SNShareService_Config, smsConfig )
@prop_instance( SNShareService_Config, emailConfig )
@prop_instance( SNShareService_Config, linkConfig )

@prop_singleton(SNShareLink, link)
@prop_singleton(SNShareQQ, qq)
@prop_singleton(SNShareEmail, email)
@prop_singleton(SNShareSina, sina)
@prop_singleton(SNShareSms, sms)
@prop_singleton(SNShareWechat, wechat)

#pragma mark - 统一配置接口

/**
 *  Leave config to client, and if handler return BOOL means he donot want.
 */
- (void)wechatConfig:(SNShareServiceConfigBlock)wechatConfigHandler
            qqConfig:(SNShareServiceConfigBlock)qqConfigHandler
          sinaConfig:(SNShareServiceConfigBlock)sinaConfigHandler
           smsConfig:(SNShareServiceConfigBlock)smsConfigHandler
         emailConfig:(SNShareServiceConfigBlock)emailConfigHandler
          linkConfig:(SNShareServiceConfigBlock)linkConfigHandler;

#pragma mark - Can be override

- (void)configure;

- (BOOL)supported;

/**
 *  分享成功
 */
@property (nonatomic, copy) ObjectBlock     succeedHandler;

/**
 *  分享失败
 */
@property (nonatomic, copy) ErrorBlock      failedHandler;

/**
 *  When inherited, this field should be set appropriate.
 */
@property (nonatomic, strong) SNShareService_Config *config;

/**
 *  Share to.
 */
- (BOOL)share:(ShareParamBuilder *)paramBuilder onViewController:(UIViewController *)viewController;

/**
 *  Call when ApplicationDelegate touch application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
    Should not be call as [super parse:url application:application]
 *
 *  @param url         url
 *  @param application application
 */
- (void)parse:(NSURL *)url application:(UIApplication *)application;

@end



