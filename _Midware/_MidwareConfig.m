//
//  ALSportsConfig.m
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwareConfig.h"
#import "_MidwarePrecompile.h"
#import "_Midware.h"

#import "ALSNetworkImpl.h"
#import "ALSerializationImpl.h"
#import "ALSImageLoaderImpl.h"
#import "ALSBrowserImpl.h"
#import "ALSCacheImpl.h"
#import "ALSUserImpl.h"
#import "ALSegueImpl.h"
#import "ALSNetworkServerImpl.h"
#import "ALSLogImpl.h"
#import "ALSLogConfigureImpl.h"
#import "ALSBrowserConfigureImpl.h"

#import "ALShareImpl.h"
#import "ALSharesImpl.h"
#import "ALShareParamImpl.h"
#import "ALShareConfigImpl.h"
#import "ALShareUtilityImpl.h"

#import "ALSPayImpl.h"
#import "ALSPaysImpl.h"
#import "ALSPayParamImpl.h"
#import "ALSPayConfigImpl.h"
#import "ALSPayInAppPurchaseImpl.h"

#import "ALSAppContextImpl.h"
#import "ALSDependencyImpl.h"

#import "ALSEncryptionImpl.h"
#import "ALSAppConfigImpl.h"

@implementation _MidwareConfig

/**
 * 默认向 sports 注册 实现类，判断framework是否存在，避免代码更新后，新增依赖库导致其他工程编译不通过。
 */
+ (void)onLoad {
    
    /**
     * 网络实现配置
     */
    id<ALSNetworkServerProtocol> defaultServer = [ALSNetworkServerImpl new];
    id<ALSNetworkProtocol> network = [ALSNetworkImpl new];
    network.activeServer = defaultServer;
    network.dataField = @"data";
    network.errorCodeField = @"res_code";
    network.errorMessageField = @"res_msg";
    network.extraField = @"task_finished";
    
    /**
     *  序列化器
     */
    network.serialization = [ALSerializationImpl new];
    
    sports.network = network;
    
    /**
     *  图片加载配置
     */
    id<ALSImageLoaderProtocol> imageLoader = [ALSImageLoaderImpl new];
    
    sports.imageLoader = imageLoader;
    
    /**
     *  内置浏览器配置
     */
    id<ALSBrowserConfigureProtocol> browserConfig = [ALSBrowserConfigureImpl new];
    id<ALSBrowserProtocol> browser = [ALSBrowserImpl new];
    
    browser.config = browserConfig;
    
    sports.browser = browser;
    
    /**
     *  缓存
     */
    id<ALSCacheProtocol> cache = [ALSCacheImpl new];
    
    sports.cache = cache;
    
    /**
     *  业务 - 用户
     */
    id<ALSUserProtocol> user = [ALSUserImpl new];
    
    sports.user = user;
    
    /**
     *  场景切换器
     */
    id<ALSegueProtocol> segue = [ALSegueImpl new];
    
    sports.segue = segue;
    
    /**
     *  支付模块
     */

    
    /**
     *  日志打印
     */
    id<ALSLogConfigureProtocol> logConfigure = [ALSLogConfigureImpl new];
    id<ALSLogProtocol> log = [ALSLogImpl new];
    log.configure = logConfigure;
    
    sports.log = log;
    
    /**
     *  分享模块
     */
    id<ALShareConfigProtocol> wechatShareConfig = [ALShareConfigImpl new];
    id<ALShareConfigProtocol> weiboShareConfig = [ALShareConfigImpl new];
    id<ALShareConfigProtocol> tencentShareConfig = [ALShareConfigImpl new];
    
    id<ALShareProtocol> wechatShare = [ALShareImpl new];
    id<ALShareProtocol> weiboShare = [ALShareImpl new];
    id<ALShareProtocol> tencentShare = [ALShareImpl new];
    
    wechatShare.config = wechatShareConfig;
    wechatShare.platform = ALSharePlatformWechatMask;
    
    weiboShare.config = weiboShareConfig;
    weiboShare.platform = ALSharePlatformWeiboMask;
    
    tencentShare.config = tencentShareConfig;
    tencentShare.platform = ALSharePlatformTencentMask;
    
    id<ALSharesProtocol> share = [ALSharesImpl sharedInstance];
    
    share.wechat = wechatShare;
    share.weibo = weiboShare;
    share.tencent = tencentShare;
    
    id<ALShareUtilityProtocol> shareUtility = [ALShareUtilityImpl new];
    
    share.utility = shareUtility;
    
    sports.share = share;
    
    /**
     *  支付模块
     */
    id<ALSPayConfigProtocol> wechatPayConfig = [ALSPayConfigImpl new];
    id<ALSPayConfigProtocol> aliPayConfig = [ALSPayConfigImpl new];
    id<ALSPayConfigProtocol> iapConfig = [ALSPayConfigImpl new];
    
    id<ALSPayProtocol> wechatPay = [ALSPayImpl new];
    id<ALSPayProtocol> aliPay = [ALSPayImpl new];
    id<ALSPayInAppPurchaseProtocol> iapPay = [ALSPayInAppPurchaseImpl new];
    
    wechatPay.config = wechatPayConfig;
    wechatPay.config.platform = ALSPaymentPlatformWechat;
    wechatPay.param = [ALSPayParamImpl new];
    
    aliPay.config = aliPayConfig;
    aliPay.config.platform = ALSPaymentPlatformAlipay;
    aliPay.param = [ALSPayParamImpl new];
    
    iapPay.config = iapConfig;
    iapPay.config.platform = ALSPaymentPlatformIAP;
    iapPay.param = [ALSPayParamImpl new];
    
    id<ALSPaysProtocol> pay = [ALSPaysImpl new];
    
    pay.wechat = wechatPay;
    pay.alipay = aliPay;
    pay.iap = iapPay;
    
    sports.pay = pay;

    /**
     *  应用状态
     */
    id<ALSAppContextProtocol> context = [ALSAppContextImpl new];
    
    sports.context = context;
    
    /**
     *  项目依赖
     */
    id<ALSDependencyProtocol> dependency = [ALSDependencyImpl new];
    
    sports.dependency = dependency;
    
    /**
     * 加解密
     */
    id<ALSEncryptionProtocol> encryption = [ALSEncryptionImpl new];
    
    sports.encrypt = encryption;
    
    /**
     * 应用配置
     */
    id<ALSAppConfigProtocol> config = [ALSAppConfigImpl new];
    
    sports.config = config;
    
    /**********************************
     *  打印模块状态
     **********************************/
    INFO(@"%@", [self debugDescription]);
}

+ (NSString *)debugDescription {
    NSMutableString *desc = [@"+-----------------------------+\n" mutableCopy];
    
    // -------- 开始 ---------
    
    // 网络 模块状态
    NSMutableString *network = [@"[网络]" mutableCopy];
    [network appendString:sports.network ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:network];
    
    // 内置浏览器 模块状态
    NSMutableString *browser = [@"[内置浏览器]" mutableCopy];
    [browser appendString:sports.browser ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:browser];
    
    // 缓存 模块状态
    NSMutableString *cache = [@"[缓存模块]" mutableCopy];
    [cache appendString:sports.cache ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:cache];
    
    // 用户 模块状态
    NSMutableString *user = [@"[用户模块]" mutableCopy];
    [user appendString:sports.user ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:user];
    
    // Segue 模块状态
    NSMutableString *segue = [@"[Segue模块]" mutableCopy];
    [segue appendString:sports.segue ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:segue];
    
    
    
    // -------- 结束 ---------
    
    [desc appendString:@"\n+-----------------------------+\n"];
    
    return desc;
}

@end
