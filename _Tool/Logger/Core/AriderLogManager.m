//
//  AriderLogManager.m
//  LogTest
//
//  Created by 君展 on 13-8-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogManager.h"
#import "AriderLogComponetView.h"
#import "AriderLogFormatter.h"
#import "AriderLogFileFormatter.h"
#import "MongooseDaemon.h"
#import "AriderTool.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "fishhook.h"
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDLog.h>

int globalALogLevel = ALOG_LEVEL_VERBOSE; // NOT CONST
NSString* const kAriderLogFindNewFileNameNotification = @"kAriderLogFindNewFileNameNotification";
NSString* const kAriderLogFindNewMethodNameNotification = @"kAriderLogFindNewMethodNameNotification";
NSString* const kAriderLogShowLogComponetView = @"kAriderLogShowLogComponetView";
@interface AriderLogManager()<AriderLogFormatterDelegate>
{
    AriderLogFormatter *_ttyFilter;//控制台过滤器
    AriderLogComponetView *_logComponetView;
    MongooseDaemon *_remoteServer;
}
@end
#define IP_PORT @"1688"
@implementation AriderLogManager


+ (void)setup{
    [[AriderLogManager sharedManager] setupAll];
}

+ (AriderLogManager *)sharedManager{
    static AriderLogManager *kInstance = nil;
    @synchronized(self){
        if(!kInstance){
            kInstance = [[AriderLogManager alloc] init];
        }
    }
    return kInstance;
}
- (id)init{
    self = [super init];
    if(self){//这里不应该调用setup,否则会造出无限递归

    }
    return self;
}

- (void)setupAll{
    [self setupDefaultValue];
    [self setupLogger];
    [self setupStdErrorLog];
    [self setupLogView];
}

- (void)setupLogger{
    [DDLog addLogger:[DDASLLogger sharedInstance]];//system

    [DDLog addLogger:[DDTTYLogger sharedInstance]];//控制台
    _ttyFilter = [[AriderLogFormatter alloc] init];
    _ttyFilter.formatterDelegate = self;
    [[DDTTYLogger sharedInstance] setLogFormatter:_ttyFilter];
    
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    AriderLogFileFormatter *fileFormatter = [[AriderLogFileFormatter alloc] init];
    [fileLogger setLogFormatter:fileFormatter];
    [DDLog addLogger:fileLogger];//文件
}

//- (void)setupColor{
//    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
//
//    char *xcode_colors = getenv("XcodeColors");
//    if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
//    {
//        // XcodeColors is installed and enabled!
//    }
//}

- (void)setupLogView{
    _logComponetView = [[[NSBundle mainBundle] loadNibNamed:@"AriderLogComponetView" owner:self options:nil] objectAtIndex:0];
}

- (void)setupDefaultValue{
    self.filterFileNameSet = [[NSMutableSet alloc] init];
    self.filterMethodNameSet = [[NSMutableSet alloc] init];
    self.saveFileNameSet = [[NSMutableSet alloc] init];
    self.saveMethodNameSet = [[NSMutableSet alloc] init];
    self.isCaseInsensitive = YES;
//    self.isShowFunctionName = YES;
//    self.isShowFileName = YES;
    self.isShowTime = YES;
    self.isWriteLogIntoFile = NO;
}

- (void)setupStdErrorLog{
    //此功能影响了SPDY的日志,导致异常,先关掉
//    if (!isatty(STDERR_FILENO)){//如果没有联机调试
//        [self writeSysLogIntoFile];
//    }else{//联机就没必要写入文件了.提高效率
//        
//    }
}

#pragma mark file log
//将非通过宏调用的log日志重定向到文件. 怎么和ALog文件合并?
- (void)writeSysLogIntoFile{
    if (!isatty(STDERR_FILENO)){//如果没有联机调试
        NSString *logDirectory = [self defaultLogsDirectory];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *suffix = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"alog_%@.log", suffix];
        NSString *logPath = [logDirectory stringByAppendingPathComponent:fileName];
        freopen([logPath UTF8String], "a+", stderr);
    }else{//联机就没必要写入文件了.提高效率

    }
}

