//
//  ALog+Runtime.h
//  AriderLog
//
//  Created by junzhan on 15-8-3.
//  Copyright (c) 2015年 Taobao. All rights reserved.
//

#ifndef AriderLog_ALog_Runtime_h
#define AriderLog_ALog_Runtime_h
#import <objc/message.h>
#import <objc/runtime.h>

//如果不想依赖ALog的头文件,但又希望在集成手淘后仍然能在debug环境显示日志,那么可以复制如下代码放到你的pch文件或者头文件中.
//对现有的NSLog代码进行重定向, 你可以添加底部的NSLog宏
//如果需要将日志同时写入TLog,那么可以把frmt前的NO改成YES

//请改成你的bundle名称，如mytaobao
#define BUNDLE_NAME @"your_bundle_name"

#pragma mark ALog异步打印日志接口

#define TAG @{@"bundle_name": BUNDLE_NAME}

#define RUNTIME_CALL_LOG(async, level , frmt, ...) \
do{\
Class kls = objc_getClass("AriderLogManager");\
SEL sel = NSSelectorFromString(@"log:flag:context:file:function:line:tag:isCallTLog:format:");\
if(kls && [kls respondsToSelector:sel]){\
((void(*)(id, SEL, BOOL, NSString *, int, const char *, const char *, int, id, BOOL, NSString *, ...))objc_msgSend)(kls, sel, async, level, 1, __FILE__, __PRETTY_FUNCTION__, __LINE__, TAG, NO, frmt, ##__VA_ARGS__);\
}\
}while(0)\

#define ALogError(frmt, ...)    RUNTIME_CALL_LOG(YES, @"error", frmt, ##__VA_ARGS__)

#define ALogWarn(frmt, ...)     RUNTIME_CALL_LOG(YES, @"warn", frmt, ##__VA_ARGS__)

#define ALogInfo(frmt, ...)     RUNTIME_CALL_LOG(YES, @"info", frmt, ##__VA_ARGS__)

#define ALogDebug(frmt, ...)    RUNTIME_CALL_LOG(YES, @"debug", frmt, ##__VA_ARGS__)

#define ALogVerbose(frmt, ...)  RUNTIME_CALL_LOG(YES, @"verbose", frmt, ##__VA_ARGS__)


#pragma mark ALog同步打印日志接口
#define ALogErrorSync(frmt, ...)    RUNTIME_CALL_LOG(NO, @"error", frmt, ##__VA_ARGS__)

#define ALogWarnSync(frmt, ...)     RUNTIME_CALL_LOG(NO, @"warn", frmt, ##__VA_ARGS__)

#define ALogInfoSync(frmt, ...)     RUNTIME_CALL_LOG(NO, @"info", frmt, ##__VA_ARGS__)

#define ALogDebugSync(frmt, ...)    RUNTIME_CALL_LOG(NO, @"debug", frmt, ##__VA_ARGS__)

#define ALogVerboseSync(frmt, ...)  RUNTIME_CALL_LOG(NO, @"verbose", frmt, ##__VA_ARGS__)


//对现有的NSLog代码进行重定向, 你可以选择开启此功能
//#define NSLog(frmt,...) ALogInfo((frmt), ##__VA_ARGS__)

#endif
