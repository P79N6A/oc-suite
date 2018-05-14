//
//  _disk_cache.m
//  consumer
//
//  Created by fallen.ink on 6/20/16.
//
//

#import "_disk_cache.h"
#import "_cache_manager.h"

static NSString * const DiskCachePrefix = @"com.fallenink.DiskCache";
static NSString * const DiskCacheSharedName = @"DiskCacheShared";

@interface BackgroundTask : NSObject
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_OS_WATCH
@property (atomic, assign) UIBackgroundTaskIdentifier taskID;
#endif
+ (instancetype)start;
- (void)end;
@end

@interface _DiskCache ()

@property (assign) NSUInteger byteCount;
@property (strong, nonatomic) NSURL *cacheURL;

@property (strong, nonatomic) dispatch_queue_t asyncQueue;
@property (strong, nonatomic) dispatch_semaphore_t lockSemaphore;

@property (strong, nonatomic) NSMutableDictionary *dates;
@property (strong, nonatomic) NSMutableDictionary *sizes;

@end

@implementation _DiskCache

@synthesize willAddObjectBlock = _willAddObjectBlock;
@synthesize willRemoveObjectBlock = _willRemoveObjectBlock;
@synthesize willRemoveAllObjectsBlock = _willRemoveAllObjectsBlock;
@synthesize didAddObjectBlock = _didAddObjectBlock;
@synthesize didRemoveObjectBlock = _didRemoveObjectBlock;
@synthesize didRemoveAllObjectsBlock = _didRemoveAllObjectsBlock;
@synthesize byteLimit = _byteLimit;
@synthesize ageLimit = _ageLimit;
@synthesize ttlCache = _ttlCache;

#if TARGET_OS_IPHONE
@synthesize writingProtectionOption = _writingProtectionOption;
#endif

@def_singleton( _DiskCache )

+ (dispatch_queue_t)sharedQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        queue = dispatch_queue_create([[NSString stringWithFormat:@"%@ Asynchronous Queue", DiskCachePrefix] UTF8String], DISPATCH_QUEUE_CONCURRENT);
    });
    
    return queue;
}

#pragma mark - Life cycle

// 如果需要多文件管理，则用这个，否则没有理由用
//- (instancetype)initWithName:(NSString *)name
//{
//    return [self initWithName:name rootPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
//}

- (instancetype)init {
    if (self = [super init]) {
        [self initDefault];
    }
    
    return self;
}

- (void)initDefault {
    _name = [DiskCacheSharedName copy];
    _asyncQueue = [_DiskCache sharedQueue];
    _lockSemaphore = dispatch_semaphore_create(1);
    
    _willAddObjectBlock = nil;
    _willRemoveObjectBlock = nil;
    _willRemoveAllObjectsBlock = nil;
    _didAddObjectBlock = nil;
    _didRemoveObjectBlock = nil;
    _didRemoveAllObjectsBlock = nil;
    
    _byteCount = 0;
    _byteLimit = 0;
    _ageLimit = 0.0;
    
#if TARGET_OS_IPHONE
    _writingProtectionOption = NSDataWritingFileProtectionNone;
#endif
    
    _dates = [[NSMutableDictionary alloc] init];
    _sizes = [[NSMutableDictionary alloc] init];
    
    NSString *pathComponent = [[NSString alloc] initWithFormat:@"%@.%@", DiskCachePrefix, _name];
    NSString *rootPath = [_CacheManager sharedInstance].rootPath;
    _cacheURL = [NSURL fileURLWithPathComponents:@[ rootPath, pathComponent ]];
    
    //we don't want to do anything without setting up the disk cache, but we also don't want to block init, it can take a while to initialize
    //this is only safe because we use a dispatch_semaphore as a lock. If we switch to an NSLock or posix locks, this will *no longer be safe*.
    
    [self lock];
    
    @weakify(self)
    dispatch_async(_asyncQueue, ^{
        @strongify(self)
        
        [self createCacheDirectory];
        [self initializeDiskProperties];
        
        [self unlock];
    });
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"%@.%@.%p", DiskCachePrefix, _name, self];
}

