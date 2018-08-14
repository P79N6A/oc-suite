//
//  ALSharesImpl.m
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALSharesImpl.h"

@interface ALSharesImpl ()
#if __has_ALSShareService
<ALSSharePlugInitializationProtocol>
#endif

@end

@implementation ALSharesImpl

@synthesize wechat;
@synthesize weibo;
@synthesize tencent;
@synthesize param;
@synthesize utility;
@synthesize afterProcessHandler;

@def_singleton( ALSharesImpl )

// MARK: - NSLaunchableProtocol

+ (void)onLaunch { // 配置
#if __has_ALSShareService
    [[ALSShareService globalService] activateBuiltInPlugs:ALSBuiltInSharePlugStrategyAll withInitializationDelegate:[self sharedInstance] response:nil];
#endif
}

// MARK: -

- (void)shareSuccess:(void (^)(void))successHandler failure:(void (^)(NSError *))failureHandler {
    _SharePlatformType platform = self.param.type;
    
    @weakify(self)
    
    // 成功、失败句柄
    void (^ successHandler_)(void) = ^ {
        @strongify(self)
        
        if (self.afterProcessHandler) {
            self.afterProcessHandler(self.param);
        }
        
        if (successHandler) successHandler();
    };
    
    void (^ failureHandler_)(NSError *) = ^ (NSError *error){
        if (failureHandler) failureHandler(error);
    };
    
    // 分享调用
    if (platform & _SharePlatformWechatMask) {
        [self.wechat shareWithParam:self.param
                            success:successHandler_
                            failure:failureHandler_];
    } else if (platform & _SharePlatformWeiboMask) {
        [self.weibo shareWithParam:self.param
                           success:successHandler_
                           failure:failureHandler_];
    } else if (platform & _SharePlatformTencentMask) {
        [self.tencent shareWithParam:self.param
                             success:successHandler_
                             failure:failureHandler_];
    }
}

// MARK: - ALSSharePlugInitializationProtocol

#if __has_ALSShareService

- (ALSSharePlugInitializationInfo *)sharePlugInitilizationInfoForPlatform:(ALSSharePlatform)platform {
    
    NSAssert(self.weibo.config.key, @"请填写 分享 配置信息");
    NSAssert(self.weibo.config.secret, @"请填写 分享 配置信息");
    NSAssert(self.weibo.config.scheme, @"请填写 分享 配置信息");
    
    NSAssert(self.wechat.config.key, @"请填写 分享 配置信息");
    NSAssert(self.wechat.config.secret, @"请填写 分享 配置信息");
    NSAssert(self.wechat.config.key, @"请填写 分享 配置信息");
    
    NSAssert(self.tencent.config.key, @"请填写 分享 配置信息");
    NSAssert(self.tencent.config.secret, @"请填写 分享 配置信息");
    NSAssert(self.tencent.config.scheme, @"请填写 分享 配置信息");
    
    ALSSharePlugInitializationInfo *info = nil;
    switch (platform) {
        case ALSSharePlatformWeChat: {
            info = [ALSSharePlugInitializationInfo
                    infoWithSharePlatform:platform
                    appKey:self.wechat.config.key
                    appSecret:self.wechat.config.secret
                    urlScheme:self.wechat.config.scheme
                    andRedirectUrl:@""];
        }
            break;
        case ALSSharePlatformWeibo: {
            info = [ALSSharePlugInitializationInfo
                    infoWithSharePlatform:platform
                    appKey:self.weibo.config.key
                    appSecret:self.weibo.config.secret
                    urlScheme:self.weibo.config.scheme
                    andRedirectUrl:self.weibo.config.redirect];
        }
            break;
        case ALSSharePlatformTencent: {
            info = [ALSSharePlugInitializationInfo
                    infoWithSharePlatform:platform
                    appKey:self.tencent.config.key
                    appSecret:self.tencent.config.secret
                    urlScheme:self.tencent.config.scheme
                    andRedirectUrl:@""];
        }
            break;
        default:
            break;
    }
    return info;
}

#endif

@end
