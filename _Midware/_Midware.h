//
//  ALSports.h
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSportsMacro.h"
#import "ALSportsConfig.h"
#import "ALSportsManager.h"
#import "ALSNetworkProtocol.h"
#import "ALSBrowserProtocol.h"
#import "ALSImageLoaderProtocol.h"
#import "ALSCacheProtocol.h"
#import "ALSUserProtocol.h"
#import "ALSegueProtocol.h"
#import "ALSLogProtocol.h"
#import "ALSharesProtocol.h"
#import "ALSPaysProtocol.h"
#import "ALSAppContextProtocol.h"
#import "ALSDependencyProtocol.h"
#import "ALSEncryptionProtocol.h"
#import "ALSAppConfigProtocol.h"

#import "_foundation.h"
#import "_i_utility.h"
#import "_i_processor.h"
#import "_i_validator.h"

@interface _Midware : NSObject

@singleton( _Midware )

@property (nonatomic, readonly) ALSportsManager *manager;

// 应用状态
@property (nonatomic, strong) id<ALSAppContextProtocol> context;
@property (nonatomic, strong) id<ALSAppConfigProtocol> config;

// 业务数据对象
@property (nonatomic, strong) id<ALSUserProtocol> user;

// 通用业务对象
@property (nonatomic, strong) id<ALSBrowserProtocol> browser;
@property (nonatomic, strong) id<ALSegueProtocol> segue;

// 工具对象
@property (nonatomic, strong) id<ALSLogProtocol> log;
@property (nonatomic, strong) id<ALSImageLoaderProtocol> imageLoader;
@property (nonatomic, strong) id<ALSCacheProtocol> cache;
@property (nonatomic, strong) id<ALSNetworkProtocol> network;
@property (nonatomic, strong) id<ALSharesProtocol> share;
@property (nonatomic, strong) id<ALSPaysProtocol> pay;
@property (nonatomic, strong) id<ALSEncryptionProtocol> encrypt;

@property (nonatomic, strong) id<ALSDependencyProtocol> dependency;

// @property (nonatomic, strong) id<> app; .main .profile .main.appearance .main.business...

// message router
// ui signal router
// js message router
// url router

//@prop_strong(id<_IApplication>, app)

//@prop_strong(id<_ICache>, cache)
//
//@prop_strong(id<_INetwork>, net)

@prop_strong(id<_IUtility>, util)

//@prop_strong(id<_IDatabase>, db)

@prop_strong(id<_IProcessor>, processor)

@prop_strong(id<_IValidator>, validator)

@end

#define midware [_Midware sharedInstance]

#import "ALSportsPredefine.h"

