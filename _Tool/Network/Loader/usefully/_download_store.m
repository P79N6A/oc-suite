//
//  _download_store.m
//  consumer
//
//  Created by fallen on 16/12/21.
//
//

#import "_greats.h"
#import "_download_store.h"
#import "_downloader.h"

NSString* _Nonnull const DownloadModule_downloadDidCompleteNotification = @"downloadDidCompleteNotification";
NSString* _Nonnull const DownloadModule_downloadProgressChangedNotification = @"downloadProgressChangedNotification";
NSString* _Nonnull const DownloadModule_totalDownloadProgressChangedNotification = @"totalDownloadProgressChangedNotification";

static NSString *DownloadModule_downloadModelsStoreKey = @"downloadModelsStoreKey";

static void *DownloadStoreProgressObserverContext = &DownloadStoreProgressObserverContext;

@interface _DownloadStore ()

@property (nonatomic, assign) NSUInteger networkActivityIndicatorCount;

@property (nonatomic, strong, readwrite, nonnull) NSMutableDictionary *models;

@property (nonatomic, strong, nonnull) NSProgress *progress;

@end

@implementation _DownloadStore

- (instancetype)init {
    self = [super init];
    if (self) {
        self.networkActivityIndicatorCount = 0;
        
        self.progress = [NSProgress progressWithTotalUnitCount:0];
        
        
        {
            [self.progress addObserver:self
                            forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                               options:NSKeyValueObservingOptionInitial
                               context:DownloadStoreProgressObserverContext];
        }
    }
    return self;
}

- (void)setupDownloadItems {
    self.models = [self restoredDownloadItems];
    
    [self.models enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull aDownloadIdentifier, _DownloadModel * _Nonnull model, BOOL * _Nonnull stop) {
        BOOL isDownloading = [self.downloader isDownloadingIdentifier:aDownloadIdentifier];
        
        // 如果没有在下载，同时当前状态是started，改为‘中断’
        if (!isDownloading && (model.status == DownloadModelStatusStarted || model.status == DownloadModelStatusPaused)) {
            model.status = DownloadModelStatusInterrupted;
        }
        
        // 如果没有在下载，同时当前状态是completed，仍然是completed
        if (!isDownloading && model.status == DownloadModelStatusCompleted) {
            model.status = DownloadModelStatusCompleted;
        }
    }];
    
    [self storeDemoDownloadItems];
}

- (void)dealloc {
    {
        [self.progress removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                              context:DownloadStoreProgressObserverContext];
    }
}

#pragma mark - Public

- (void)startDownloadWithModel:(_DownloadModel *)aModel {
    [self resetProgressIfNoActiveDownloadsRunning];
    
    // If aModel has store to self.models, set it
    if (![self.models.allKeys containsString:aModel.downloadIdentifier]) {
        [self.models setObject:aModel forKey:aModel.downloadIdentifier];
    }
    
    if ((aModel.status != DownloadModelStatusCancelled) && (aModel.status != DownloadModelStatusCompleted)) {
        BOOL isDownloading = [self.downloader isDownloadingIdentifier:aModel.downloadIdentifier];
        if (isDownloading == NO) {
            aModel.status = DownloadModelStatusStarted;
            
            [self storeDemoDownloadItems];
            
            // kick off individual download
            if (aModel.resumeData.length > 0) {
                [self.downloader startDownloadWithIdentifier:aModel.downloadIdentifier usingResumeData:aModel.resumeData];
            } else {
                [self.downloader startDownloadWithIdentifier:aModel.downloadIdentifier fromRemoteURL:aModel.remoteURL];
            }
        }
    }
}

- (void)cancelDownloadWithIdentifier:(NSString *)anIdentifier {
    _DownloadModel *aModel = [self.models objectForKey:anIdentifier];
    
    if (aModel) {
        aModel.status = DownloadModelStatusCancelled;
        
        [self storeDemoDownloadItems];
        
        [self.downloader cancelDownloadWithIdentifier:anIdentifier];
    } else {
        LOG(@"ERR: Cancelled download item not found (id: %@)", anIdentifier);
    }
}

