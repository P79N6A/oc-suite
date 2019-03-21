//
//  AriderLogFormatter.h
//  LogTest
//
//  Created by 君展 on 13-8-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/DDLog.h>

@protocol AriderLogFormatterDelegate;
@interface AriderLogFormatter : NSObject<DDLogFormatter>
@property (nonatomic, unsafe_unretained)id<AriderLogFormatterDelegate> formatterDelegate;
@property (nonatomic, retain)NSDateFormatter *dateFormatter;
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage;

@end

@protocol AriderLogFormatterDelegate <NSObject>
@optional
/**
 *	告诉delegate,已经格式化了消息对象
 *
 *	@param 	formatter 	<#formatter description#>
 *	@param 	logMessage 	原消息对象
 *	@param 	formattedText 	格式化后的字符串
 */
- (void)ariderLogFormatter:(AriderLogFormatter *)formatter orginalLogMessage:(DDLogMessage *)logMessage formattedText:(NSString *)formattedText;


@end