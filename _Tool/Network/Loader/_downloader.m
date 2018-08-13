//
//  _downloader.m
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//

#import "_precompile.h"
#import "_downloader.h"
#import "_download_request.h"
#import "_download_store.h"

@interface _Downloader () <
    NSURLSessionDelegate,
    NSURLSessionTaskDelegate,
    NSURLSessionDataDelegate,
    NSURLSessionDownloadDelegate,
    NSURLConnectionDelegate
>

@property (nonatomic, strong, nullable) NSURLSession *backgroundSession;
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSNumber *, _DownloadRequest *> *activeDownloadsDictionary;
@property (nonatomic, strong, nonnull) NSMutableArray<NSDictionary <NSString *, NSObject *> *> *waitingDownloadsArray;
@property (nonatomic, weak, nullable) NSObject<_DownloadDelegate>* fileDownloadDelegate;
@property (nonatomic, copy, nullable) BackgroundSessionCompletionHandlerBlock bgSessionCompletionHandlerBlock;
@property (nonatomic, assign) NSInteger maxConcurrentFileDownloadsCount;

@property (nonatomic, assign) NSUInteger highestDownloadID;
@property (nonatomic, strong, nullable) dispatch_queue_t downloadFileSerialWriterDispatchQueue;

@end


@implementation _Downloader

#pragma mark - Initialization

- (nullable instancetype)initWithDelegate:(nonnull NSObject<_DownloadDelegate>*)aDelegate {
    return [self initWithDelegate:aDelegate maxConcurrentDownloads:-1];
}

- (nullable instancetype)initWithDelegate:(nonnull NSObject<_DownloadDelegate>*)aDelegate maxConcurrentDownloads:(NSInteger)aMaxConcurrentFileDownloadsCount {
    self = [super init];
    if (self) {
        self.maxConcurrentFileDownloadsCount = -1;
        if (aMaxConcurrentFileDownloadsCount > 0) {
            self.maxConcurrentFileDownloadsCount = aMaxConcurrentFileDownloadsCount;
        }
        
        self.fileDownloadDelegate = aDelegate;
        self.activeDownloadsDictionary = [NSMutableDictionary dictionary];
        self.waitingDownloadsArray = [NSMutableArray array];
        self.highestDownloadID = 0;
        
        {
            NSString *aBackgroundDownloadSessionIdentifier = [NSString stringWithFormat:@"%@.HWIFileDownload", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
            NSURLSessionConfiguration *aBackgroundSessionConfiguration = nil;
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                aBackgroundSessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:aBackgroundDownloadSessionIdentifier];
            } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                aBackgroundSessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:aBackgroundDownloadSessionIdentifier];
#pragma GCC diagnostic pop
            }
            
            if ([self.fileDownloadDelegate respondsToSelector:@selector(customizeBackgroundSessionConfiguration:)]) {
                [self.fileDownloadDelegate customizeBackgroundSessionConfiguration:aBackgroundSessionConfiguration];
            }
            
            self.backgroundSession = [NSURLSession sessionWithConfiguration:aBackgroundSessionConfiguration
                                                                   delegate:self
                                                              delegateQueue:[NSOperationQueue mainQueue]];
        }
    }
    return self;
}

