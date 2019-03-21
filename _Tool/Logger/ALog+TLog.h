//
//  ALog.h
//  LogTest
//
//  Created by 君展 on 13-9-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

// 适配ALog+TLog的宏定义,把整个头文件import或者拷贝到你的pch或者需要使用的头文件


#import <objc/message.h>
#import <objc/runtime.h>


//#warning @"将NSLog重定义为ALogInfo"
//#define NSLog(frmt,...) ALogInfo((frmt), ##__VA_ARGS__)

//DEBUG使用ALog，Release使用TLog
#ifdef DEBUG
#import <ALog/AriderLogDefine.h>

//同步打印日志方法,TLog没有对应的同步，异步，所以两者一样
#define ALogError(frmt, ...)   LOG_C_MAYBE(ALOG_ASYNC_ERROR,   ALOG_LEVEL_DEF, ALOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)

#define ALogWarn(frmt, ...)    LOG_C_MAYBE(ALOG_ASYNC_WARN,    ALOG_LEVEL_DEF, ALOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)

#define ALogInfo(frmt, ...)    LOG_C_MAYBE(ALOG_ASYNC_INFO,    ALOG_LEVEL_DEF, ALOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)

#define ALogDebug(frmt, ...)   LOG_C_MAYBE(ALOG_ASYNC_DEBUG,   ALOG_LEVEL_DEF, ALOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)

#define ALogVerbose(frmt, ...) LOG_C_MAYBE(ALOG_ASYNC_VERBOSE, ALOG_LEVEL_DEF, ALOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)


//同步打印日志方法,TLog没有对应的同步，异步，所以两者一样
#define ALogErrorSync(frmt, ...)   LOG_C_MAYBE(ALOG_SYNC_ERROR,   ALOG_LEVEL_DEF, ALOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__);

#define ALogWarnSync(frmt, ...)    LOG_C_MAYBE(ALOG_SYNC_WARN,    ALOG_LEVEL_DEF, ALOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__);

#define ALogInfoSync(frmt, ...)    LOG_C_MAYBE(ALOG_SYNC_INFO,    ALOG_LEVEL_DEF, ALOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__);

#define ALogDebugSync(frmt, ...)   LOG_C_MAYBE(ALOG_SYNC_DEBUG,   ALOG_LEVEL_DEF, ALOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__);

#define ALogVerboseSync(frmt, ...) LOG_C_MAYBE(ALOG_SYNC_VERBOSE, ALOG_LEVEL_DEF, ALOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__);


#else //Release

#define CALL_TLOG(level, f, ...) \
do{\
id TLog = objc_getClass("TLog");\
SEL infoSEL = NSSelectorFromString([NSString stringWithFormat:@"%@:", level]);\
NSString *s = [NSString stringWithFormat:(f), ##__VA_ARGS__]; \
if(TLog && [TLog respondsToSelector:infoSEL]){\
((void(*)(id, SEL, id))objc_msgSend)(TLog, infoSEL, s);\
}\
}while(0)\


//同步打印日志方法,TLog没有对应的同步，异步，所以两者一样
#define ALogError(frmt, ...)    CALL_TLOG(@"error", frmt, ##__VA_ARGS__)

#define ALogWarn(frmt, ...)     CALL_TLOG(@"warn", frmt, ##__VA_ARGS__)

#define ALogInfo(frmt, ...)     CALL_TLOG(@"info", frmt, ##__VA_ARGS__)

#define ALogDebug(frmt, ...)    CALL_TLOG(@"debug", frmt, ##__VA_ARGS__)

#define ALogVerbose(frmt, ...)  CALL_TLOG(@"info", frmt, ##__VA_ARGS__)


//同步打印日志方法,TLog没有对应的同步，异步，所以两者一样
#define ALogErrorSync(frmt, ...)    CALL_TLOG(@"error", frmt, ##__VA_ARGS__)

#define ALogWarnSync(frmt, ...)     CALL_TLOG(@"warn", frmt, ##__VA_ARGS__)

#define ALogInfoSync(frmt, ...)     CALL_TLOG(@"info", frmt, ##__VA_ARGS__)

#define ALogDebugSync(frmt, ...)    CALL_TLOG(@"debug", frmt, ##__VA_ARGS__)

#define ALogVerboseSync(frmt, ...)  CALL_TLOG(@"info", frmt, ##__VA_ARGS__)

#endif





