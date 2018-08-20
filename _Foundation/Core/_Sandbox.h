
#import <Foundation/Foundation.h>
#import "_Precompile.h"
#import "_Property.h"
#import "_Singleton.h"

#pragma mark -

@interface _Sandbox : NSObject

@singleton( _Sandbox )

/**
 *  应用目录
 */
@prop_strong( NSString *,	appPath );
/**
 *  文档目录
 */
@prop_strong( NSString *,	docPath );
@prop_strong( NSString *,	libPrefPath );
@prop_strong( NSString *,	libCachePath );
@prop_strong( NSString *,	tmpPath );

- (BOOL)touch:(NSString *)path;
- (BOOL)touchFile:(NSString *)file;

/**
 * 应用bundle
 */
+ (NSString *)pathForFilename:(NSString *)filename pod:(NSString *)podName;
+ (NSData *)dataForFilename:(NSString *)filename pod:(NSString *)podName;
+ (NSString *)stringForFilename:(NSString *)filename pod:(NSString *)podName;
// returns the resource bundle path for the specified pod
+ (NSString *)bundlePathForPod:(NSString *)podName;
// return the resource bundle
+ (NSBundle *)bundleForPod:(NSString *)podName;
// returns all assets in the bundle that contains the specified pod
+ (NSArray *)assetsInPod:(NSString *)podName;

@end

#pragma mark - 

@interface _Path : NSObject // fallenink: 要整合到sandbox

#pragma mark - Const

+ (NSString *)documentPath;
+ (NSString *)cachePath;
+ (NSString *)tmpPath;

#pragma mark - Construct

+ (NSString *)documentPathWithName:(NSString *)name;
+ (NSString *)cachePathWithName:(NSString *)name;
+ (NSString *)tmpPathWithName:(NSString *)name;

@end

#pragma mark -

@interface _Path ( Service )

/**
 *  Importantly
 
 *  service as UserId, uuid
 */
+ (void)setService:(NSString *)service;

@end

#pragma mark - TODO: 这里概念不对

@interface _File : NSObject

+ (BOOL)createFolder:(NSString *)dint;

+ (void)remove:(NSString *)path;

+ (void)copyFile:(NSString *)src dint:(NSString *)dint;

+ (int)fileLength: (NSString *) path;

+ (BOOL)fileExit:(NSString *)filepath;

+ (float)folderSizeAtPath:(NSString *)folderPath;

+ (NSArray<NSString *> *)filenamesInDirectory:(NSString *)directory;

/**
 *  将包内文件拷贝到文件沙盒
 *
 *  @param bundlePath 包内路径
 *  @param filePath   文件路径
 *
 *  @return //如果filePath中已存在，则直接返回YES
 //如果bundle和filePath中都不存在，则返回NO
 //如果bundle中存在，则复制到filePath，并返回拷贝结果。
 */
+ (BOOL)copyFileFromBundlePath:(NSString *)bundlePath toFilePath:(NSString *)filePath;

@end
