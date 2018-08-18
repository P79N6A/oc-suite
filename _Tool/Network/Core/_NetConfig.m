//
//  _net_config.m
//  component
//
//  Created by fallen.ink on 4/22/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_greats.h"
#import "_net_config.h"
#import "_model.h"
#import "_net_request.h"

// 需求 1：在实际业务中，我们的测试人员需要切换不同的服务器地址来测试。统一设置服务器地址到 YTKNetworkConfig 类中，也便于我们统一切换服务器地址。
// 如果有 需求 1， 则该对象比较方便

@implementation _NetConfig {
    NSMutableArray *_urlFilters;
}

#pragma mark - Private method

- (instancetype)init {
    if (self = [super init]) {
        _urlFilters = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Public method

+ (instancetype)instance {
    return [self defaultConfig];
}

+ (instancetype)defaultConfig {
    _NetConfig *config = [_NetConfig new];
    
    config.timeoutInterval = 60; // 亲测有效，和http://zhidao.baidu.com/link?url=RkLl_WD6h_hfDrTzROh-yHrHCDADrLC6UqxtCCosy2PhLLRDjgN8QuK9IH1raLQ889i2-rZce_gqWx7f1Nkbtx2dHPm9szGFG-_g_q2ViC7说的不同
    config.retryCount = 3;
    config.securityPolicy = [AFSecurityPolicy defaultPolicy];
    
    config.dataEncoding = NSUTF8StringEncoding;
    
    config.reachableMonitorHostname = @"www.baidu.com";
    config.reachableMonitorTimeout = 5.f;
    config.reachableMonitorInterval = 2.f;
    
    return config;
}

- (void)addUrlFilter:(id<_UrlArgumentsFilterProtocol>)filter {
    [_urlFilters addObject:filter];
}

- (NSArray *)urlFilters {
    return [_urlFilters copy];
}

@end

#pragma mark - Url helper

@implementation _NetConfig ( HttpHelper )

- (NSString *)buildRequestUrlWithNetModelProtocol:(id<_NetModelProtocol>)prot {
    NSString *url = [prot buildUrl];
    
    if (!is_string_empty(url)) { // Case client itself build the whole url.
        return url;
    }
    
    url = [prot requestUrl];
    
    if ([url hasPrefix:@"http"]) {
        return url;
    }
    
    // filter url
    NSArray *filters = [self urlFilters];
    for (id<_UrlArgumentsFilterProtocol> f in filters) {
        url = [f filterUrl:url];
    }
    
    NSString *baseUrl;
    if (is_method_implemented(prot, useCDN) && [prot useCDN]) {
        if ([prot cdnUrl].length > 0) {
            baseUrl = [prot cdnUrl];
        } else {
            baseUrl = [self cdnUrl];
        }
    } else {
        if (is_method_implemented(prot, baseUrl) && [prot baseUrl].length > 0) {
            baseUrl = [prot baseUrl];
        } else {
            baseUrl = [self baseUrl];
        }
    }
    
    ASSERT(baseUrl)
    
    LOG(@"baseUrl = %@, detailUrl = %@", baseUrl, url);
    
    return [NSString stringWithFormat:@"%@%@", baseUrl, url];
}

@end
