//
//  _HttpRequestManager.h
//  wesg
//
//  Created by Altair on 8/5/16.
//  Copyright © 2016 AliSports. All rights reserved.
//

#import "_Foundation.h"
#import "_HttpRequestConfiguration.h"

extern NSString *const kRequestParamKeyPartner;
extern NSString *const kRequestParamKeyUUID;
extern NSString *const kRequestParamKeyDevice;
extern NSString *const kRequestParamKeyNet;
extern NSString *const kRequestParamKeyScreen;
extern NSString *const kRequestParamKeyOS;
extern NSString *const kRequestParamKeyOSVersion;
extern NSString *const kRequestParamKeyClientVersion;

@interface _HttpRequestManager : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *skey;
@property (nonatomic, strong) NSArray<NSString *> *h5WhiteList;
@property (nonatomic, strong) ObjectBlock shouldLogoutHandler;
@property (nonatomic, strong) ObjectBlock shouldUpdateAppHandler;

@property (nonatomic, strong, readonly) NSDictionary *params;

@singleton( _HttpRequestManager )

//设置请求信息配置
- (void)syncSetupRequestConfiguration;
- (void)asyncSetupRequestConfiguration;

//清空请求信息配置
- (void)resetRequestConfiguration;

//默认请求配置
- (_HttpRequestConfiguration *)commonHttpRequestConfiguration;


- (NSDictionary *)signedDictionaryForParameter:(NSDictionary *)parameter;


@end