#pragma mark - Private Methods

- (NSURL *)encodedFileURLForKey:(NSString *)key {
    if (![key length])
        return nil;
    
    return [_cacheURL URLByAppendingPathComponent:[self encodedString:key]];
}

- (NSString *)keyForEncodedFileURL:(NSURL *)url {
    NSString *fileName = [url lastPathComponent];
    if (!fileName)
        return nil;
    
    return [self decodedString:fileName];
}

- (NSString *)encodedString:(NSString *)string {
    if (![string length]) {
        return @"";
    }
    
    if ([string respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        return [string stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@".:/%"] invertedSet]];
    }
    else {
        CFStringRef static const charsToEscape = CFSTR(".:/%");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                            (__bridge CFStringRef)string,
                                                                            NULL,
                                                                            charsToEscape,
                                                                            kCFStringEncodingUTF8);
#pragma clang diagnostic pop
        return (__bridge_transfer NSString *)escapedString;
    }
}

- (NSString *)decodedString:(NSString *)string {
    if (![string length]) {
        return @"";
    }
    
    if ([string respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [string stringByRemovingPercentEncoding];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringRef unescapedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                              (__bridge CFStringRef)string,
                                                                                              CFSTR(""),
                                                                                              kCFStringEncodingUTF8);
#pragma clang diagnostic pop
        return (__bridge_transfer NSString *)unescapedString;
    }
}

#pragma mark - Private Trash Methods

+ (dispatch_queue_t)sharedTrashQueue {
    static dispatch_queue_t trashQueue;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        NSString *queueName = [[NSString alloc] initWithFormat:@"%@.trash", DiskCachePrefix];
        trashQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(trashQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    });
    
    return trashQueue;
}

+ (NSURL *)sharedTrashURL {
    static NSURL *sharedTrashURL;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedTrashURL = [[[NSURL alloc] initFileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:DiskCachePrefix isDirectory:YES];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[sharedTrashURL path]]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtURL:sharedTrashURL
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];
            if (error) LOG(@"%@", error);
        }
    });
    
    return sharedTrashURL;
}

+ (BOOL)moveItemAtURLToTrash:(NSURL *)itemURL {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[itemURL path]])
        return NO;
    
    NSError *error = nil;
    NSString *uniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *uniqueTrashURL = [[_DiskCache sharedTrashURL] URLByAppendingPathComponent:uniqueString];
    BOOL moved = [[NSFileManager defaultManager] moveItemAtURL:itemURL toURL:uniqueTrashURL error:&error];
    
    if (error) LOG(@"%@", error);
    
    return moved;
}

+ (void)emptyTrash {
    dispatch_async([self sharedTrashQueue], ^{
        BackgroundTask *task = [BackgroundTask start];
        
        NSError *searchTrashedItemsError = nil;
        NSArray *trashedItems = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self sharedTrashURL]
                                                              includingPropertiesForKeys:nil
                                                                                 options:0
                                                                                   error:&searchTrashedItemsError];
        if (searchTrashedItemsError) LOG(@"%@", searchTrashedItemsError);
        
        for (NSURL *trashedItemURL in trashedItems) {
            NSError *removeTrashedItemError = nil;
            [[NSFileManager defaultManager] removeItemAtURL:trashedItemURL error:&removeTrashedItemError];
    
            if (removeTrashedItemError) LOG(@"%@", searchTrashedItemsError);
        }
        
        [task end];
    });
}

#pragma mark - Private Queue Methods

- (BOOL)createCacheDirectory {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_cacheURL path]])
        return NO;
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:_cacheURL
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    if (error) LOG(@"%@", error);
    
//    TODO("要做好错误处理")
    
    return success;
}

