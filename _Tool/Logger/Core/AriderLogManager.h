//
//  AriderLogManager.h
//  功能强大的log
//
//  Created by 君展 on 13-8-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <Foundation/Foundation.h>



//#warning @"请注意AriderLog内部不能用NSLog,可以使用printf"
/**
 *	日志等级全局变量,需要设置等级，请调用AriderLogManager的logLevel属性
 */
extern int globalALogLevel;

#define ALOG_LEVEL_DEF globalALogLevel

/**
 *	发现新的文件名在打印日志
 */
extern  NSString* const kAriderLogFindNewFileNameNotification;

/**
 *	发现新的方法在打印日志
 */
extern  NSString* const kAriderLogFindNewMethodNameNotification;

/**
 *	用户点击显示组件
 */
extern NSString* const kAriderLogShowLogComponetView;

@interface AriderLogManager : NSObject

/**
 *	日志等级.默认为Verbose
 */
@property (nonatomic, assign)NSInteger logLevel;


#pragma mark --日志过滤

/**
 *	过滤日志的模式串
 */
@property (nonatomic, copy)NSString *filterPattern;

/**
 * 文件名过滤的模式串， 此模式串的文件名可以打出日志
 */
@property (nonatomic, copy) NSString *filenameFilterPattern;

/**
 *	过滤是否忽略大小写.默认为YES
 */
@property (nonatomic, assign)BOOL isCaseInsensitive;

/**
 *	过滤是否完全匹配.默认为NO
 */
@property (nonatomic, assign)BOOL isCompelteMatch;


/**
 *  是否过滤NSLog的日志
 */
@property (nonatomic, assign)BOOL isFilterSystemLog;

/**
 *  是否关闭NSLog的日志
 */
@property (nonatomic, assign)BOOL isCloseSystemLog;

/**
 *	过滤文件名集合.此集合里的文件内产生的日志将不会显示
 */
@property (nonatomic, retain)NSMutableSet *filterFileNameSet;

/**
 *	过滤函数名集合.此集合里的函数内产生的日志将不会显示
 */
@property (nonatomic, retain)NSMutableSet *filterMethodNameSet;

/**
 *	存储文件名.必须线程安全
 */
@property (atomic, retain)NSMutableSet *saveFileNameSet;

/**
 *	存储方法名.必须线程安全
 */
@property (atomic, retain)NSMutableSet *saveMethodNameSet;


#pragma mark --日志显示

/**
 *	是否写入文件.默认为YES
 */
@property (nonatomic, assign)BOOL isWriteLogIntoFile;


/**
 *	显示文件名.
 */
@property (nonatomic, assign)BOOL isShowFileName;

/**
 *	显示函数名
 */
@property (nonatomic, assign)BOOL isShowFunctionName;

/**
 *	显示行号
 */
@property (nonatomic, assign)BOOL isShowLineNumber;

/**
 *	显示时间
 */
@property (nonatomic, assign)BOOL isShowTime;

/**
 *	显示所在线程名
 */
@property (nonatomic, assign)BOOL isShowThead;

/**
 *	显示所在进程名
 */
@property (nonatomic, assign)BOOL isShowProcess;

/**
 *	日志是否写入文件
 */
@property (nonatomic, assign)BOOL isWriteToFile;


/**
 *	是否开启远程访问。可以通过IP地址访问app下所有文件
 */
@property (nonatomic, assign) BOOL isRemoteAccess;

/**
 *	如果开启了远程访问，那么可以获取到访问的IP地址和端口
 */
@property (nonatomic, readonly) NSString *remoteAccessIPAddress;


#pragma mark --获取属性

/**
 *	现在是否显示了日志组件
 */
@property (nonatomic, readonly)BOOL isShowLogView;


/**
 *	ALog的标志按钮所在的window，可以修改此window的frame，样式等.
 */
@property (nonatomic, readonly) UIWindow *loggoWindow;

/**
 *	整个ALog显示组件的view, 可以修改frame, 样式等.
 */
@property (nonatomic, readonly) UIView *logComponetView;

/**
 *	功能总数，insertFunctiont时可能需要用到
 */
@property (nonatomic, readonly) NSInteger functionCount;


#pragma mark --初始化
+ (AriderLogManager *)sharedManager;

/**
 *	初始化操作
 */
+ (void)setup;


#pragma mark 功能添加，删除
/**
 *	清空显示的日志
 */
- (void)clearDisplayLog;

/**
 *	在segmentedControl中添加一个功能
 *
 *	@param 	title 	标题
 *	@param 	view 	对应的试图
 *	@param 	segment 	segmentedControl的位置
 */
- (void)insertFunctiontWithTitle:(NSString *)title view:(UIView *)view atIndex:(NSUInteger)segment;

/**
 *	删除segmentedControl的某个功能
 *
 *	@param 	segment 	segmentedControl的位置
 */
- (void)removeFunctionAtIndex:(NSUInteger)segment;

/**
 *	显示第segment个功能
 *
 *	@param 	segment 	segmentedControl的位置
 */
- (void)showFunctionAtIndex:(NSUInteger)segment;

/**
 *  获取ALog能显示功能视图的的大小,可以用来初始化自己的View
 *
 *  @return <#return value description#>
 */
- (CGRect)frameForFunctionView;

/**
 *  显示整个ALog视图
 */
- (void)showLogView;

/**
 *  隐藏整个ALog视图
 */
- (void)hideLogView;

/**
 *  设置非联机调试时所有的系统stderr（如NSLog,系统crash时的原因）日志写入文件. 文件目录在app的/Library/Caches/Logs/alog_XXX.log
 */
- (void)writeSysLogIntoFile;

/**
 *  调用TLog
 *
 *  @param level  <#level description#>
 *  @param format <#format description#>
 */
+ (void)callTLog:(NSString *)level format:(NSString *)format, ...;
@end
