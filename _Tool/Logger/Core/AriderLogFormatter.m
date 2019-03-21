//
//  AriderLogFormatter.m
//  LogTest
//
//  Created by 君展 on 13-8-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogFormatter.h"
#import "AriderLogManager.h"
@interface AriderLogFormatter()

@end

@implementation AriderLogFormatter

//此处需要保证线程安全!
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage{
    //收集信息
    NSString *fileName = [self collectFileName:logMessage];
    [self collectFunctionName:logMessage];
    
    //过滤模式串
    if(![self hasPattern:[AriderLogManager sharedManager].filterPattern inText:logMessage->logMsg]){
        return nil;
    }
    
    // 过滤文件名
    if (![self hasPattern:[AriderLogManager sharedManager].filenameFilterPattern inText:fileName]) {
        return nil;
    }
    
    //过滤文件名
    if([self isFilterByFileName:logMessage]){
        return nil;
    }
    //过滤函数名
    if([self isFilterByMethodName:logMessage]){
        return nil;
    }
    
    //格式化
    NSString *text = [self logByAddInfo:logMessage];

    //通知delegate处理完结果
    __unsafe_unretained AriderLogFormatter *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([weakSelf.formatterDelegate respondsToSelector:@selector(ariderLogFormatter:orginalLogMessage:formattedText:)]){
            [weakSelf.formatterDelegate ariderLogFormatter:weakSelf orginalLogMessage:logMessage formattedText:text];
        }
    });
    
    return text;
}

#pragma mark format
- (NSString *)logByAddInfo:(DDLogMessage *)logMessage{
    NSMutableString *finalLog = [NSMutableString string];
    
    if([AriderLogManager sharedManager].isShowTime){
        [finalLog appendFormat:@"%@ ", [self timeByFormatter:logMessage->timestamp]];
    }
    
//    if([AriderLogManager sharedManager].isShowProcess){//pending
//        [finalLog stringByAppendingFormat:@"%@ ", logMessage->threadName];
//    }
    
    if([AriderLogManager sharedManager].isShowThead){
        [finalLog appendFormat:@"thread:%s ", logMessage->queueLabel];
    }
    
    if([AriderLogManager sharedManager].isShowFileName){
        [finalLog appendFormat:@"file:%@ ", [logMessage fileName]];
    }
    
    if([AriderLogManager sharedManager].isShowFunctionName){
        [finalLog appendFormat:@"method:%@ ", [logMessage methodName]];
    }
    
    if([AriderLogManager sharedManager].isShowLineNumber){
        [finalLog appendFormat:@"line:%d ", logMessage->lineNumber];
    }
    
    if(finalLog.length > 0){
        [finalLog appendString:logMessage->logMsg];
        return finalLog;
    }else{
        return logMessage->logMsg;
    }
}

- (NSString *)timeByFormatter:(NSDate *)date{
    if(!self.dateFormatter){//这里要加锁?
        NSString  *dateFormatString = @"MM-dd HH:mm:ss.SSS";
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [self.dateFormatter setDateFormat:dateFormatString];        
    }
    return [self.dateFormatter stringFromDate:date];
}

#pragma mark filter
- (BOOL)hasPattern:(NSString *)pattern inText:(NSString *)text{
    if(text.length == 0 || pattern.length == 0){
        return YES;
    }
    
    NSRegularExpressionOptions option = 0;
    if([AriderLogManager sharedManager].isCaseInsensitive){//大小写
        option = NSRegularExpressionCaseInsensitive;
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:option error:&error];
    if(!regex){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"过滤模式串不符合正则规范" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        return YES;//直接返回yes
    }
    NSTextCheckingResult *regxResult = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    
    //完全匹配验证
    BOOL returnValue = (regxResult && regxResult.range.location != NSNotFound);
    if(returnValue && [AriderLogManager sharedManager].isCompelteMatch){
        returnValue &= (regxResult.range.location == 0 && regxResult.range.length == text.length);
    }
    return returnValue;
}

- (BOOL)isFilterByFileName:(DDLogMessage *)logMessage{
    NSString *fileName = [logMessage fileName];
    if(!fileName){
        return NO;
    }
    if ([[AriderLogManager sharedManager].filterFileNameSet containsObject:fileName]) {
        return YES;
    }
    return NO;
}

- (BOOL)isFilterByMethodName:(DDLogMessage *)logMessage{
    NSString *methodName = [logMessage methodName];
    if(!methodName){
        return NO;
    }
    if ([[AriderLogManager sharedManager].filterMethodNameSet containsObject:methodName]) {
        return YES;
    }
    return NO;
}

#pragma mark collect
//收集文件名
- (NSString *)collectFileName:(DDLogMessage *)logMessage{
    NSString *fileName = [logMessage fileName];
    if(fileName.length > 0){
        if([[AriderLogManager sharedManager].saveFileNameSet containsObject:fileName]){
            //已有
        }else{
             [[AriderLogManager sharedManager].saveFileNameSet addObject:fileName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kAriderLogFindNewFileNameNotification object:self];
            });
        }
    }
    return fileName;
}

//收集函数名
- (void)collectFunctionName:(DDLogMessage *)logMessage{
    NSString *functionName = [logMessage methodName];
    if(functionName.length > 0){
        if(![[AriderLogManager sharedManager].saveMethodNameSet containsObject:functionName]){
            [[AriderLogManager sharedManager].saveMethodNameSet addObject:functionName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kAriderLogFindNewMethodNameNotification object:self];
            });
        }
    }
}


@end