- (void)initializeDiskProperties {
    NSUInteger byteCount = 0;
    NSArray *keys = @[ NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_cacheURL
                                                   includingPropertiesForKeys:keys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&error];
    if (error) LOG(@"%@", error);
    
    for (NSURL *fileURL in files) {
        NSString *key = [self keyForEncodedFileURL:fileURL];
        
        error = nil;
        NSDictionary *dictionary = [fileURL resourceValuesForKeys:keys error:&error];
        if (error) LOG(@"%@", error);
        
        NSDate *date = [dictionary objectForKey:NSURLContentModificationDateKey];
        if (date && key)
            [_dates setObject:date forKey:key];
        
        NSNumber *fileSize = [dictionary objectForKey:NSURLTotalFileAllocatedSizeKey];
        if (fileSize) {
            [_sizes setObject:fileSize forKey:key];
            byteCount += [fileSize unsignedIntegerValue];
        }
    }
    
    if (byteCount > 0)
        self.byteCount = byteCount; // atomic
}

- (BOOL)setFileModificationDate:(NSDate *)date forURL:(NSURL *)fileURL {
    if (!date || !fileURL) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] setAttributes:@{ NSFileModificationDate: date }
                                                    ofItemAtPath:[fileURL path]
                                                           error:&error];
    if (error) LOG(@"%@", error);
    
    if (success) {
        NSString *key = [self keyForEncodedFileURL:fileURL];
        if (key) {
            [_dates setObject:date forKey:key];
        }
    }
    
    return success;
}

- (BOOL)removeFileAndExecuteBlocksForKey:(NSString *)key {
    NSURL *fileURL = [self encodedFileURLForKey:key];
    if (!fileURL || ![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]])
        return NO;
    
    if (_willRemoveObjectBlock)
        _willRemoveObjectBlock(self, key, nil, fileURL);
    
    BOOL trashed = [_DiskCache moveItemAtURLToTrash:fileURL];
    if (!trashed)
        return NO;
    
    [_DiskCache emptyTrash];
    
    NSNumber *byteSize = [_sizes objectForKey:key];
    if (byteSize)
        self.byteCount = _byteCount - [byteSize unsignedIntegerValue]; // atomic
    
    [_sizes removeObjectForKey:key];
    [_dates removeObjectForKey:key];
    
    if (_didRemoveObjectBlock)
        _didRemoveObjectBlock(self, key, nil, fileURL);
    
    return YES;
}

- (void)trimDiskToSize:(NSUInteger)trimByteCount {
    if (_byteCount <= trimByteCount)
        return;
    
    NSArray *keysSortedBySize = [_sizes keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in [keysSortedBySize reverseObjectEnumerator]) { // largest objects first
        [self removeFileAndExecuteBlocksForKey:key];
        
        if (_byteCount <= trimByteCount)
            break;
    }
}

- (void)trimDiskToSizeByDate:(NSUInteger)trimByteCount {
    if (_byteCount <= trimByteCount)
        return;
    
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByDate) { // oldest objects first
        [self removeFileAndExecuteBlocksForKey:key];
        
        if (_byteCount <= trimByteCount)
            break;
    }
}

- (void)trimDiskToDate:(NSDate *)trimDate {
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByDate) { // oldest files first
        NSDate *accessDate = [_dates objectForKey:key];
        if (!accessDate)
            continue;
        
        if ([accessDate compare:trimDate] == NSOrderedAscending) { // older than trim date
            [self removeFileAndExecuteBlocksForKey:key];
        } else {
            break;
        }
    }
}

- (void)trimToAgeLimitRecursively {
    [self lock];
    NSTimeInterval ageLimit = _ageLimit;
    [self unlock];
    if (ageLimit == 0.0)
        return;
    
    [self lock];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-ageLimit];
    [self trimDiskToDate:date];
    [self unlock];
    
    @weakify(self);
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_ageLimit * NSEC_PER_SEC));
    dispatch_after(time, _asyncQueue, ^(void) {
        @strongify(self);

        [self trimToAgeLimitRecursively];
    });
}

#pragma mark - Public Asynchronous Methods

- (void)lockFileAccessWhileExecutingBlock:(void(^)(_DiskCache *diskCache))block {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        @strongify(self)
        
        if (block) {
            [self lock];
            block(self);
            [self unlock];
        }
    });
}

