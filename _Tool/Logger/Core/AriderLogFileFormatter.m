//
//  AriderLogFileFormatter.m
//  LogTest
//
//  Created by 君展 on 13-9-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogFileFormatter.h"
#import "AriderLogManager.h"
@implementation AriderLogFileFormatter

//此处需要保证线程安全!
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage{
    if (![AriderLogManager sharedManager].isWriteLogIntoFile) {//不写入文件则返回空
        return nil;
    }
    if(!logMessage->logMsg)
        return @"";
    NSString *text = [self logByAddInfo:logMessage];
    return text;
}

- (NSString *)logByAddInfo:(DDLogMessage *)logMessage{
    NSMutableString *finalLog = [NSMutableString string];
    
    [finalLog appendFormat:@"%@ ", logMessage->timestamp];
    
    if(strcmp("thread:com.apple.main-thread", logMessage->queueLabel) != 0){
        [finalLog appendFormat:@"thread:%s ", logMessage->queueLabel];
    }
    
    [finalLog appendFormat:@"file:%@ ", [logMessage fileName]];
    
    [finalLog appendFormat:@"method:%@ ", [logMessage methodName]];
    
    [finalLog appendFormat:@"line:%d ", logMessage->lineNumber];
    
    [finalLog appendString:logMessage->logMsg];
    return finalLog;
}

@end
