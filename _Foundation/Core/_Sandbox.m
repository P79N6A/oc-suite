
#import "_Sandbox.h"
#import "NSString+Extension.h"

#pragma mark -

@implementation _Sandbox

@def_singleton_autoload( _Sandbox )

@def_prop_strong( NSString *,	appPath );
@def_prop_strong( NSString *,	docPath );
@def_prop_strong( NSString *,	libPrefPath );
@def_prop_strong( NSString *,	libCachePath );
@def_prop_strong( NSString *,	tmpPath );

- (id)init {
    if (self = [super init]) {
        NSString *execName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
        NSString *execPath = [[NSHomeDirectory() stringByAppendingPathComponent:execName] stringByAppendingPathExtension:@"app"];
        
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *prefPath = [[libPaths objectAtIndex:0] stringByAppendingFormat:@"/Preference"];
        NSString *cachePath = [[libPaths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
        NSString *tmpPath = [[libPaths objectAtIndex:0] stringByAppendingFormat:@"/tmp"];
        
        self.appPath = execPath;
        self.docPath = [docPaths objectAtIndex:0];
        self.tmpPath = tmpPath;
        
        self.libPrefPath = prefPath;
        self.libCachePath = cachePath;
        
        [self touch:self.docPath];
        [self touch:self.tmpPath];
        [self touch:self.libPrefPath];
        [self touch:self.libCachePath];
    }
    return self;
}

- (BOOL)touch:(NSString *)path {
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:NULL];
    }
    
    return YES;
}

- (BOOL)touchFile:(NSString *)file {
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return [[NSFileManager defaultManager] createFileAtPath:file
                                                       contents:[NSData data]
                                                     attributes:nil];
    }
    
    return YES;
}

@end

#pragma mark - 

static const NSString *path_service = nil;

@implementation _Path

#pragma mark - Const

+ (NSString *)documentPath {
    return [self flexiableWithBasePath:path_of_document];
}

+ (NSString *)cachePath {
    return [self flexiableWithBasePath:path_of_cache];
}

+ (NSString *)tmpPath {
    return [self flexiableWithBasePath:path_of_temp];
}

#pragma mark - Construct

+ (NSString *)flexiableWithBasePath:(NSString *)path {
    if ([path_service empty]) {
        return path;
    } else {
        return [path stringByAppendingPathComponent:(NSString *)path_service];
    }
}

+ (NSString *)documentPathWithName:(NSString *)name {
    return [[self documentPath] stringByAppendingPathComponent:name];
}

+ (NSString *)cachePathWithName:(NSString *)name {
    return [[self cachePath] stringByAppendingPathComponent:name];
}

+ (NSString *)tmpPathWithName:(NSString *)name {
    return [[self tmpPath] stringByAppendingPathComponent:name];
}

@end

#pragma mark -

@implementation _Path ( Service )

+ (void)setService:(NSString *)service {
    
    path_service = service;
}

@end

#pragma mark - 

@implementation _File

+ (BOOL)createFolder:(NSString *)dint {
    @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:dint] != YES) {
            [fileManager createDirectoryAtPath:dint withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return TRUE;
    }
    @catch (NSException *exception) {
        return FALSE;
    }
}

+ (void)remove:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path] == YES) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

+ (void)copyFile:(NSString *)src dint:(NSString *)dint {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:src] == YES) {
        
        NSData *temData = [NSData dataWithContentsOfFile:src];
        
        [temData writeToFile:dint atomically:YES];
        
        //		[fileManager copyItemAtPath:src toPath:dint error:nil];
    }
}

+ (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (int)fileLength: (NSString *) path {
    int length = 0;
    
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    if ([fileMgr fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir == NO) {
            NSDictionary * attrs = [fileMgr attributesOfItemAtPath:path error:nil];
            NSNumber * fileSize = [attrs objectForKey:NSFileSize];
            
            if (fileSize != nil) {
                length = [fileSize intValue];
            }
        }
    }
    
    return length;
}

+ (BOOL)fileExit:(NSString *)filepath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSArray<NSString *> *)filenamesInDirectory:(NSString *)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:directory error:nil]];
    return fileList;
}

+ (BOOL)copyFileFromBundlePath:(NSString *)bundlePath toFilePath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath isDirectory:NULL]) {
        return YES;
    }
    if (![manager fileExistsAtPath:bundlePath isDirectory:NULL]) {
        return NO;
    }
    BOOL checkCopyValidData = YES;//判断是否拷贝成功
    NSError *error=nil;
    [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:filePath error:&error ];
    if (error!=nil) {
        NSLog(@"%@", error);
        NSLog(@"%@", [error userInfo]);
        checkCopyValidData = NO;
    }
    return checkCopyValidData;
}


@end