- (void)containsObjectForKey:(NSString *)key block:(DiskCacheContainsBlock)block {
    if (!key || !block)
        return;
    
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        @strongify(self)
        
        block([self containsObjectForKey:key]);
    });
}

- (void)objectForKey:(NSString *)key block:(DiskCacheObjectBlock)block {
    @weakify(self);
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        NSURL *fileURL = nil;
        id <NSCoding> object = [self objectForKey:key fileURL:&fileURL];
        
        if (block) {
            [self lock];
            block(self, key, object, fileURL);
            [self unlock];
        }
    });
}

- (void)fileURLForKey:(NSString *)key block:(DiskCacheObjectBlock)block {
    @weakify(self);

    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        NSURL *fileURL = [self fileURLForKey:key];
        
        if (block) {
            [self lock];
            block(self, key, nil, fileURL);
            [self unlock];
        }
    });
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(DiskCacheObjectBlock)block {
    @weakify(self);

    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        NSURL *fileURL = nil;
        [self setObject:object forKey:key fileURL:&fileURL];
        
        if (block) {
            [self lock];
            block(self, key, object, fileURL);
            [self unlock];
        }
    });
}

- (void)removeObjectForKey:(NSString *)key block:(DiskCacheObjectBlock)block {
    @weakify(self);

    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        NSURL *fileURL = nil;
        [self removeObjectForKey:key fileURL:&fileURL];
        
        if (block) {
            [self lock];
            block(self, key, nil, fileURL);
            [self unlock];
        }
    });
}

- (void)trimToSize:(NSUInteger)trimByteCount block:(DiskCacheBlock)block {
    @weakify(self);

    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        [self trimToSize:trimByteCount];
        
        if (block) {
            [self lock];
            block(self);
            [self unlock];
        }
    });
}

- (void)trimToDate:(NSDate *)trimDate block:(DiskCacheBlock)block {
    @weakify(self);

    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        [self trimToDate:trimDate];
        
        if (block) {
            [self lock];
            block(self);
            [self unlock];
        }
    });
}

- (void)trimToSizeByDate:(NSUInteger)trimByteCount block:(DiskCacheBlock)block {
    @weakify(self);

    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        [self trimToSizeByDate:trimByteCount];
        
        if (block) {
            [self lock];
            block(self);
            [self unlock];
        }
    });
}

- (void)removeAllObjects:(DiskCacheBlock)block {
    @weakify(self);
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        [self removeAllObjects];
        
        if (block) {
            [self lock];
            block(self);
            [self unlock];
        }
    });
}

- (void)enumerateObjectsWithBlock:(DiskCacheObjectBlock)block completionBlock:(DiskCacheBlock)completionBlock {
    @weakify(self);
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        [self enumerateObjectsWithBlock:block];
        
        if (completionBlock) {
            [self lock];
            completionBlock(self);
            [self unlock];
        }
    });
}

#pragma mark - Public Synchronous Methods

- (void)synchronouslyLockFileAccessWhileExecutingBlock:(void(^)(_DiskCache *diskCache))block {
    if (block) {
        [self lock];
        block(self);
        [self unlock];
    }
}

- (BOOL)containsObjectForKey:(NSString *)key {
    return ([self fileURLForKey:key updateFileModificationDate:NO] != nil);
}

- (id <NSCoding>)objectForKey:(NSString *)key {
    return [self objectForKey:key fileURL:nil];
}

- (__nullable id <NSCoding>)objectForKey:(NSString *)key fileURL:(NSURL **)outFileURL {
    NSDate *now = [[NSDate alloc] init];
    
    if (!key)
        return nil;
    
    id <NSCoding> object = nil;
    NSURL *fileURL = nil;
    
    [self lock];
    fileURL = [self encodedFileURLForKey:key];
    object = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]] &&
        // If the cache should behave like a TTL cache, then only fetch the object if there's a valid ageLimit and  the object is still alive
        (!self->_ttlCache || self->_ageLimit <= 0 || fabs([[_dates objectForKey:key] timeIntervalSinceDate:now]) < self->_ageLimit)) {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithFile:[fileURL path]];
        }
        @catch (NSException *exception) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[fileURL path] error:&error];
            if (error) LOG(@"%@", error);
        }
        if (!self->_ttlCache) {
            [self setFileModificationDate:now forURL:fileURL];
        }
    }
    [self unlock];
    
    if (outFileURL) {
        *outFileURL = fileURL;
    }
    
    return object;
}

