//
//  LogFileManager.h
// fallen.ink
//
//  Created by fallen.ink on 12/21/15.
//
//

#import "_greats.h"

/**
 *  @desc 暂时不支持，文件配置
 
 *  先flush到同一个文件中
 
 
 *  文件和目录管理（文件名、文件目录，文件创建与删除）、压缩管理
 */

@interface LogFileManager : NSObject

@singleton( LogFileManager )

/**
 *  存放 log 文件的目录
 */
@property (nonatomic, strong, readonly) NSString *  logFileDirectory;
/**
 *  log文件的名字
 */
@property (nonatomic, strong, readonly) NSString *  zippedLogFilename;
/**
 *  log文件的全路径
 */
@property (nonatomic, strong, readonly) NSString *  zippedLogFilePath;
/**
 *  log文件的压缩包
 
 *  警告：请先调用compressLogFiles，然后才能获取到最新的压缩包的数据
 */
@property (nonatomic, strong, readonly) NSData *    zippedLogFileData;

- (NSData *)compressLogFiles;

- (void)deleteLogFiles;

@end
