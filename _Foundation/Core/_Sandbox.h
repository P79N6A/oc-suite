
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

@end