/// Helper function to call fileURLForKey:updateFileModificationDate:
- (NSURL *)fileURLForKey:(NSString *)key {
    // Don't update the file modification time, if self is a ttlCache
    return [self fileURLForKey:key updateFileModificationDate:!self->_ttlCache];
}

- (NSURL *)fileURLForKey:(NSString *)key updateFileModificationDate:(BOOL)updateFileModificationDate {
    if (!key) {
        return nil;
    }
    
    NSDate *now = [[NSDate alloc] init];
    NSURL *fileURL = nil;
    
    [self lock];
    fileURL = [self encodedFileURLForKey:key];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        if (updateFileModificationDate) {
            [self setFileModificationDate:now forURL:fileURL];
        }
    } else {
        fileURL = nil;
    }
    [self unlock];
    return fileURL;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key {
    [self setObject:object forKey:key fileURL:nil];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key fileURL:(NSURL **)outFileURL {
    NSDate *now = [[NSDate alloc] init];
    
    if (!key || !object)
        return;
    
    BackgroundTask *task = [BackgroundTask start];
    
#if TARGET_OS_IPHONE
    NSDataWritingOptions writeOptions = NSDataWritingAtomic | self.writingProtectionOption;
#else
    NSDataWritingOptions writeOptions = NSDataWritingAtomic;
#endif
    
    NSURL *fileURL = nil;
    
    [self lock];
    fileURL = [self encodedFileURLForKey:key];
    
    if (self->_willAddObjectBlock)
        self->_willAddObjectBlock(self, key, object, fileURL);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSError *writeError = nil;
    
    BOOL written = [data writeToURL:fileURL options:writeOptions error:&writeError];
    
    if (writeError) LOG(@"%@", writeError);
    
    if (written) {
        [self setFileModificationDate:now forURL:fileURL];
        
        NSError *error = nil;
        NSDictionary *values = [fileURL resourceValuesForKeys:@[ NSURLTotalFileAllocatedSizeKey ] error:&error];
        
        if (error) LOG(@"%@", error);
        
        NSNumber *diskFileSize = [values objectForKey:NSURLTotalFileAllocatedSizeKey];
        if (diskFileSize) {
            NSNumber *prevDiskFileSize = [self->_sizes objectForKey:key];
            if (prevDiskFileSize) {
                self.byteCount = self->_byteCount - [prevDiskFileSize unsignedIntegerValue];
            }
            [self->_sizes setObject:diskFileSize forKey:key];
            self.byteCount = self->_byteCount + [diskFileSize unsignedIntegerValue]; // atomic
        }
        
        if (self->_byteLimit > 0 && self->_byteCount > self->_byteLimit)
            [self trimToSizeByDate:self->_byteLimit block:nil];
    } else {
        fileURL = nil;
    }
    
    if (self->_didAddObjectBlock)
        self->_didAddObjectBlock(self, key, object, written ? fileURL : nil);
    [self unlock];
    
    if (outFileURL) {
        *outFileURL = fileURL;
    }
    
    [task end];
}

- (void)removeObjectForKey:(NSString *)key {
    [self removeObjectForKey:key fileURL:nil];
}

- (void)removeObjectForKey:(NSString *)key fileURL:(NSURL **)outFileURL {
    if (!key)
        return;
    
    BackgroundTask *task = [BackgroundTask start];
    
    NSURL *fileURL = nil;
    
    [self lock];
    fileURL = [self encodedFileURLForKey:key];
    [self removeFileAndExecuteBlocksForKey:key];
    [self unlock];
    
    [task end];
    
    if (outFileURL) {
        *outFileURL = fileURL;
    }
}

- (void)trimToSize:(NSUInteger)byteCount {
    if (byteCount == 0) {
        [self removeAllObjects];
        return;
    }
    
    BackgroundTask *task = [BackgroundTask start];
    
    [self lock];
    [self trimDiskToSize:byteCount];
    [self unlock];
    
    [task end];
}

- (void)trimToDate:(NSDate *)trimDate {
    if (!trimDate)
        return;
    
    if ([trimDate isEqualToDate:[NSDate distantPast]]) {
        [self removeAllObjects];
        return;
    }
    
    BackgroundTask *task = [BackgroundTask start];
    
    [self lock];
    [self trimDiskToDate:trimDate];
    [self unlock];
    
    [task end];
}

- (void)trimToSizeByDate:(NSUInteger)byteCount {
    if (byteCount == 0) {
        [self removeAllObjects];
        return;
    }
    
    BackgroundTask *task = [BackgroundTask start];
    
    [self lock];
    [self trimDiskToSizeByDate:byteCount];
    [self unlock];
    
    [task end];
}

- (void)removeAllObjects {
    BackgroundTask *task = [BackgroundTask start];
    
    [self lock];
    if (self->_willRemoveAllObjectsBlock)
        self->_willRemoveAllObjectsBlock(self);
    
    [_DiskCache moveItemAtURLToTrash:self->_cacheURL];
    [_DiskCache emptyTrash];
    
    [self createCacheDirectory];
    
    [self->_dates removeAllObjects];
    [self->_sizes removeAllObjects];
    self.byteCount = 0; // atomic
    
    if (self->_didRemoveAllObjectsBlock)
        self->_didRemoveAllObjectsBlock(self);
    [self unlock];
    
    [task end];
}

- (void)enumerateObjectsWithBlock:(DiskCacheObjectBlock)block {
    if (!block)
        return;
    
    BackgroundTask *task = [BackgroundTask start];
    
    [self lock];
    NSDate *now = [NSDate date];
    NSArray *keysSortedByDate = [self->_dates keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByDate) {
        NSURL *fileURL = [self encodedFileURLForKey:key];
        // If the cache should behave like a TTL cache, then only fetch the object if there's a valid ageLimit and  the object is still alive
        if (!self->_ttlCache || self->_ageLimit <= 0 || fabs([[_dates objectForKey:key] timeIntervalSinceDate:now]) < self->_ageLimit) {
            block(self, key, nil, fileURL);
        }
    }
    [self unlock];
    
    [task end];
}

#pragma mark - Public Thread Safe Accessors

- (DiskCacheObjectBlock)willAddObjectBlock {
    DiskCacheObjectBlock block = nil;
    
    [self lock];
    block = _willAddObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setWillAddObjectBlock:(DiskCacheObjectBlock)block {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        [self lock];
        self->_willAddObjectBlock = [block copy];
        [self unlock];
    });
}

