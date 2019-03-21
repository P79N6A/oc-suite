//
//  AriderLogDefine.h
//  LogTest
//
//  Created by 君展 on 13-9-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import "AriderLogManager.h"
#import <CocoaLumberjack/DDLog.h>

#define ALOG_FLAG_ERROR    (1 << 0)  // 0...00001
#define ALOG_FLAG_WARN     (1 << 1)  // 0...00010
#define ALOG_FLAG_INFO     (1 << 2)  // 0...00100
#define ALOG_FLAG_DEBUG    (1 << 3)  // 0...01000
#define ALOG_FLAG_VERBOSE  (1 << 4)  // 0...10000

#define ALOG_LEVEL_OFF     0
#define ALOG_LEVEL_ERROR   (ALOG_FLAG_ERROR)                                                                            // 0...00001
#define ALOG_LEVEL_WARN    (ALOG_FLAG_ERROR | ALOG_FLAG_WARN)                                                           // 0...00011
#define ALOG_LEVEL_INFO    (ALOG_FLAG_ERROR | ALOG_FLAG_WARN | ALOG_FLAG_INFO)                                          // 0...00111
#define ALOG_LEVEL_DEBUG   (ALOG_FLAG_ERROR | ALOG_FLAG_WARN | ALOG_FLAG_INFO | ALOG_FLAG_DEBUG)                        // 0...01111
#define ALOG_LEVEL_VERBOSE (ALOG_FLAG_ERROR | ALOG_FLAG_WARN | ALOG_FLAG_INFO | ALOG_FLAG_DEBUG | ALOG_FLAG_VERBOSE)    // 0...11111

#define ALOG_ERROR    (ALOG_LEVEL_DEF & ALOG_FLAG_ERROR)
#define ALOG_WARN     (ALOG_LEVEL_DEF & ALOG_FLAG_WARN)
#define ALOG_INFO     (ALOG_LEVEL_DEF & ALOG_FLAG_INFO)
#define ALOG_DEBUG    (ALOG_LEVEL_DEF & ALOG_FLAG_DEBUG)
#define ALOG_VERBOSE  (ALOG_LEVEL_DEF & ALOG_FLAG_VERBOSE)

#define ALOG_ASYNC_ENABLED YES

#define ALOG_ASYNC_ERROR    ( NO && ALOG_ASYNC_ENABLED)
#define ALOG_ASYNC_WARN     (YES && ALOG_ASYNC_ENABLED)
#define ALOG_ASYNC_INFO     (YES && ALOG_ASYNC_ENABLED)
#define ALOG_ASYNC_DEBUG    (YES && ALOG_ASYNC_ENABLED)
#define ALOG_ASYNC_VERBOSE  (YES && ALOG_ASYNC_ENABLED)

#define ALOG_SYNC_ERROR    NO
#define ALOG_SYNC_WARN     NO
#define ALOG_SYNC_INFO     NO
#define ALOG_SYNC_DEBUG    NO
#define ALOG_SYNC_VERBOSE  NO

//备用
//#if (ALOG_SET_MODE == 1)
//
//#warning @"开启功能强大的AriderLog"
//
//#import "AriderLogManager.h"
//
//#define ALogError(frmt, ...)   LOG_C_MAYBE(LOG_ASYNC_ERROR,   ddLogLevel, LOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
//#define ALogWarn(frmt, ...)    LOG_C_MAYBE(LOG_ASYNC_WARN,    ddLogLevel, LOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
//#define ALogInfo(frmt, ...)    LOG_C_MAYBE(LOG_ASYNC_INFO,    ddLogLevel, LOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
//#define ALogVerbose(frmt, ...) LOG_C_MAYBE(LOG_ASYNC_VERBOSE, ddLogLevel, LOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)
//
////默认的原来NSLog都为ALogInfo
//#define NSLog(frmt,...) ALogInfo((frmt), ##__VA_ARGS__)
//
//#elif (ALOG_SET_MODE == 2)
//
//#warning @"使用原始的NSLog"
//
//#define ALogError(frmt, ...)   NSLog((frmt), ##__VA_ARGS__)
//#define ALogWarn(frmt, ...)    NSLog((frmt), ##__VA_ARGS__)
//#define ALogInfo(frmt, ...)    NSLog((frmt), ##__VA_ARGS__)
//#define ALogVerbose(frmt, ...) NSLog((frmt), ##__VA_ARGS__)
//
//#else
//
//#warning @"关闭代码产生的日志"
////注意usertrack等framework库的日志需这里是关闭不了的,需要找到对应库的方法关闭
//
//#define NSLog(frmt,...) {}
//#define ALogError(frmt, ...)   {}
//#define ALogWarn(frmt, ...)    {}
//#define ALogInfo(frmt, ...)    {}
//#define ALogVerbose(frmt, ...) {}
//#endif
