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
 * 默认向 midware 注册 实现类，判断framework是否存在，避免代码更新后，新增依赖库导致其他工程编译不通过。
 */
+ (void)onLoad {
    
    /**
     * 网络实现配置
     */
    id<_NetworkServerProtocol> defaultServer = [ALSNetworkServerImpl new];
    id<_NetworkProtocol> network = [ALSNetworkImpl new];
    network.activeServer = defaultServer;
    network.dataField = @"data";
    network.errorCodeField = @"res_code";
    network.errorMessageField = @"res_msg";
    network.extraField = @"task_finished";
    
    /**
     *  序列化器
     */
    network.serialization = [ALSerializationImpl new];
    
    midware.network = network;
    
    /**
     *  图片加载配置
     */
    id<_ImageLoaderProtocol> imageLoader = [ALSImageLoaderImpl new];
    
    midware.imageLoader = imageLoader;
    
    /**
     *  内置浏览器配置
     */
    id<_BrowserConfigureProtocol> browserConfig = [ALSBrowserConfigureImpl new];
    id<_BrowserProtocol> browser = [ALSBrowserImpl new];
    
    browser.config = browserConfig;
    
    midware.browser = browser;
    
    /**
     *  缓存
     */
    id<_CacheProtocol> cache = [ALSCacheImpl new];
    
    midware.cache = cache;
    
    /**
     *  业务 - 用户
     */
    id<_UserProtocol> user = [ALSUserImpl new];
    
    midware.user = user;
    
    /**
     *  场景切换器
     */
    id<_SegueProtocol> segue = [ALSegueImpl new];
    
    midware.segue = segue;
    
    /**
     *  支付模块
     */

    
    /**
     *  日志打印
     */
    id<_LogConfigureProtocol> logConfigure = [ALSLogConfigureImpl new];
    id<_LogProtocol> log = [ALSLogImpl new];
    log.configure = logConfigure;
    
    midware.log = log;
    
    /**
     *  分享模块
     */
    id<_ShareConfigProtocol> wechatShareConfig = [ALShareConfigImpl new];
    id<_ShareConfigProtocol> weiboShareConfig = [ALShareConfigImpl new];
    id<_ShareConfigProtocol> tencentShareConfig = [ALShareConfigImpl new];
    
    id<_ShareProtocol> wechatShare = [ALShareImpl new];
    id<_ShareProtocol> weiboShare = [ALShareImpl new];
    id<_ShareProtocol> tencentShare = [ALShareImpl new];
    
    wechatShare.config = wechatShareConfig;
    wechatShare.platform = _SharePlatformWechatMask;
    
    weiboShare.config = weiboShareConfig;
    weiboShare.platform = _SharePlatformWeiboMask;
    
    tencentShare.config = tencentShareConfig;
    tencentShare.platform = _SharePlatformTencentMask;
    
    id<_SharesProtocol> share = [ALSharesImpl sharedInstance];
    
    share.wechat = wechatShare;
    share.weibo = weiboShare;
    share.tencent = tencentShare;
    
    id<_ShareUtilityProtocol> shareUtility = [ALShareUtilityImpl new];
    
    share.utility = shareUtility;
    
    midware.share = share;
    
    /**
     *  支付模块
     */
    id<_PayConfigProtocol> wechatPayConfig = [ALSPayConfigImpl new];
    id<_PayConfigProtocol> aliPayConfig = [ALSPayConfigImpl new];
    id<_PayConfigProtocol> iapConfig = [ALSPayConfigImpl new];
    
    id<_PayProtocol> wechatPay = [ALSPayImpl new];
    id<_PayProtocol> aliPay = [ALSPayImpl new];
    id<_PayInAppPurchaseProtocol> iapPay = [ALSPayInAppPurchaseImpl new];
    
    wechatPay.config = wechatPayConfig;
    wechatPay.config.platform = _PaymentPlatformWechat;
    wechatPay.param = [ALSPayParamImpl new];
    
    aliPay.config = aliPayConfig;
    aliPay.config.platform = _PaymentPlatformAlipay;
    aliPay.param = [ALSPayParamImpl new];
    
    iapPay.config = iapConfig;
    iapPay.config.platform = _PaymentPlatformIAP;
    iapPay.param = [ALSPayParamImpl new];
    
    id<_PaysProtocol> pay = [ALSPaysImpl new];
    
    pay.wechat = wechatPay;
    pay.alipay = aliPay;
    pay.iap = iapPay;
    
    midware.pay = pay;

    /**
     *  应用状态
     */
    id<_AppContextProtocol> context = [ALSAppContextImpl new];
    
    midware.context = context;
    
    /**
     *  项目依赖
     */
    id<_DependencyProtocol> dependency = [ALSDependencyImpl new];
    
    midware.dependency = dependency;
    
    /**
     * 加解密
     */
    id<_EncryptionProtocol> encryption = [ALSEncryptionImpl new];
    
    midware.encrypt = encryption;
    
    /**
     * 应用配置
     */
    id<_AppConfigProtocol> config = [ALSAppConfigImpl new];
    
    midware.config = config;
    
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
    [network appendString:midware.network ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:network];
    
    // 内置浏览器 模块状态
    NSMutableString *browser = [@"[内置浏览器]" mutableCopy];
    [browser appendString:midware.browser ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:browser];
    
    // 缓存 模块状态
    NSMutableString *cache = [@"[缓存模块]" mutableCopy];
    [cache appendString:midware.cache ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:cache];
    
    // 用户 模块状态
    NSMutableString *user = [@"[用户模块]" mutableCopy];
    [user appendString:midware.user ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:user];
    
    // Segue 模块状态
    NSMutableString *segue = [@"[Segue模块]" mutableCopy];
    [segue appendString:midware.segue ? @"[开启]" : @"[关闭]"];
    
    [desc appendString:@"\n"];
    [desc appendString:segue];
    
    
    // -------- 结束 ---------
    
    [desc appendString:@"\n+-----------------------------+\n"];
    
    return desc;
}

@end