- (DiskCacheObjectBlock)willRemoveObjectBlock {
    DiskCacheObjectBlock block = nil;
    
    [self lock];
    block = _willRemoveObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setWillRemoveObjectBlock:(DiskCacheObjectBlock)block {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_willRemoveObjectBlock = [block copy];
        [self unlock];
    });
}

- (DiskCacheBlock)willRemoveAllObjectsBlock {
    DiskCacheBlock block = nil;
    
    [self lock];
    block = _willRemoveAllObjectsBlock;
    [self unlock];
    
    return block;
}

- (void)setWillRemoveAllObjectsBlock:(DiskCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_willRemoveAllObjectsBlock = [block copy];
        [self unlock];
    });
}

- (DiskCacheObjectBlock)didAddObjectBlock {
    DiskCacheObjectBlock block = nil;
    
    [self lock];
    block = _didAddObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setDidAddObjectBlock:(DiskCacheObjectBlock)block {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_didAddObjectBlock = [block copy];
        [self unlock];
    });
}

- (DiskCacheObjectBlock)didRemoveObjectBlock {
    DiskCacheObjectBlock block = nil;
    
    [self lock];
    block = _didRemoveObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setDidRemoveObjectBlock:(DiskCacheObjectBlock)block {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_didRemoveObjectBlock = [block copy];
        [self unlock];
    });
}

