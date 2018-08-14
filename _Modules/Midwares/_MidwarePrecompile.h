//
//  _MidwarePrecompile.h
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

// -------------------------------------------
// 特有预定义
// -------------------------------------------

#ifndef VERBOSE
#   define VERBOSE(format, ...) fprintf(stderr, "class：%s \nline： %d \nmethod：%s \nmessage：%s \n%s \n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__, __func__,[[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String], [@"----------------------------------------------" UTF8String]);
#endif

#ifndef INFO
#   define INFO(format, ...) fprintf(stderr, "%s \n",[[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);
#endif

// -------------------------------------------
// 数据能力
// -------------------------------------------

// AEDataKit
#if __has_include(<AEDataKit/AEDataKit.h>)
#   define __has_AEDataKit 1
#   import <AEDataKit/AEDataKit.h>
#elif __has_include("AEDataKit.h")
#   define __has_AEDataKit 1
#   import "AEDataKit.h"
#else
#   define __has_AEDataKit 0
#endif

// -------------------------------------------
// 序列化／反序列化
// -------------------------------------------

// YYModel
#if __has_include(<YYModel/YYModel.h>)
#   define __has_YYModel 1
#   import <YYModel/YYModel.h>
#elif __has_include("YYModel.h")
#   define __has_YYModel 1
#   import "YYModel.h"
#else
#   define __has_YYModel 0
#endif

// MJExtension
#if __has_include(<MJExtension/MJExtension.h>)
#   define __has_MJExtension 1
#   import <MJExtension/MJExtension.h>
#elif __has_include("MJExtension.h")
#   define __has_MJExtension 1
#   import "MJExtension.h"
#else
#   define __has_MJExtension 0
#endif

// -------------------------------------------
// 网页
// -------------------------------------------

// AEHybridEngine
#if __has_include(<AEHybridEngine/AEHybridEngine>)
#   define __has_AEHybridEngine 1
#   import <AEHybridEngine/AEHybridEngine.h>
#elif __has_include("AEHybridEngine.h")
#   define __has_AEHybridEngine 1
#   import "AEHybridEngine.h"
#else
#   define __has_AEHybridEngine 0
#endif

// ALSWebViewController 暂时的
#if __has_include("ALSWebViewController.h")
#   define __has_ALSWebViewController 1
#   import "ALSWebViewController.h"
#else
#   define __has_ALSWebViewController 0
#endif

// -------------------------------------------
// 图片上传
// -------------------------------------------

// OSSService
#if __has_include("OSSService.h")
#   define __has_OSSService 1
#   import "OSSService.h"
#else
#   define __has_OSSService 0
#endif

// -------------------------------------------
// 业务
// -------------------------------------------

#if __has_include("AESUser.h")
#   define __has_AESUser 1
#   import "AESUser.h"
#else
#   define __has_AESUser 0
#endif

// -------------------------------------------
// 场景路由
// -------------------------------------------

#if __has_include("AESegueService.h")
#   define __has_AESegueService 1
#   import "AESegueService.h"
#else
#   define __has_AESegueService 0
#endif

// -------------------------------------------
// 模块路由（万能路由）
// -------------------------------------------


// -------------------------------------------
// 分享
// -------------------------------------------

#if __has_include(<ALSShare/ALSShareService.h>)
#   define __has_ALSShareService 1
#   import <ALSShare/ALSShareService.h>
#elif __has_include("ALSShareService.h")
#   define __has_ALSShareService 1
#   import "ALSShareService.h"
#else
#   define __has_ALSShareService 0
#endif

// -------------------------------------------
// 公共 UI 组件
// -------------------------------------------

#if __has_include("iToast.h")
#   define __has_iToast 1
#   import "iToast.h"
#else
#   define __has_iToast 0
#endif

// -------------------------------------------
// 支付 组件
// -------------------------------------------

#if __has_include("ALSPayment.h")
#   define __has_ALSPayment 1
#   import "ALSPayment.h"
#   import "ALSPaymentProtocol.h"
#   import <ALSInterfaceSdk/ALSTransactionKit.h>
#   import <ALSInterfaceSdk/NetHelp.h>
#else
#   define __has_ALSPayment 0
#endif

// -------------------------------------------
// 日志 组件
// -------------------------------------------

#if __has_include(<ALSLog/ALSLog.h>)
#   define __has_ALSLog 1
#   import <ALSLog/ALSLog.h>
#else
#   define __has_ALSLog 0
#endif

// -------------------------------------------
// QQ 公共api 组件
// -------------------------------------------
#if __has_include(<TencentOpenAPI/QQApiInterface.h>)
#   define __has_ALSTencentOpenAPI 1
#   import <TencentOpenAPI/QQApiInterface.h>
#else
#   define __has_ALSTencentOpenAPI 0
#endif

// -------------------------------------------
// 安全 组件
// -------------------------------------------

#if __has_include(<SecurityGuardSDK/Open/OpenSecurityGuardManager.h>)
#   define __has_SecurityGuardSDK 1
#import <SecurityGuardSDK/Open/OpenSecurityGuardManager.h>
#import <SecurityGuardSDK/Open/OpenDynamicDataEncrypt/IOpenDynamicDataEncryptComponent.h>
#import <SecurityGuardSDK/Open/OpenStaticDataStore/IOpenStaticDataStoreComponent.h>
#else
#   define __has_SecurityGuardSDK 0
#endif


// -------------------------------------------
// 。。。 组件
// -------------------------------------------