- (NSString *)defaultLogsDirectory
{
#if TARGET_OS_IPHONE
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];
    
#else
	NSString *appName = [[NSProcessInfo processInfo] processName];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	NSString *logsDirectory = [[basePath stringByAppendingPathComponent:@"Logs"] stringByAppendingPathComponent:appName];
    
#endif
    [[NSFileManager defaultManager] createDirectoryAtPath:logsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	return logsDirectory;
}


#pragma mark AriderLogFormatterDelegate
- (void)ariderLogFormatter:(AriderLogFormatter *)formatter orginalLogMessage:(DDLogMessage *)logMessage formattedText:(NSString *)formattedText{
    [_logComponetView.logDisplayView addText:formattedText textColor:nil];
}

#pragma mark property

- (UIWindow *)loggoWindow{
    return _logComponetView.loggoWindow;
}

- (NSInteger)logLevel{
    return globalALogLevel;
}

- (void)setLogLevel:(NSInteger)logLevel{
    globalALogLevel = (int)logLevel;
}

- (NSInteger)functionCount{
    return _logComponetView.segmentModelArray.count;
}

- (AriderLogFormatter *)logFormatter{
    return _ttyFilter;
}

#pragma mark fish hook
static void (*orig_NSLog)(NSString *format, ...);
static int (*orig_printf)(const char *format, ...);

static void alog_NSLog(NSString *format, ...){
    if([AriderLogManager sharedManager].isCloseSystemLog){//关闭

    }else if([AriderLogManager sharedManager].isFilterSystemLog){//过滤
        va_list ap = {0};
        va_start(ap, format);
        
        NSString *logMsg = [[NSString alloc] initWithFormat:format arguments:ap];
        DDLogMessage *logMessage = [[DDLogMessage alloc] initWithLogMsg:logMsg
                                                                  level:ALOG_INFO
                                                                   flag:0
                                                                context:0
                                                                   file:""
                                                               function:""
                                                                   line:0
                                                                    tag:0
                                                                options:0];
        NSString *newLog = [[[AriderLogManager sharedManager] logFormatter] formatLogMessage:logMessage];
        if(newLog.length > 0){
            orig_NSLog(@"%@", newLog);
        }
        va_end(ap);
    }else{//开启
        va_list ap = {0};
        va_start(ap, format);
        NSLogv(format, ap);
        va_end(ap);
    }
}

static int alog_printf(const char *format, ...){
    if([AriderLogManager sharedManager].isCloseSystemLog){//关闭
        
    }else if([AriderLogManager sharedManager].isFilterSystemLog){//过滤
        va_list ap = {0};
        va_start(ap, format);
        NSString *ocFormat = [[NSString alloc] initWithUTF8String:format];
        NSString *logMsg = [[NSString alloc] initWithFormat:ocFormat arguments:ap];
        DDLogMessage *logMessage = [[DDLogMessage alloc] initWithLogMsg:logMsg
                                                                  level:ALOG_INFO
                                                                   flag:0
                                                                context:0
                                                                   file:""
                                                               function:""
                                                                   line:0
                                                                    tag:0
                                                                options:0];
        NSString *newLog = [[[AriderLogManager sharedManager] logFormatter] formatLogMessage:logMessage];
        if(newLog.length > 0){
            orig_printf("%s", [newLog UTF8String]);
        }
        va_end(ap);
    }else{//开启
        va_list ap = {0};
        NSString *ocFormat = [[NSString alloc] initWithUTF8String:format];
        va_start(ap, format);
        NSLogv(ocFormat, ap);
        va_end(ap);
    }
    return 0;
}



static void hookSystemLog(){
    if(!orig_NSLog){
        alog_rebind_symbols((struct rebinding[2]){{"NSLog", alog_NSLog, (void *)&orig_NSLog},
        {"printf", alog_printf, (void *)&orig_printf}}, 2);
    }
}

- (void)setIsFilterSystemLog:(BOOL)isFilterSystemLog{
    hookSystemLog();
    _isFilterSystemLog = isFilterSystemLog;
}