- (DiskCacheBlock)didRemoveAllObjectsBlock {
    DiskCacheBlock block = nil;
    
    [self lock];
    block = _didRemoveAllObjectsBlock;
    [self unlock];
    
    return block;
}

- (void)setDidRemoveAllObjectsBlock:(DiskCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_didRemoveAllObjectsBlock = [block copy];
        [self unlock];
    });
}

- (NSUInteger)byteLimit {
    NSUInteger byteLimit;
    
    [self lock];
    byteLimit = _byteLimit;
    [self unlock];
    
    return byteLimit;
}

- (void)setByteLimit:(NSUInteger)byteLimit {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_byteLimit = byteLimit;
        
        if (byteLimit > 0)
            [self trimDiskToSizeByDate:byteLimit];
        [self unlock];
    });
}

- (NSTimeInterval)ageLimit {
    NSTimeInterval ageLimit;
    
    [self lock];
    ageLimit = _ageLimit;
    [self unlock];
    
    return ageLimit;
}

- (void)setAgeLimit:(NSTimeInterval)ageLimit {
    @weakify(self)
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_ageLimit = ageLimit;
        [self unlock];
        
        [self trimToAgeLimitRecursively];
    });
}

- (BOOL)isTTLCache {
    BOOL isTTLCache;
    
    [self lock];
    isTTLCache = _ttlCache;
    [self unlock];
    
    return isTTLCache;
}

- (void)setTtlCache:(BOOL)ttlCache {
    @weakify(self);
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        [self lock];
        self->_ttlCache = ttlCache;
        [self unlock];
    });
}

#if TARGET_OS_IPHONE
- (NSDataWritingOptions)writingProtectionOption {
    NSDataWritingOptions option;
    
    [self lock];
    option = _writingProtectionOption;
    [self unlock];
    
    return option;
}

- (void)setWritingProtectionOption:(NSDataWritingOptions)writingProtectionOption {
    @weakify(self);
    
    dispatch_async(_asyncQueue, ^{
        
        @strongify(self);

        if (!self)
            return;
        
        NSDataWritingOptions option = NSDataWritingFileProtectionMask & writingProtectionOption;
        
        [self lock];
        self->_writingProtectionOption = option;
        [self unlock];
    });
}
#endif

- (void)lock {
    dispatch_semaphore_wait(_lockSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_lockSemaphore);
}

#pragma mark - CacheObjectSubscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self setObject:obj forKey:key];
}

@end

#pragma mark - 

@implementation BackgroundTask

+ (BOOL)isAppExtension {
    
    static BOOL isExtension;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSDictionary *extensionDictionary = [[NSBundle mainBundle] infoDictionary][@"NSExtension"];
        isExtension = [extensionDictionary isKindOfClass:[NSDictionary class]];
    });
    
    return isExtension;
}

- (instancetype)init {
    if (self = [super init]) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_OS_WATCH
        _taskID = UIBackgroundTaskInvalid;
#endif
    }
    return self;
}

+ (instancetype)start {
    BackgroundTask *task = nil;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_OS_WATCH
    if ([self.class isAppExtension]) {
        return task;
    }
    
    task = [[self alloc] init];
    
    UIApplication *sharedApplication = [UIApplication performSelector:@selector(sharedApplication)];
    task.taskID = [sharedApplication beginBackgroundTaskWithExpirationHandler:^{
        UIBackgroundTaskIdentifier taskID = task.taskID;
        task.taskID = UIBackgroundTaskInvalid;
        [sharedApplication endBackgroundTask:taskID];
    }];
#endif
    
    return task;
}

- (void)end {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_OS_WATCH
    if ([self.class isAppExtension]) {
        return;
    }
    
    UIBackgroundTaskIdentifier taskID = self.taskID;
    self.taskID = UIBackgroundTaskInvalid;
    
    UIApplication *sharedApplication = [UIApplication performSelector:@selector(sharedApplication)];
    [sharedApplication endBackgroundTask:taskID];
#endif
}

@end