- (void)resumeDownloadWithIdentifier:(NSString *)anIdentifier {
    [self resetProgressIfNoActiveDownloadsRunning];
    
    _DownloadModel *aModel = [self.models objectForKey:anIdentifier];
    
    if (aModel) {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
            if (aModel.progress.nativeProgress) {
                [aModel.progress.nativeProgress resume];
            } else {
                [self startDownloadWithModel:aModel];
            }
        } else {
            [self startDownloadWithModel:aModel];
        }
    }
}

#pragma mark - _DownloadDelegate

- (void)downloadDidCompleteWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                             localFileURL:(nonnull NSURL *)aLocalFileURL {
    _DownloadModel *aModel = [self.models objectForKey:aDownloadIdentifier];
    aModel.localFileURL = aLocalFileURL;
    if (aModel) {
        LOG(@"INFO: Download completed (id: %@)", aDownloadIdentifier);
        
        aModel.status = DownloadModelStatusCompleted;
        
        // Begin download post process
        [aModel beginPostprocess];
        
        [self storeDemoDownloadItems];
    } else {
        LOG(@"ERR: Completed download item not found (id: %@)", aDownloadIdentifier);
    }
    
    [self postNotification:DownloadModule_downloadDidCompleteNotification withObject:aModel];
}


- (void)downloadFailedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                               error:(nonnull NSError *)anError
                      httpStatusCode:(NSInteger)aHttpStatusCode
                  errorMessagesStack:(nullable NSArray<NSString *> *)anErrorMessagesStack
                          resumeData:(nullable NSData *)aResumeData {
    _DownloadModel *aModel = [self.models objectForKey:aDownloadIdentifier];
    
    if (aModel) {
        aModel.lastHttpStatusCode = aHttpStatusCode;
        aModel.resumeData = aResumeData;
        aModel.downloadError = anError;
        aModel.downloadErrorMessagesStack = anErrorMessagesStack;
        
        // download status heuristics
        if (aModel.status != DownloadModelStatusPaused) {
            if (aResumeData.length > 0) {
                aModel.status = DownloadModelStatusInterrupted;
            } else if ([anError.domain isEqualToString:NSURLErrorDomain] && (anError.code == NSURLErrorCancelled)) {
                aModel.status = DownloadModelStatusCancelled;
            } else {
                aModel.status = DownloadModelStatusError;
            }
        }
        
        [self storeDemoDownloadItems];
        
        switch (aModel.status) {
            case DownloadModelStatusError:
                LOG(@"ERR: Download with error %@ (http status: %@) - id: %@", @(anError.code), @(aHttpStatusCode), aDownloadIdentifier);
                break;
            case DownloadModelStatusInterrupted:
                LOG(@"ERR: Download interrupted with error %@ - id: %@", @(anError.code), aDownloadIdentifier);
                break;
            case DownloadModelStatusCancelled:
                LOG(@"INFO: Download cancelled - id: %@", aDownloadIdentifier);
                break;
            case DownloadModelStatusPaused:
                LOG(@"INFO: Download paused - id: %@", aDownloadIdentifier);
                break;
                
            default:
                break;
        }
        
    } else {
        LOG(@"ERR: Failed download item not found (id: %@)", aDownloadIdentifier);
    }
    
    [self postNotification:DownloadModule_downloadDidCompleteNotification withObject:aModel];
}

- (void)incrementNetworkActivityIndicatorActivityCount {
    [self toggleNetworkActivityIndicatorVisible:YES];
}


- (void)decrementNetworkActivityIndicatorActivityCount {
    [self toggleNetworkActivityIndicatorVisible:NO];
}

#pragma mark - _DownloadDelegate (optional)