- (void)setIsCloseSystemLog:(BOOL)isCloseSystemLog{
    hookSystemLog();
    _isCloseSystemLog = isCloseSystemLog;
}
#pragma mark network
- (void)setIsRemoteAccess:(BOOL)isRemoteAccess{
    _isRemoteAccess = isRemoteAccess;
    if(isRemoteAccess){
        _remoteServer = nil;
        _remoteServer = [[MongooseDaemon alloc] init];
        [_remoteServer startMongooseDaemon:IP_PORT];
    }else{
        [_remoteServer stopMongooseDaemon];
    }
}

- (NSString *)remoteAccessIPAddress{
    return [NSString stringWithFormat:@"http://%@:%@", [_remoteServer getIPAddress], IP_PORT];
}

#pragma mark function

- (void)clearDisplayLog{
    [_logComponetView.logDisplayView clearText];
}

- (void)insertFunctiontWithTitle:(NSString *)title view:(UIView *)view atIndex:(NSUInteger)segment{
    [_logComponetView insertSegmentWithTitle:title view:view atIndex:segment];
}
- (void)removeFunctionAtIndex:(NSUInteger)segment{
    [_logComponetView removeSegmentAtIndex:segment];
}

- (void)showFunctionAtIndex:(NSUInteger)segment{
    [_logComponetView showSegmentAtIndex:segment];
}

- (CGRect)frameForFunctionView{
    return CGRectMake(0, 0, [AriderTool screenWidth], ALOG_SUB_COMPONET_VIEW_HEIGHT);
}

- (void)showLogView{
    if(self.isShowLogView){
        //已经显示,不用干啥
    }else{
        _isShowLogView = YES;
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.logComponetView];
        //发送消息
        [[NSNotificationCenter defaultCenter] postNotificationName:kAriderLogShowLogComponetView object:self];
        
        AriderLogComponetView *compView = (AriderLogComponetView *)self.logComponetView;
        [compView.menuScrollView flashScrollIndicators];
    }
}

- (void)hideLogView{
    if(self.isShowLogView){
        _isShowLogView = NO;
        [self.logComponetView removeFromSuperview];
    }else{
        //没显示,不用干啥
    }
    
}

#pragma mark TLog适配

+ (void)callTLog:(NSString *)level format:(NSString *)format, ...{

    va_list args;
    if (format){
        va_start(args, format);
        NSString *logMsg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);

        id TLog = objc_getClass("TLog");
        SEL infoSEL = NSSelectorFromString([NSString stringWithFormat:@"%@:", level]);
        if(TLog && [TLog respondsToSelector:infoSEL]){
            ((void(*)(id, SEL, id))objc_msgSend)(TLog, infoSEL, logMsg);
        }
    }
}

#pragma mark 适配动态打log, 无编译依赖


+ (void)log:(BOOL)asynchronous
       flag:(NSString *)flag
    context:(int)context
       file:(const char *)file
   function:(const char *)function
       line:(int)line
        tag:(id)tag
    isCallTLog:(BOOL)isCallTLog
     format:(NSString *)format, ...
{
 
    int level = (int)[self sharedManager].logLevel;
    NSDictionary *flagDict = @{@"error":@ALOG_FLAG_ERROR, @"warn":@ALOG_FLAG_WARN,
                                @"info":@ALOG_FLAG_INFO, @"debug":@ALOG_FLAG_DEBUG, @"verbose":@ALOG_FLAG_VERBOSE};
    int flagValue = (int)[flagDict[flag] integerValue];
    
    if(level & flagValue){
        va_list args;
        if (format)
        {
            va_start(args, format);
            [DDLog log:asynchronous level:level flag:flagValue context:context file:file function:function line:line tag:tag format:format args:args];
            va_end(args);
        }
    }
    if(isCallTLog){
        va_list args;
        va_start(args, format);
        NSString *logMsg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        id TLog = objc_getClass("TLog");
        SEL infoSEL = NSSelectorFromString([NSString stringWithFormat:@"%@:", flag]);
        if(TLog && [TLog respondsToSelector:infoSEL]){
            ((void(*)(id, SEL, id))objc_msgSend)(TLog, infoSEL, logMsg);
        }
    }
}
@end
