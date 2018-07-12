//
//  LogFileManager.m
// fallen.ink
//
//  Created by fallen.ink on 12/21/15.
//
//

#import "LogFileManager.h"
#import "ZipArchive.h"
#import "CocoaLumberjack.h"

static const int64_t kLogFileMaxSize = 1024*1024*1;

@interface LogFileManager ()

/*
 * 初始化 log 第三方库
 *
 */
- (void)initLumberjack;

/**
 *  输出 log 文件列表
 */
- (NSArray *)logFilePathArray;

@end

@implementation LogFileManager

@def_singleton( LogFileManager )

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        [self initLumberjack];
    }
    
    return self;
}

- (void)initLumberjack {
    // Basic config
    {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    }
    
    // Init log file
    {
        DDLogFileManagerDefault *ddlogFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:self.logFileDirectory];
        DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:ddlogFileManager];
        fileLogger.maximumFileSize = kLogFileMaxSize; // 设置log文件大小
        fileLogger.logFileManager.maximumNumberOfLogFiles = 2; // 设置log文件最多个数
        fileLogger.rollingFrequency = INT_MAX;
        
        [DDLog addLogger:fileLogger];
    }
}

#pragma mark - zipper & manager

- (NSData *)compressLogFiles {
    NSArray *filenames  = [self logFilePathArray];
    
    // 压缩 log 文件
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:self.zippedLogFilePath];
    
    //循环压缩所有的log文件
    for( NSString *fileName in filenames){
        NSRange range = [fileName rangeOfString:@".log"];
        if (range.length > 0) {
            NSString *logFilePath = [path_of_document stringByAppendingPathComponent:[NSString stringWithFormat:@"Logs/%@",fileName]];
            [za addFileToZip:logFilePath newname:fileName];
        }
    }
    
    [za CloseZipFile2];
    
    // 返回压缩之后的文件
    return [self zippedLogFileData];
}

- (void)deleteLogFiles {
    // todo
}

#pragma mark - Private method

- (NSArray *)logFilePathArray {
    // 查询 log 文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager contentsOfDirectoryAtPath:
            [path_of_document stringByAppendingPathComponent:@"Logs"] error:nil];
}

#pragma mark - Property

- (NSString *)logFileDirectory {
    //设置log文件路径
    NSString *logsDirectory = [path_of_document stringByAppendingPathComponent:@"Logs/"];
    
    return logsDirectory;
}

- (NSString *)zippedLogFilename {
    return @"LOGFile.zip";
}

- (NSString *)zippedLogFilePath {
    // 设置log文件全路径
    NSString *zipFilePath = [self.logFileDirectory stringByAppendingPathComponent:self.zippedLogFilename];
    
    return zipFilePath;
}

- (NSData *)zippedLogFileData {
    NSData *fileData = [NSData dataWithContentsOfFile:[self zippedLogFilePath]];
    return fileData;
}

@end