- (void)setupWithCompletion:(nullable void (^)(void))aSetupCompletionBlock {
    {
        [self.backgroundSession getTasksWithCompletionHandler:^(NSArray * _Nonnull aDataTasksArray, NSArray * _Nonnull anUploadTasksArray, NSArray * _Nonnull aDownloadTasksArray) {
            for (NSURLSessionDownloadTask *aDownloadTask in aDownloadTasksArray) {
                NSString *aDownloadToken = [aDownloadTask.taskDescription copy];
                if (aDownloadToken) {
                    NSProgress *aRootProgress = nil;
                    if ([self.fileDownloadDelegate respondsToSelector:@selector(rootProgress)]) {
                        aRootProgress = [self.fileDownloadDelegate rootProgress];
                    }
                    
                    aRootProgress.totalUnitCount++;
                    [aRootProgress becomeCurrentWithPendingUnitCount:1];
                    _DownloadRequest *aDownloadRequest = [[_DownloadRequest alloc] initWithDownloadToken:aDownloadToken
                                                                                        sessionDownloadTask:aDownloadTask
                                                                                              urlConnection:nil];
                    [aRootProgress resignCurrent];
                    if (aDownloadRequest) {
                        [self.activeDownloadsDictionary setObject:aDownloadRequest forKey:@(aDownloadTask.taskIdentifier)];
                        
                        NSString *aDownloadToken = [aDownloadRequest.downloadToken copy];
                        [aDownloadRequest.progress setPausingHandler:^{
                            [self pauseDownloadWithIdentifier:aDownloadToken];
                        }];
                        
                        [aDownloadRequest.progress setCancellationHandler:^{
                            [self cancelDownloadWithIdentifier:aDownloadToken];
                        }];
                        
                        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
                            [aDownloadRequest.progress setResumingHandler:^{
                                [self resumeDownloadWithIdentifier:aDownloadToken];
                            }];
                        }
                    }
                    
                    [self.fileDownloadDelegate incrementNetworkActivityIndicatorActivityCount];
                } else {
                    LOG(@"ERR: Missing task description (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                }
            }
            
            if (aSetupCompletionBlock) {
                aSetupCompletionBlock();
            }
        }];
    }
}


- (void)dealloc {
    [self.backgroundSession finishTasksAndInvalidate];
}


#pragma mark - Download Start


- (void)startDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                      fromRemoteURL:(nonnull NSURL *)aRemoteURL {
    [self startDownloadWithDownloadToken:aDownloadIdentifier fromRemoteURL:aRemoteURL usingResumeData:nil];
}


- (void)startDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                    usingResumeData:(nonnull NSData *)aResumeData {
    [self startDownloadWithDownloadToken:aDownloadIdentifier fromRemoteURL:nil usingResumeData:aResumeData];
}


- (void)startDownloadWithDownloadToken:(nonnull NSString *)aDownloadToken
                         fromRemoteURL:(nullable NSURL *)aRemoteURL
                       usingResumeData:(nullable NSData *)aResumeData {
    NSUInteger aDownloadID = 0;
    
    if ((self.maxConcurrentFileDownloadsCount == -1) || ((NSInteger)self.activeDownloadsDictionary.count < self.maxConcurrentFileDownloadsCount)) {
        NSURLSessionDownloadTask *aDownloadTask = nil;
        NSURLConnection *aURLConnection = nil;
        
        _DownloadRequest *aDownloadRequest = nil;
        NSProgress *aRootProgress = nil;
        if ([self.fileDownloadDelegate respondsToSelector:@selector(rootProgress)]) {
            aRootProgress = [self.fileDownloadDelegate rootProgress];
        }

        // Create download request
        {
            if (aResumeData) {
                aDownloadTask = [self.backgroundSession downloadTaskWithResumeData:aResumeData];
            } else if (aRemoteURL) {
                aDownloadTask = [self.backgroundSession downloadTaskWithURL:aRemoteURL];
            }
            
            aDownloadID = aDownloadTask.taskIdentifier;
            aDownloadTask.taskDescription = aDownloadToken;
            
            aRootProgress.totalUnitCount++;
            [aRootProgress becomeCurrentWithPendingUnitCount:1];
            aDownloadRequest = [[_DownloadRequest alloc] initWithDownloadToken:aDownloadToken
                                                           sessionDownloadTask:aDownloadTask
                                                                 urlConnection:nil];
            if (aResumeData) {
                aDownloadRequest.resumedFileSizeInBytes = aResumeData.length;
                aDownloadRequest.downloadStartDate = [NSDate date];
                aDownloadRequest.bytesPerSecondSpeed = 0;
            }
            [aRootProgress resignCurrent];
        }
        
        if (aDownloadRequest) {
            [self.activeDownloadsDictionary setObject:aDownloadRequest forKey:@(aDownloadID)];
            NSString *aDownloadToken = [aDownloadRequest.downloadToken copy];
            [aDownloadRequest.progress setPausingHandler:^{
                [self pauseDownloadWithIdentifier:aDownloadToken];
            }];
            [aDownloadRequest.progress setCancellationHandler:^{
                [self cancelDownloadWithIdentifier:aDownloadToken];
            }];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
                [aDownloadRequest.progress setResumingHandler:^{
                    [self resumeDownloadWithIdentifier:aDownloadToken];
                }];
            }
            
            [self.fileDownloadDelegate incrementNetworkActivityIndicatorActivityCount];
            
            {
                [aDownloadTask resume];
            }
        } else {
            LOG(@"ERR: No download item (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
    } else {
        NSMutableDictionary *aWaitingDownloadDict = [NSMutableDictionary dictionary];
        [aWaitingDownloadDict setObject:aDownloadToken forKey:@"downloadToken"];
        if (aResumeData) {
            [aWaitingDownloadDict setObject:aResumeData forKey:@"resumeData"];
        } else if (aRemoteURL) {
            [aWaitingDownloadDict setObject:aRemoteURL forKey:@"remoteURL"];
        }
        
        [self.waitingDownloadsArray addObject:aWaitingDownloadDict];
    }
}


- (void)resumeDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier {
    BOOL isDownloading = [self isDownloadingIdentifier:aDownloadIdentifier];
    if (isDownloading == NO) {
        if ([self.fileDownloadDelegate respondsToSelector:@selector(downloadResumeWithIdentifier:)]) {
            [self.fileDownloadDelegate downloadResumeWithIdentifier:aDownloadIdentifier];
        } else {
            LOG(@"ERR: Resume action called without implementation (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
    }
}


#pragma mark - Download Stop


- (void)pauseDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier {
    BOOL isDownloading = [self isDownloadingIdentifier:aDownloadIdentifier];
    if (isDownloading) {
        [self pauseDownloadWithIdentifier:aDownloadIdentifier resumeDataBlock:^(NSData *aResumeData) {
            if ([self.fileDownloadDelegate respondsToSelector:@selector(downloadPausedWithIdentifier:resumeData:)]) {
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
                    // resume data is managed by the system and used when calling resume with NSProgress
                    aResumeData = nil;
                }
                
                [self.fileDownloadDelegate downloadPausedWithIdentifier:aDownloadIdentifier
                                                             resumeData:aResumeData];
            }
        }];
    }
}

- (void)pauseDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier resumeDataBlock:(nullable DownloaderPauseResumeDataBlock)aResumeDataBlock {
    NSInteger aDownloadID = [self downloadIDForActiveDownloadToken:aDownloadIdentifier];
    if (aDownloadID > -1) {
        [self pauseDownloadWithDownloadID:aDownloadID resumeDataBlock:aResumeDataBlock];
    } else {
        NSInteger aFoundIndex = -1;
        for (NSUInteger anIndex = 0; anIndex < self.waitingDownloadsArray.count; anIndex++) {
            NSDictionary *aWaitingDownloadDict = self.waitingDownloadsArray[anIndex];
            if ([aWaitingDownloadDict[@"downloadToken"] isEqualToString:aDownloadIdentifier]) {
                aFoundIndex = anIndex;
                break;
            }
            
            aFoundIndex++;
        }
        
        if (aFoundIndex > -1) {
            [self.waitingDownloadsArray removeObjectAtIndex:aFoundIndex];
        }
    }
}


- (void)pauseDownloadWithDownloadID:(NSUInteger)aDownloadID resumeDataBlock:(nullable DownloaderPauseResumeDataBlock)aResumeDataBlock {
    _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadID)];
    if (aDownloadRequest) {
        NSURLSessionDownloadTask *aDownloadTask = aDownloadRequest.sessionDownloadTask;
        if (aDownloadTask) {
            if (aResumeDataBlock) {
                [aDownloadTask cancelByProducingResumeData:^(NSData *aResumeData) {
                    aResumeDataBlock(aResumeData);
                }];
            } else {
                [aDownloadTask cancel];
            }
            // NSURLSessionTaskDelegate method is called
            // URLSession:task:didCompleteWithError:
        } else {
            LOG(@"INFO: NSURLSessionDownloadTask cancelled (task not found): %@ (%@, %d)", aDownloadRequest.downloadToken, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
            NSError *aPauseError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            [self handleDownloadWithError:aPauseError downloadItem:aDownloadRequest downloadID:aDownloadID resumeData:nil];
        }
    }
}


- (void)cancelDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    NSInteger aDownloadID = [self downloadIDForActiveDownloadToken:aDownloadIdentifier];
    if (aDownloadID > -1)
    {
        [self cancelDownloadWithDownloadID:aDownloadID];
    }
    else
    {
        NSInteger aFoundIndex = -1;
        for (NSUInteger anIndex = 0; anIndex < self.waitingDownloadsArray.count; anIndex++)
        {
            NSDictionary *aWaitingDownloadDict = self.waitingDownloadsArray[anIndex];
            if ([aWaitingDownloadDict[@"downloadToken"] isEqualToString:aDownloadIdentifier])
            {
                aFoundIndex = anIndex;
                break;
            }
            aFoundIndex++;
        }
        if (aFoundIndex > -1)
        {
            [self.waitingDownloadsArray removeObjectAtIndex:aFoundIndex];
            
            NSError *aCancelledError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            [self.fileDownloadDelegate downloadFailedWithIdentifier:aDownloadIdentifier
                                                              error:aCancelledError
                                                     httpStatusCode:0
                                                 errorMessagesStack:nil
                                                         resumeData:nil];
            [self startNextWaitingDownload];
        }
    }
}


- (void)cancelDownloadWithDownloadID:(NSUInteger)aDownloadID {
    _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadID)];
    if (aDownloadRequest) {
        
        {
            NSURLSessionDownloadTask *aDownloadTask = aDownloadRequest.sessionDownloadTask;
            if (aDownloadTask) {
                [aDownloadTask cancel];
                // NSURLSessionTaskDelegate method is called
                // URLSession:task:didCompleteWithError:
            } else {
                LOG(@"INFO: NSURLSessionDownloadTask cancelled (task not found): %@ (%@, %d)", aDownloadRequest.downloadToken, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                NSError *aCancelError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
                [self handleDownloadWithError:aCancelError downloadItem:aDownloadRequest downloadID:aDownloadID resumeData:nil];
            }
        }
    }
}


