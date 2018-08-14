//
//  ALSports.h
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_MidwareConfig.h"

#import "_NetworkProtocol.h"
#import "_BrowserProtocol.h"
#import "_ImageLoaderProtocol.h"
#import "_CacheProtocol.h"
#import "_UserProtocol.h"
#import "_SegueProtocol.h"
#import "_LogProtocol.h"
#import "_SharesProtocol.h"
#import "_PaysProtocol.h"
#import "_AppContextProtocol.h"
#import "_DependencyProtocol.h"
#import "_EncryptionProtocol.h"
#import "_AppConfigProtocol.h"
#import "ALSErrorImpl.h"

#import "_Foundation.h"

@interface _Midware : NSObject

@singleton( _Midware )

// 应用状态
@property (nonatomic, strong) id<_AppContextProtocol> context;
@property (nonatomic, strong) id<_AppConfigProtocol> config;

// 业务数据对象
@property (nonatomic, strong) id<_UserProtocol> user;

// 通用业务对象
@property (nonatomic, strong) id<_BrowserProtocol> browser;
@property (nonatomic, strong) id<_SegueProtocol> segue;

// 工具对象
@property (nonatomic, strong) id<_LogProtocol> log;
@property (nonatomic, strong) id<_ImageLoaderProtocol> imageLoader;
@property (nonatomic, strong) id<_CacheProtocol> cache;
@property (nonatomic, strong) id<_NetworkProtocol> network;
@property (nonatomic, strong) id<_SharesProtocol> share;
@property (nonatomic, strong) id<_PaysProtocol> pay;
@property (nonatomic, strong) id<_EncryptionProtocol> encrypt;

@property (nonatomic, strong) id<_DependencyProtocol> dependency;

// @property (nonatomic, strong) id<> app; .main .profile .main.appearance .main.business...

// message router
// ui signal router
// js message router
// url router

@end

#define midware [_Midware sharedInstance]

//#import "ALSportsPredefine.h"