- (void)downloadProgressChangedForIdentifier:(nonnull NSString *)aDownloadIdentifier {
    _DownloadModel *model = [self.models objectForKey:aDownloadIdentifier];
    if (model) {
        _DownloadProgress *aFileDownloadProgress = [self.downloader downloadProgressForIdentifier:aDownloadIdentifier];
        if (aFileDownloadProgress) {
            model.progress = aFileDownloadProgress;
            {
                model.progress.lastLocalizedDescription = model.progress.nativeProgress.localizedDescription;
                model.progress.lastLocalizedAdditionalDescription = model.progress.nativeProgress.localizedAdditionalDescription;
            }
        }
    }
    
    [self postNotification:DownloadModule_downloadProgressChangedNotification withObject:model];
}


- (void)downloadPausedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                          resumeData:(nullable NSData *)aResumeData {
    _DownloadModel *model = [self.models objectForKey:aDownloadIdentifier];
    if (model) {
        LOG(@"INFO: Download paused - id: %@", aDownloadIdentifier);
        
        model.status = DownloadModelStatusPaused;
        model.resumeData = aResumeData;
        
        [self storeDemoDownloadItems];
    } else {
        LOG(@"ERR: Paused download item not found (id: %@)", aDownloadIdentifier);
    }
}

- (void)downloadResumeWithIdentifier:(nonnull NSString *)aDownloadIdentifier {
    _DownloadModel *model = [self.models objectForKey:aDownloadIdentifier];
    if (model) {
        [self startDownloadWithModel:model];
    }
}

- (BOOL)downloadAtLocalFileURL:(nonnull NSURL *)aLocalFileURL isValidForDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier {
    BOOL anIsValidFlag = YES;
    
    // just checking for file size
    // you might want to check by converting into expected data format (like UIImage) or by scanning for expected content
    
    NSError *anError = nil;
    NSDictionary <NSString *, id> *aFileAttributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:aLocalFileURL.path error:&anError];
    if (anError) {
        LOG(@"ERR: Error on getting file size for item at %@: %@", aLocalFileURL, anError.localizedDescription);
        anIsValidFlag = NO;
    } else {
        unsigned long long aFileSize = [aFileAttributesDictionary fileSize];
        if (aFileSize == 0) {
            anIsValidFlag = NO;
        } else {
//            if (aFileSize < 40000) {
//                NSError *anError = nil;
//                NSString *aString = [NSString stringWithContentsOfURL:aLocalFileURL encoding:NSUTF8StringEncoding error:&anError];
//                if (anError) {
//                    LOG(@"ERR: %@", anError.localizedDescription);
//                } else {
//                    LOG(@"INFO: Downloaded file content for download identifier %@: %@", aDownloadIdentifier, aString);
//                }
//                
//                anIsValidFlag = NO;
//            }
            anIsValidFlag = YES;
            
            _DownloadModel *model = [self.models objectForKey:aDownloadIdentifier];
            model.localFileURL = aLocalFileURL;
            if (is_method_implemented(model, isValidAtLocalFileURL:)) {
                anIsValidFlag = YES;
            }
        }
    }
    
    return anIsValidFlag;
}

//- (void)onAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)aChallenge
//               downloadIdentifier:(nonnull NSString *)aDownloadIdentifier
//                completionHandler:(void (^ _Nonnull)(NSURLCredential * _Nullable aCredential, NSURLSessionAuthChallengeDisposition disposition))aCompletionHandler {
//    if (aChallenge.previousFailureCount == 0) {
//        NSURLCredential *aCredential = [NSURLCredential credentialWithUser:@"username" password:@"password" persistence:NSURLCredentialPersistenceNone];
//        aCompletionHandler(aCredential, NSURLSessionAuthChallengeUseCredential);
//    } else {
//        aCompletionHandler(nil, NSURLSessionAuthChallengeRejectProtectionSpace);
//    }
//}

