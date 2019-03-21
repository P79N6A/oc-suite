//
//  AriderLogFileFormatter.h
//  LogTest
//
//  Created by 君展 on 13-9-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/DDLog.h>
@interface AriderLogFileFormatter : NSObject<DDLogFormatter>

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage;
@end