- (void)cancelURLConnection:(NSURLConnection *)aDownloadURLConnection downloadID:(NSUInteger)aDownloadID
{
    [aDownloadURLConnection cancel];
    // delegate method is not necessarily called
    
    NSURL *aTempFileURL = [self tempLocalFileURLForDownloadFromURL:aDownloadURLConnection.originalRequest.URL];
    __weak _Downloader *weakSelf = self;
    dispatch_async(self.downloadFileSerialWriterDispatchQueue, ^{
        _Downloader *strongSelf = weakSelf;
        NSError *aRemoveError = nil;
        [[NSFileManager defaultManager] removeItemAtURL:aTempFileURL error:&aRemoveError];
        if (aRemoveError)
        {
            LOG(@"ERR: Unable to remove file at %@: %@ (%@, %d)", aTempFileURL, aRemoveError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
        __weak _Downloader *anotherWeakSelf = strongSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            _Downloader *anotherStrongSelf = anotherWeakSelf;
            _DownloadRequest *aFoundDownloadItem = [strongSelf.activeDownloadsDictionary objectForKey:@(aDownloadID)];
            if (aFoundDownloadItem)
            {
                LOG(@"INFO: NSURLConnection cancelled: %@", aFoundDownloadItem.downloadToken);
                NSError *aCancelError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
                [anotherStrongSelf handleDownloadWithError:aCancelError downloadItem:aFoundDownloadItem downloadID:aDownloadID resumeData:nil];
            }
        });
    });
}


#pragma mark - Download Status

- (BOOL)isDownloadingIdentifier:(nonnull NSString *)aDownloadIdentifier {
    BOOL isDownloading = NO;
    NSInteger aDownloadID = [self downloadIDForActiveDownloadToken:aDownloadIdentifier];
    if (aDownloadID > -1) {
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadID)];
        if (aDownloadRequest) {
            isDownloading = YES;
        }
    }
    
    if (isDownloading == NO) {
        for (NSDictionary *aWaitingDownloadDict in self.waitingDownloadsArray) {
            if ([aWaitingDownloadDict[@"downloadToken"] isEqualToString:aDownloadIdentifier]) {
                isDownloading = YES;
                break;
            }
        }
    }
    
    return isDownloading;
}


- (BOOL)isWaitingForDownloadOfIdentifier:(nonnull NSString *)aDownloadIdentifier {
    BOOL isWaitingForDownload = NO;
    for (NSDictionary *aWaitingDownloadDict in self.waitingDownloadsArray) {
        if ([aWaitingDownloadDict[@"downloadToken"] isEqualToString:aDownloadIdentifier]) {
            isWaitingForDownload = YES;
            break;
        }
    }
    
    NSInteger aDownloadID = [self downloadIDForActiveDownloadToken:aDownloadIdentifier];
    if (aDownloadID > -1) {
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadID)];
        if (aDownloadRequest && (aDownloadRequest.receivedFileSizeInBytes == 0)) {
            isWaitingForDownload = YES;
        }
    }
    return isWaitingForDownload;
}


- (BOOL)hasActiveDownloads {
    BOOL aHasActiveDownloadsFlag = NO;
    if ((self.activeDownloadsDictionary.count > 0) || (self.waitingDownloadsArray.count > 0)) {
        aHasActiveDownloadsFlag = YES;
    }
    return aHasActiveDownloadsFlag;
}


- (nonnull NSURL *)tempLocalFileURLForDownloadFromURL:(nonnull NSURL *)aRemoteURL {
    NSString *anOfflineDownloadDirectory = NSTemporaryDirectory();
    TODO("该文件夹，可以设置在_downloader_config中去")
    anOfflineDownloadDirectory = [anOfflineDownloadDirectory stringByAppendingPathComponent:@"file-download"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:anOfflineDownloadDirectory] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:anOfflineDownloadDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSURL *anOfflineDownloadDirectoryURL = [NSURL fileURLWithPath:anOfflineDownloadDirectory isDirectory:YES];
    [anOfflineDownloadDirectoryURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:NULL];
    
    NSString *aFilePathName = [anOfflineDownloadDirectory stringByAppendingPathComponent:[aRemoteURL lastPathComponent]];
    NSURL *aLocalFileURL = [NSURL fileURLWithPath:aFilePathName isDirectory:NO];
    return aLocalFileURL;
}

#pragma mark - BackgroundSessionCompletionHandler