- (nullable NSProgress *)rootProgress {
    {
        return self.progress;
    }
}

//- (void)customizeBackgroundSessionConfiguration:(nonnull NSURLSessionConfiguration *)aBackgroundSessionConfiguration {
//    NSMutableDictionary *aHTTPAdditionalHeadersDict = [aBackgroundSessionConfiguration.HTTPAdditionalHeaders mutableCopy];
//    if (aHTTPAdditionalHeadersDict == nil) {
//        aHTTPAdditionalHeadersDict = [[NSMutableDictionary alloc] init];
//    }
//    
//    [aHTTPAdditionalHeadersDict setObject:@"identity" forKey:@"Accept-Encoding"];
//    
//    aBackgroundSessionConfiguration.HTTPAdditionalHeaders = aHTTPAdditionalHeadersDict;
//}


#pragma mark - NSProgress

- (void)observeValueForKeyPath:(nullable NSString *)aKeyPath
                      ofObject:(nullable id)anObject
                        change:(nullable NSDictionary<NSString*, id> *)aChange
                       context:(nullable void *)aContext {
    if (aContext == DownloadStoreProgressObserverContext) {
        NSProgress *aProgress = anObject; // == self.progress
        if ([aKeyPath isEqualToString:@"fractionCompleted"]) {
            [self postNotification:DownloadModule_totalDownloadProgressChangedNotification withObject:aProgress];
        } else {
            LOG(@"ERR: Invalid keyPath (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
    } else {
        [super observeValueForKeyPath:aKeyPath
                             ofObject:anObject
                               change:aChange
                              context:aContext];
    }
}

- (void)resetProgressIfNoActiveDownloadsRunning {
    BOOL aHasActiveDownloadsFlag = [self.downloader hasActiveDownloads];
    if (aHasActiveDownloadsFlag == NO) {
        {
            [self.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
        }
        
        self.progress = [NSProgress progressWithTotalUnitCount:0];
        
        {
            [self.progress addObserver:self
                            forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                               options:NSKeyValueObservingOptionInitial
                               context:DownloadStoreProgressObserverContext];
        }
    }
}

#pragma mark - Network Activity Indicator


- (void)toggleNetworkActivityIndicatorVisible:(BOOL)visible {
    visible ? self.networkActivityIndicatorCount++ : self.networkActivityIndicatorCount--;
    
    LOG(@"INFO: NetworkActivityIndicatorCount: %@", @(self.networkActivityIndicatorCount));
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkActivityIndicatorCount > 0);
}

#pragma mark - Persistence


- (void)storeDemoDownloadItems {
    NSMutableDictionary *aDownloadModels = [NSMutableDictionary dictionaryWithCapacity:self.models.count];
    
    for (_DownloadModel *aModel in self.models.allValues) {
        NSData *aModelEncoded = [NSKeyedArchiver archivedDataWithRootObject:aModel];
        
        [aDownloadModels setObject:aModelEncoded forKey:aModel.downloadIdentifier];
    }
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:aDownloadModels forKey:DownloadModule_downloadModelsStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (nonnull NSMutableDictionary *)restoredDownloadItems {
    NSMutableDictionary *aDownloadModels = [NSMutableDictionary new];
    NSMutableDictionary *aRestoredDownloadModels = [[[NSUserDefaults standardUserDefaults] objectForKey:DownloadModule_downloadModelsStoreKey] mutableCopy];
    
    if (!aRestoredDownloadModels) {
        aRestoredDownloadModels = [NSMutableDictionary new];
    }
    
    [aRestoredDownloadModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull identifier, NSData * _Nonnull aData, BOOL * _Nonnull stop) {
        _DownloadModel *aDownloadModel = [NSKeyedUnarchiver unarchiveObjectWithData:aData];
        
        [aDownloadModels setObject:aDownloadModel forKey:identifier];
    }];
    
    return aDownloadModels;
}

@end
