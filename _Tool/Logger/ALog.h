//
//  ALog.h
//  LogTest
//
//  Created by 君展 on 13-9-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog




#import "AriderLogDefine.h"

//异步打印日志方法
#define ALogError(frmt, ...)   LOG_C_MAYBE(ALOG_ASYNC_ERROR,   ALOG_LEVEL_DEF, ALOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define ALogWarn(frmt, ...)    LOG_C_MAYBE(ALOG_ASYNC_WARN,    ALOG_LEVEL_DEF, ALOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define ALogInfo(frmt, ...)    LOG_C_MAYBE(ALOG_ASYNC_INFO,    ALOG_LEVEL_DEF, ALOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define ALogDebug(frmt, ...)   LOG_C_MAYBE(ALOG_ASYNC_DEBUG,   ALOG_LEVEL_DEF, ALOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define ALogVerbose(frmt, ...) LOG_C_MAYBE(ALOG_ASYNC_VERBOSE, ALOG_LEVEL_DEF, ALOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

//同步打印日志方法
#define ALogErrorSync(frmt, ...)   LOG_C_MAYBE(ALOG_SYNC_ERROR,   ALOG_LEVEL_DEF, ALOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define ALogWarnSync(frmt, ...)    LOG_C_MAYBE(ALOG_SYNC_WARN,    ALOG_LEVEL_DEF, ALOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define ALogInfoSync(frmt, ...)    LOG_C_MAYBE(ALOG_SYNC_INFO,    ALOG_LEVEL_DEF, ALOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define ALogDebugSync(frmt, ...)   LOG_C_MAYBE(ALOG_SYNC_DEBUG,   ALOG_LEVEL_DEF, ALOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define ALogVerboseSync(frmt, ...) LOG_C_MAYBE(ALOG_SYNC_VERBOSE, ALOG_LEVEL_DEF, ALOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

//#warning @"将NSLog重定义为ALogInfo"
//#define NSLog(frmt,...) ALogInfo((frmt), ##__VA_ARGS__)

#define ALOG_IS_IMPORTED 1


//#define ALogError(frmt, ...)   {}
//#define ALogWarn(frmt, ...)    {}
//#define ALogInfo(frmt, ...)    {}
//#define ALogDebug(frmt, ...)   {}
//#define ALogVerbose(frmt, ...) {}