- (void)setBackgroundSessionCompletionHandlerBlock:(nullable BackgroundSessionCompletionHandlerBlock)aBackgroundSessionCompletionHandlerBlock {
    self.bgSessionCompletionHandlerBlock = aBackgroundSessionCompletionHandlerBlock;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(nonnull NSURLSession *)aSession downloadTask:(nonnull NSURLSessionDownloadTask *)aDownloadTask didFinishDownloadingToURL:(nonnull NSURL *)aDownloadURL {
    NSString *anErrorString = nil;
    _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadTask.taskIdentifier)];
    if (aDownloadRequest) {
        // move download item to final local location
        
        NSURL *aLocalDestinationFileURL = nil;
        if ([self.fileDownloadDelegate respondsToSelector:@selector(localFileURLForIdentifier:remoteURL:)]) {
            NSURL *aRemoteURL = [[aDownloadTask.originalRequest URL] copy];
            if (aRemoteURL) {
                aLocalDestinationFileURL = [self.fileDownloadDelegate localFileURLForIdentifier:aDownloadRequest.downloadToken remoteURL:aRemoteURL];
            } else {
                anErrorString = [NSString stringWithFormat:@"ERR: Missing information: Remote URL (token: %@) (%@, %d)", aDownloadRequest.downloadToken, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                LOG(@"%@", anErrorString);
            }
        } else {
            aLocalDestinationFileURL = [_Downloader localFileURLForRemoteURL:aDownloadTask.originalRequest.URL];
        }
        
        if (aLocalDestinationFileURL) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:aLocalDestinationFileURL.path] == YES) {
                NSError *aRemoveError = nil;
                [[NSFileManager defaultManager] removeItemAtURL:aLocalDestinationFileURL error:&aRemoveError];
                if (aRemoveError) {
                    anErrorString = [NSString stringWithFormat:@"ERR: Error on removing file at %@: %@ (%@, %d)", aLocalDestinationFileURL, aRemoveError, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                    LOG(@"%@", anErrorString);
                }
            }
            
            NSError *anError = nil;
            BOOL aSuccessFlag = [[NSFileManager defaultManager] moveItemAtURL:aDownloadURL toURL:aLocalDestinationFileURL error:&anError];
            if (aSuccessFlag == NO) {
                NSError *aMoveError = anError;
                if (aMoveError == nil) {
                    aMoveError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCannotMoveFile userInfo:nil];
                }
                
                anErrorString = [NSString stringWithFormat:@"ERR: Unable to move file from %@ to %@ (%@) (%@, %d)", aDownloadURL, aLocalDestinationFileURL, aMoveError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                
                LOG(@"%@", anErrorString);
            } else {
                NSError *anError = nil;
                NSDictionary *aFileAttributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:aLocalDestinationFileURL.path error:&anError];
                if (anError) {
                    anErrorString = [NSString stringWithFormat:@"ERR: Error on getting file size for item at %@: %@ (%@, %d)", aLocalDestinationFileURL, anError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                    LOG(@"%@", anErrorString);
                } else {
                    unsigned long long aFileSize = [aFileAttributesDictionary fileSize];
                    if (aFileSize == 0) {
                        NSError *aFileSizeZeroError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:nil];
                        anErrorString = [NSString stringWithFormat:@"ERR: Zero file size for item at %@: %@ (%@, %d)", aLocalDestinationFileURL, aFileSizeZeroError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                        LOG(@"%@", anErrorString);
                    } else {
                        if ([self.fileDownloadDelegate respondsToSelector:@selector(downloadAtLocalFileURL:isValidForDownloadIdentifier:)]) {
                            BOOL anIsValidDownloadFlag = [self.fileDownloadDelegate downloadAtLocalFileURL:aLocalDestinationFileURL isValidForDownloadIdentifier:aDownloadRequest.downloadToken];
                            if (anIsValidDownloadFlag == NO) {
                                anErrorString = [NSString stringWithFormat:@"ERR: Download check failed for item at %@", aLocalDestinationFileURL];
                                LOG(@"%@", anErrorString);
                            }
                        }
                    }
                }
            }
        } else {
            anErrorString = [NSString stringWithFormat:@"ERR: Missing information: Local file URL (token: %@) (%@, %d)", aDownloadRequest.downloadToken, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
            LOG(@"%@", anErrorString);
        }
        
        if (anErrorString) {
            NSMutableArray<NSString *> *anErrorMessagesStackArray = [aDownloadRequest.errorMessagesStack mutableCopy];
            if (anErrorMessagesStackArray == nil) {
                anErrorMessagesStackArray = [NSMutableArray array];
            }
            [anErrorMessagesStackArray insertObject:anErrorString atIndex:0];
            [aDownloadRequest setErrorMessagesStack:anErrorMessagesStackArray];
        } else {
            aDownloadRequest.finalLocalFileURL = aLocalDestinationFileURL;
        }
    } else {
        LOG(@"ERR: Missing download item for taskIdentifier: %@ (%@, %d)", @(aDownloadTask.taskIdentifier), [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}


- (void)URLSession:(nonnull NSURLSession *)aSession downloadTask:(nonnull NSURLSessionDownloadTask *)aDownloadTask didWriteData:(int64_t)aBytesWrittenCount totalBytesWritten:(int64_t)aTotalBytesWrittenCount totalBytesExpectedToWrite:(int64_t)aTotalBytesExpectedToWriteCount
{
    _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadTask.taskIdentifier)];
    if (aDownloadRequest)
    {
        if (aDownloadRequest.downloadStartDate == nil)
        {
            aDownloadRequest.downloadStartDate = [NSDate date];
        }
        aDownloadRequest.receivedFileSizeInBytes = aTotalBytesWrittenCount;
        aDownloadRequest.expectedFileSizeInBytes = aTotalBytesExpectedToWriteCount;
        if ([self.fileDownloadDelegate respondsToSelector:@selector(downloadProgressChangedForIdentifier:)])
        {
            NSString *aTaskDescription = [aDownloadTask.taskDescription copy];
            if (aTaskDescription)
            {
                [self.fileDownloadDelegate downloadProgressChangedForIdentifier:aTaskDescription];
            }
        }
    }
}


- (void)URLSession:(nonnull NSURLSession *)aSession downloadTask:(nonnull NSURLSessionDownloadTask *)aDownloadTask didResumeAtOffset:(int64_t)aFileOffset expectedTotalBytes:(int64_t)aTotalBytesExpectedCount
{
    _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadTask.taskIdentifier)];
    if (aDownloadRequest)
    {
        aDownloadRequest.resumedFileSizeInBytes = aFileOffset;
        aDownloadRequest.downloadStartDate = [NSDate date];
        aDownloadRequest.bytesPerSecondSpeed = 0;
        LOG(@"INFO: Download (id: %@) resumed (offset: %@ bytes, expected: %@ bytes", aDownloadTask.taskDescription, @(aFileOffset), @(aTotalBytesExpectedCount));
    }
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(nonnull NSURLSession *)aSession task:(nonnull NSURLSessionTask *)aDownloadTask didCompleteWithError:(nullable NSError *)anError {
    _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadTask.taskIdentifier)];
    if (aDownloadRequest) {
        NSHTTPURLResponse *aHttpResponse = (NSHTTPURLResponse *)aDownloadTask.response;
        NSInteger aHttpStatusCode = aHttpResponse.statusCode;
        aDownloadRequest.lastHttpStatusCode = aHttpStatusCode;
        if (anError == nil) {
            BOOL aHttpStatusCodeIsCorrectFlag = NO;
            if ([self.fileDownloadDelegate respondsToSelector:@selector(httpStatusCode:isValidForDownloadIdentifier:)]) {
                aHttpStatusCodeIsCorrectFlag = [self.fileDownloadDelegate httpStatusCode:aHttpStatusCode isValidForDownloadIdentifier:aDownloadRequest.downloadToken];
            } else {
                aHttpStatusCodeIsCorrectFlag = [_Downloader httpStatusCode:aHttpStatusCode isValidForDownloadIdentifier:aDownloadRequest.downloadToken];
            }
            
            if (aHttpStatusCodeIsCorrectFlag == YES) {
                NSURL *aFinalLocalFileURL = aDownloadRequest.finalLocalFileURL;
                if (aFinalLocalFileURL) {
                    [self handleSuccessfulDownloadToLocalFileURL:aFinalLocalFileURL
                                                    downloadItem:aDownloadRequest
                                                      downloadID:aDownloadTask.taskIdentifier];
                } else {
                    NSError *aFinalError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:nil];
                    [self handleDownloadWithError:aFinalError downloadItem:aDownloadRequest downloadID:aDownloadTask.taskIdentifier resumeData:nil];
                }
            } else {
                NSString *anErrorString = [NSString stringWithFormat:@"Invalid http status code: %@", @(aHttpStatusCode)];
                NSMutableArray<NSString *> *anErrorMessagesStackArray = [aDownloadRequest.errorMessagesStack mutableCopy];
                if (anErrorMessagesStackArray == nil) {
                    anErrorMessagesStackArray = [NSMutableArray array];
                }
                
                [anErrorMessagesStackArray insertObject:anErrorString atIndex:0];
                [aDownloadRequest setErrorMessagesStack:anErrorMessagesStackArray];
                
                NSError *aFinalError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil];
                [self handleDownloadWithError:aFinalError downloadItem:aDownloadRequest downloadID:aDownloadTask.taskIdentifier resumeData:nil];
            }
        } else {
            NSData *aSessionDownloadTaskResumeData = [anError.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            //NSString *aFailingURLStringErrorKeyString = [anError.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
            //NSNumber *aBackgroundTaskCancelledReasonKeyNumber = [anError.userInfo objectForKey:NSURLErrorBackgroundTaskCancelledReasonKey];
            
            [self handleDownloadWithError:anError downloadItem:aDownloadRequest downloadID:aDownloadTask.taskIdentifier resumeData:aSessionDownloadTaskResumeData];
        }
    } else {
        LOG(@"ERR: Download item not found for download task: %@ (%@, %d)", aDownloadTask, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)URLSession:(NSURLSession *)aSession
              task:(NSURLSessionTask *)aTask
didReceiveChallenge:(NSURLAuthenticationChallenge *)aChallenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))aCompletionHandler {
    if ([self.fileDownloadDelegate respondsToSelector:@selector(onAuthenticationChallenge:downloadIdentifier:completionHandler:)]) {
        NSString *aDownloadToken = [aTask.taskDescription copy];
        if (aDownloadToken) {
            [self.fileDownloadDelegate onAuthenticationChallenge:aChallenge
                                              downloadIdentifier:aDownloadToken
                                               completionHandler:^(NSURLCredential * _Nullable aCredential, NSURLSessionAuthChallengeDisposition aDisposition) {
                                                   aCompletionHandler(aDisposition, aCredential);
                                               }];
        } else {
            LOG(@"ERR: Missing task description (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
            aCompletionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    } else {
        LOG(@"ERR: Received authentication challenge with no delegate method implemented (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        aCompletionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

#pragma mark - NSURLSessionDelegate


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)aSession {
    if (self.bgSessionCompletionHandlerBlock) {
        void (^completionHandler)() = self.bgSessionCompletionHandlerBlock;
        self.bgSessionCompletionHandlerBlock = nil;
        completionHandler();
    }
}

- (void)URLSession:(NSURLSession *)aSession didBecomeInvalidWithError:(nullable NSError *)anError {
    LOG(@"ERR: URL session did become invalid with error: %@ (%@, %d)", anError, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
}


#pragma mark - NSURLConnection
#pragma mark - NSURLConnectionDataDelegate

- (void)connectionDidFinishLoading:(nonnull NSURLConnection *)aConnection {
    NSNumber *aDownloadID = [self downloadIDForConnection:aConnection];
    if (aDownloadID) {
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:aDownloadID];
        
        if (aDownloadRequest) {
            NSURL *aLocalFileURL = nil;
            if ([self.fileDownloadDelegate respondsToSelector:@selector(localFileURLForIdentifier:remoteURL:)]) {
                aLocalFileURL = [self.fileDownloadDelegate localFileURLForIdentifier:aDownloadRequest.downloadToken remoteURL:aConnection.originalRequest.URL];
            } else {
                aLocalFileURL = [_Downloader localFileURLForRemoteURL:aConnection.originalRequest.URL];
            }
            
            if (aLocalFileURL) {
                
                NSURL *aTempFileURL = [self tempLocalFileURLForDownloadFromURL:aConnection.originalRequest.URL];
                
                __weak _Downloader *weakSelf = self;
                dispatch_async(self.downloadFileSerialWriterDispatchQueue, ^{
                    
                    _Downloader *strongSelf = weakSelf;
                    
                    NSError *aMoveError = nil;
                    BOOL aMoveSuccessFlag = [[NSFileManager defaultManager] moveItemAtURL:aTempFileURL toURL:aLocalFileURL error:&aMoveError];
                    if (aMoveSuccessFlag == NO) {
                        NSString *anUnableToMoveErrorString = [NSString stringWithFormat:@"ERR: Unable to move file from %@ to %@ (%@) (%@, %d)", aTempFileURL, aLocalFileURL, aMoveError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                        LOG(@"%@", anUnableToMoveErrorString);
                        NSMutableArray<NSString *> *anErrorMessagesStackArray = [aDownloadRequest.errorMessagesStack mutableCopy];
                        if (anErrorMessagesStackArray == nil)
                        {
                            anErrorMessagesStackArray = [NSMutableArray array];
                        }
                        [anErrorMessagesStackArray insertObject:anUnableToMoveErrorString atIndex:0];
                        [aDownloadRequest setErrorMessagesStack:anErrorMessagesStackArray];
                        
                        __weak _Downloader *anotherWeakSelf = strongSelf;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _Downloader *anotherStrongSelf = anotherWeakSelf;
                            if ([self isDownloadingIdentifier:aDownloadRequest.downloadToken]) // check for meanwhile cancelled download
                            {
                                [anotherStrongSelf handleDownloadWithError:aMoveError downloadItem:aDownloadRequest downloadID:[aDownloadID unsignedIntegerValue] resumeData:nil];
                            }
                        });
                    } else {
                        __weak _Downloader *anotherWeakSelf = strongSelf;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            _Downloader *anotherStrongSelf = anotherWeakSelf;
                            
                            if ([self isDownloadingIdentifier:aDownloadRequest.downloadToken] == NO) {
                                // download has been cancelled meanwhile
                                NSError *aRemoveError = nil;
                                BOOL aRemoveSuccessFlag = [[NSFileManager defaultManager] removeItemAtURL:aLocalFileURL error:&aRemoveError];
                                if (aRemoveSuccessFlag == NO) {
                                    LOG(@"ERR: Unable to remove file at %@ (%@) (%@, %d)", aLocalFileURL, aRemoveError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                                }
                            } else {
                                NSError *aFileAttributesError = nil;
                                NSDictionary *aFileAttributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:aLocalFileURL.path error:&aFileAttributesError];
                                if (aFileAttributesError) {
                                    NSString *FileAttributesErrorString = [NSString stringWithFormat:@"ERR: Error on getting file size for item at %@: %@ (%@, %d)", aLocalFileURL, aFileAttributesError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                                    LOG(@"%@", FileAttributesErrorString);
                                    NSMutableArray<NSString *> *anErrorMessagesStackArray = [aDownloadRequest.errorMessagesStack mutableCopy];
                                    if (anErrorMessagesStackArray == nil)
                                    {
                                        anErrorMessagesStackArray = [NSMutableArray array];
                                    }
                                    [anErrorMessagesStackArray insertObject:FileAttributesErrorString atIndex:0];
                                    [aDownloadRequest setErrorMessagesStack:anErrorMessagesStackArray];
                                    
                                    [anotherStrongSelf handleDownloadWithError:aFileAttributesError downloadItem:aDownloadRequest downloadID:[aDownloadID unsignedIntegerValue] resumeData:nil];
                                }
                                else
                                {
                                    unsigned long long aFileSize = [aFileAttributesDictionary fileSize];
                                    if (aFileSize == 0)
                                    {
                                        NSError *aFileSizeZeroError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:nil];
                                        NSString *aFileSizeZeroErrorString = [NSString stringWithFormat:@"ERR: Zero file size for item at %@: %@ (%@, %d)", aLocalFileURL, aFileSizeZeroError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                                        LOG(@"%@", aFileSizeZeroErrorString);
                                        NSMutableArray<NSString *> *anErrorMessagesStackArray = [aDownloadRequest.errorMessagesStack mutableCopy];
                                        if (anErrorMessagesStackArray == nil)
                                        {
                                            anErrorMessagesStackArray = [NSMutableArray array];
                                        }
                                        [anErrorMessagesStackArray insertObject:aFileSizeZeroErrorString atIndex:0];
                                        [aDownloadRequest setErrorMessagesStack:anErrorMessagesStackArray];
                                        
                                        [anotherStrongSelf handleDownloadWithError:aFileSizeZeroError downloadItem:aDownloadRequest downloadID:[aDownloadID unsignedIntegerValue] resumeData:nil];
                                    }
                                    else
                                    {
                                        aDownloadRequest.finalLocalFileURL = aLocalFileURL;
                                        if ([self.fileDownloadDelegate respondsToSelector:@selector(downloadAtLocalFileURL:isValidForDownloadIdentifier:)])
                                        {
                                            BOOL anIsValidDownloadFlag = [self.fileDownloadDelegate downloadAtLocalFileURL:aLocalFileURL isValidForDownloadIdentifier:aDownloadRequest.downloadToken];
                                            if (anIsValidDownloadFlag)
                                            {
                                                [anotherStrongSelf handleSuccessfulDownloadToLocalFileURL:aLocalFileURL
                                                                                             downloadItem:aDownloadRequest
                                                                                               downloadID:[aDownloadID unsignedIntegerValue]];
                                            }
                                            else
                                            {
                                                NSError *aValidationError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCannotDecodeRawData userInfo:nil];
                                                NSString *aValidationErrorString = [NSString stringWithFormat:@"WARN: Download check failed for item at %@: %@ (%@, %d)", aLocalFileURL, aValidationError, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                                                LOG(@"%@", aValidationErrorString);
                                                NSMutableArray<NSString *> *anErrorMessagesStackArray = [aDownloadRequest.errorMessagesStack mutableCopy];
                                                if (anErrorMessagesStackArray == nil)
                                                {
                                                    anErrorMessagesStackArray = [NSMutableArray array];
                                                }
                                                [anErrorMessagesStackArray insertObject:aValidationErrorString atIndex:0];
                                                [aDownloadRequest setErrorMessagesStack:anErrorMessagesStackArray];
                                                [anotherStrongSelf handleDownloadWithError:aValidationError downloadItem:aDownloadRequest downloadID:[aDownloadID unsignedIntegerValue] resumeData:nil];
                                            }
                                        }
                                        else
                                        {
                                            [anotherStrongSelf handleSuccessfulDownloadToLocalFileURL:aLocalFileURL
                                                                                         downloadItem:aDownloadRequest
                                                                                           downloadID:[aDownloadID unsignedIntegerValue]];
                                        }
                                    }
                                }
                            }
                        });
                    }
                    
                });
                
            } else {
                NSString *aMissingURLErrorString = [NSString stringWithFormat:@"ERR: Missing information: Local file URL (token: %@) (%@, %d)", aDownloadRequest.downloadToken, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__];
                LOG(@"%@", aMissingURLErrorString);
                NSMutableArray<NSString *> *anErrorMessagesStackArray = [aDownloadRequest.errorMessagesStack mutableCopy];
                if (anErrorMessagesStackArray == nil)
                {
                    anErrorMessagesStackArray = [NSMutableArray array];
                }
                [anErrorMessagesStackArray insertObject:aMissingURLErrorString atIndex:0];
                [aDownloadRequest setErrorMessagesStack:anErrorMessagesStackArray];
                NSError *aMissingURLError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
                [self handleDownloadWithError:aMissingURLError downloadItem:aDownloadRequest downloadID:[aDownloadID unsignedIntegerValue] resumeData:nil];
            }
        } else {
            LOG(@"ERR: No download item found on URL connection finish (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
    } else {
        LOG(@"ERR: No download id found on URL connection finish (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}


- (void)connection:(nonnull NSURLConnection *)aConnection didReceiveResponse:(nonnull NSURLResponse *)aResponse {
    NSNumber *aFoundDownloadID = [self downloadIDForConnection:aConnection];
    if (aFoundDownloadID) {
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:aFoundDownloadID];
        if (aDownloadRequest) {
            if (aDownloadRequest.downloadStartDate == nil) {
                aDownloadRequest.downloadStartDate = [NSDate date];
            }
            
            long long anExpectedContentLength = [aResponse expectedContentLength];
            if (anExpectedContentLength > 0) {
                aDownloadRequest.expectedFileSizeInBytes = anExpectedContentLength;
            }
            
            NSHTTPURLResponse *aHttpResponse = (NSHTTPURLResponse *)aResponse;
            aDownloadRequest.lastHttpStatusCode = aHttpResponse.statusCode;
        }
    }
}

- (void)connection:(nonnull NSURLConnection *)aConnection didReceiveData:(nonnull NSData *)aData {
    NSNumber *aFoundDownloadID = [self downloadIDForConnection:aConnection];
    if (aFoundDownloadID) {
        NSURL *aTempFileURL = [self tempLocalFileURLForDownloadFromURL:aConnection.originalRequest.URL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:aTempFileURL.path] == NO) {
            dispatch_async(self.downloadFileSerialWriterDispatchQueue, ^{
                [[NSFileManager defaultManager] createFileAtPath:aTempFileURL.path contents:nil attributes:nil];
            });
        }
        
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:aFoundDownloadID];
        if (aDownloadRequest) {
            if (aDownloadRequest.downloadStartDate == nil) {
                aDownloadRequest.downloadStartDate = [NSDate date];
            }
            int64_t anUntilNowReceivedContentSize = aDownloadRequest.receivedFileSizeInBytes;
            int64_t aCompleteReceivedContentSize = anUntilNowReceivedContentSize + [aData length];
            aDownloadRequest.receivedFileSizeInBytes = aCompleteReceivedContentSize;
            
            if ([self.fileDownloadDelegate respondsToSelector:@selector(downloadProgressChangedForIdentifier:)]) {
                NSString *aDownloadIdentifier = [aDownloadRequest.downloadToken copy];
                if (aDownloadIdentifier) {
                    [self.fileDownloadDelegate downloadProgressChangedForIdentifier:aDownloadRequest.downloadToken];
                }
            }
            
            dispatch_async(self.downloadFileSerialWriterDispatchQueue, ^{
                NSFileHandle *aFileHandle = [NSFileHandle fileHandleForWritingAtPath:aTempFileURL.path];
                if (!aFileHandle) {
                    LOG(@"ERR: No file handle (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                } else {
                    [aFileHandle seekToEndOfFile];
                    [aFileHandle writeData:aData];
                    [aFileHandle closeFile];
                }
            });
        }
    }
}

- (NSNumber *)downloadIDForConnection:(nonnull NSURLConnection *)aConnection {
    NSNumber *aFoundDownloadID = nil;
    NSArray *aDownloadKeysArray = [self.activeDownloadsDictionary allKeys];
    for (NSNumber *aDownloadID in aDownloadKeysArray) {
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:aDownloadID];
        if ([aDownloadRequest.urlConnection isEqual:aConnection]) {
            aFoundDownloadID = aDownloadID;
            break;
        }
    }
    
    return aFoundDownloadID;
}

#pragma mark - NSURLConnectionDelegate


- (void)connection:(nonnull NSURLConnection *)aConnection didFailWithError:(nonnull NSError *)anError
{
    NSNumber *aDownloadID = [self downloadIDForConnection:aConnection];
    if (aDownloadID)
    {
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:aDownloadID];
        if (aDownloadRequest)
        {
            LOG(@"ERR: NSURLConnection failed with error: %@ (%@, %d)", anError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
            [self handleDownloadWithError:anError downloadItem:aDownloadRequest downloadID:[aDownloadID unsignedIntegerValue] resumeData:nil];
        }
    }
}


- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)aConnection {
    return NO;
}


- (void)connection:(NSURLConnection *)aConnection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)aChallenge {
    if ([self.fileDownloadDelegate respondsToSelector:@selector(onAuthenticationChallenge:downloadIdentifier:completionHandler:)]) {
        NSNumber *aDownloadID = [self downloadIDForConnection:aConnection];
        if (aDownloadID) {
            _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:aDownloadID];
            
            if (aDownloadRequest) {
                
                [self.fileDownloadDelegate onAuthenticationChallenge:aChallenge
                                                  downloadIdentifier:aDownloadRequest.downloadToken
                                                   completionHandler:^(NSURLCredential * _Nullable aCredential, NSURLSessionAuthChallengeDisposition aDisposition) {
                                                       [aChallenge.sender useCredential:aCredential forAuthenticationChallenge:aChallenge];
                                                   }];
            } else {
                LOG(@"ERR: Missing download item for download id: %@ (%@, %d)", aDownloadRequest, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                [aChallenge.sender cancelAuthenticationChallenge:aChallenge];
            }
        } else {
            [aChallenge.sender cancelAuthenticationChallenge:aChallenge];
        }
    } else {
        LOG(@"ERR: Received authentication challenge with no delegate method implemented (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        [aChallenge.sender cancelAuthenticationChallenge:aChallenge];
    }
}

#pragma mark - _DownloadDelegate Defaults

+ (nullable NSURL *)localFileURLForRemoteURL:(nonnull NSURL *)aRemoteURL {
    NSURL *aLocalFileURL = nil;
    NSURL *aFileDownloadDirectoryURL = nil;
    NSError *anError = nil;
    NSArray *aDocumentDirectoryURLsArray = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *aDocumentsDirectoryURL = [aDocumentDirectoryURLsArray firstObject];
    if (aDocumentsDirectoryURL) {
        aFileDownloadDirectoryURL = [aDocumentsDirectoryURL URLByAppendingPathComponent:@"file-download" isDirectory:YES];
        if ([[NSFileManager defaultManager] fileExistsAtPath:aFileDownloadDirectoryURL.path] == NO) {
            BOOL aCreateDirectorySuccess = [[NSFileManager defaultManager] createDirectoryAtPath:aFileDownloadDirectoryURL.path withIntermediateDirectories:YES attributes:nil error:&anError];
            if (aCreateDirectorySuccess == NO) {
                LOG(@"ERR on create directory: %@ (%@, %d)", anError, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
            } else {
                BOOL aSetResourceValueSuccess = [aFileDownloadDirectoryURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&anError];
                if (aSetResourceValueSuccess == NO) {
                    LOG(@"ERR on set resource value (NSURLIsExcludedFromBackupKey): %@ (%@, %d)", anError, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                }
            }
        }
        
        NSString *aLocalFileName = [NSString stringWithFormat:@"%@.%@", [[NSUUID UUID] UUIDString], [[aRemoteURL lastPathComponent] pathExtension]];
        aLocalFileURL = [aFileDownloadDirectoryURL URLByAppendingPathComponent:aLocalFileName isDirectory:NO];
    }
    
    return aLocalFileURL;
}


+ (BOOL)httpStatusCode:(NSInteger)aHttpStatusCode isValidForDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier {
    BOOL anIsCorrectFlag = NO;
    if ((aHttpStatusCode >= 200) && (aHttpStatusCode < 300)) {
        anIsCorrectFlag = YES;
    }
    
    return anIsCorrectFlag;
}


#pragma mark - Download Completion Handler


- (void)handleSuccessfulDownloadToLocalFileURL:(nonnull NSURL *)aLocalFileURL
                                  downloadItem:(nonnull _DownloadRequest *)aDownloadRequest
                                    downloadID:(NSUInteger)aDownloadID {
    aDownloadRequest.progress.completedUnitCount = aDownloadRequest.progress.totalUnitCount;
    [self.activeDownloadsDictionary removeObjectForKey:@(aDownloadID)];
    [self.fileDownloadDelegate decrementNetworkActivityIndicatorActivityCount];
    
    [self.fileDownloadDelegate downloadDidCompleteWithIdentifier:aDownloadRequest.downloadToken
                                                    localFileURL:aLocalFileURL];
    [self startNextWaitingDownload];
}


- (void)handleDownloadWithError:(nonnull NSError *)anError
                   downloadItem:(nonnull _DownloadRequest *)aDownloadRequest
                     downloadID:(NSUInteger)aDownloadID
                     resumeData:(nullable NSData *)aResumeData {
    aDownloadRequest.progress.completedUnitCount = aDownloadRequest.progress.totalUnitCount;
    [self.activeDownloadsDictionary removeObjectForKey:@(aDownloadID)];
    [self.fileDownloadDelegate decrementNetworkActivityIndicatorActivityCount];
    
    [self.fileDownloadDelegate downloadFailedWithIdentifier:aDownloadRequest.downloadToken
                                                      error:anError
                                             httpStatusCode:aDownloadRequest.lastHttpStatusCode
                                         errorMessagesStack:aDownloadRequest.errorMessagesStack
                                                 resumeData:aResumeData];
    [self startNextWaitingDownload];
}

#pragma mark - Download Progress

- (nullable _DownloadProgress *)downloadProgressForIdentifier:(nonnull NSString *)aDownloadIdentifier {
    _DownloadProgress *aDownloadProgress = nil;
    NSInteger aDownloadID = [self downloadIDForActiveDownloadToken:aDownloadIdentifier];
    if (aDownloadID > -1) {
        aDownloadProgress = [self downloadProgressForDownloadID:aDownloadID];
    }
    return aDownloadProgress;
}

- (nullable _DownloadProgress *)downloadProgressForDownloadID:(NSUInteger)aDownloadID {
    _DownloadProgress *aDownloadProgress = nil;
    _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:@(aDownloadID)];
    if (aDownloadRequest) {
        float aDownloadProgressFloat = 0.0;
        if (aDownloadRequest.expectedFileSizeInBytes > 0) {
            aDownloadProgressFloat = (float)aDownloadRequest.receivedFileSizeInBytes / (float)aDownloadRequest.expectedFileSizeInBytes;
        }
        
        NSDictionary *aRemainingTimeDict = [_Downloader remainingTimeAndBytesPerSecondForDownloadItem:aDownloadRequest];
        
        {
            [aDownloadRequest.progress setUserInfoObject:[aRemainingTimeDict objectForKey:@"remainingTime"] forKey:NSProgressEstimatedTimeRemainingKey];
            [aDownloadRequest.progress setUserInfoObject:[aRemainingTimeDict objectForKey:@"bytesPerSecondSpeed"] forKey:NSProgressThroughputKey];
        }
        
        aDownloadProgress = [[_DownloadProgress alloc] initWithDownloadProgress:aDownloadProgressFloat
                                                                     expectedFileSize:aDownloadRequest.expectedFileSizeInBytes
                                                                     receivedFileSize:aDownloadRequest.receivedFileSizeInBytes
                                                               estimatedRemainingTime:[[aRemainingTimeDict objectForKey:@"remainingTime"] doubleValue]
                                                                  bytesPerSecondSpeed:[[aRemainingTimeDict objectForKey:@"bytesPerSecondSpeed"] unsignedIntegerValue]
                                                                             progress:aDownloadRequest.progress];
    }
    
    return aDownloadProgress;
}

#pragma mark - Utilities

- (NSInteger)downloadIDForActiveDownloadToken:(nonnull NSString *)aDownloadToken {
    NSInteger aFoundDownloadID = -1;
    NSArray *aDownloadKeysArray = [self.activeDownloadsDictionary allKeys];
    for (NSNumber *aDownloadID in aDownloadKeysArray) {
        _DownloadRequest *aDownloadRequest = [self.activeDownloadsDictionary objectForKey:aDownloadID];
        if ([aDownloadRequest.downloadToken isEqualToString:aDownloadToken]) {
            aFoundDownloadID = [aDownloadID unsignedIntegerValue];
            break;
        }
    }
    return aFoundDownloadID;
}

- (void)startNextWaitingDownload {
    if ((self.maxConcurrentFileDownloadsCount == -1) || ((NSInteger)self.activeDownloadsDictionary.count < self.maxConcurrentFileDownloadsCount)) {
        if (self.waitingDownloadsArray.count > 0) {
            NSDictionary *aWaitingDownload = [self.waitingDownloadsArray objectAtIndex:0];
            NSString *aDownloadToken = aWaitingDownload[@"downloadToken"];
            NSURL *aRemoteURL = aWaitingDownload[@"remoteURL"];
            NSData *aResumeData = aWaitingDownload[@"resumeData"];
            [self.waitingDownloadsArray removeObjectAtIndex:0];
            [self startDownloadWithDownloadToken:aDownloadToken
                                   fromRemoteURL:aRemoteURL
                                 usingResumeData:aResumeData];
        }
    }
}


+ (nonnull NSDictionary *)remainingTimeAndBytesPerSecondForDownloadItem:(nonnull _DownloadRequest *)aDownloadRequest
{
    NSTimeInterval aRemainingTimeInterval = 0.0;
    NSUInteger aBytesPerSecondsSpeed = 0;
    if ((aDownloadRequest.receivedFileSizeInBytes > 0) && (aDownloadRequest.expectedFileSizeInBytes > 0))
    {
        float aSmoothingFactor = 0.8; // range 0.0 ... 1.0 (determines the weight of the current speed calculation in relation to the stored past speed value)
        NSTimeInterval aDownloadDurationUntilNow = [[NSDate date] timeIntervalSinceDate:aDownloadRequest.downloadStartDate];
        int64_t aDownloadedFileSize = aDownloadRequest.receivedFileSizeInBytes - aDownloadRequest.resumedFileSizeInBytes;
        float aCurrentBytesPerSecondSpeed = (aDownloadDurationUntilNow > 0.0) ? (aDownloadedFileSize / aDownloadDurationUntilNow) : 0.0;
        float aNewWeightedBytesPerSecondSpeed = 0.0;
        if (aDownloadRequest.bytesPerSecondSpeed > 0.0)
        {
            aNewWeightedBytesPerSecondSpeed = (aSmoothingFactor * aCurrentBytesPerSecondSpeed) + ((1.0 - aSmoothingFactor) * (float)aDownloadRequest.bytesPerSecondSpeed);
        }
        else
        {
            aNewWeightedBytesPerSecondSpeed = aCurrentBytesPerSecondSpeed;
        }
        if (aNewWeightedBytesPerSecondSpeed > 0.0)
        {
            aRemainingTimeInterval = (aDownloadRequest.expectedFileSizeInBytes - aDownloadRequest.resumedFileSizeInBytes - aDownloadedFileSize) / aNewWeightedBytesPerSecondSpeed;
        }
        aBytesPerSecondsSpeed = (NSUInteger)aNewWeightedBytesPerSecondSpeed;
        aDownloadRequest.bytesPerSecondSpeed = aBytesPerSecondsSpeed;
    }
    return @{@"bytesPerSecondSpeed" : @(aBytesPerSecondsSpeed), @"remainingTime" : @(aRemainingTimeInterval)};
}


#pragma mark - Description


- (NSString *)description
{
    NSMutableDictionary *aDescriptionDict = [NSMutableDictionary dictionary];
    [aDescriptionDict setObject:self.activeDownloadsDictionary forKey:@"activeDownloadsDictionary"];
    [aDescriptionDict setObject:self.waitingDownloadsArray forKey:@"waitingDownloadsArray"];
    [aDescriptionDict setObject:@(self.maxConcurrentFileDownloadsCount) forKey:@"maxConcurrentFileDownloadsCount"];
    [aDescriptionDict setObject:@(self.highestDownloadID) forKey:@"highestDownloadID"];
    
    NSString *aDescriptionString = [NSString stringWithFormat:@"%@", aDescriptionDict];
    
    return aDescriptionString;
}

@end

