//
//  _downloader.h
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//  https://github.com/Heikowi/HWIFileDownload

#import <Foundation/Foundation.h>

#import "_downloaderdef.h"
#import "_download_progress.h"


/**
 DownloaderPauseResumeDataBlock is a block optionally called after cancelling a download.
 */
typedef void (^DownloaderPauseResumeDataBlock)(NSData * _Nullable aResumeData);


/**
 HWIFileDownloader coordinates download activities.
 */
@interface _Downloader : NSObject

#pragma mark - Initialization


/**
 Secondary initializer.
 @param aDelegate Delegate for salient download events.
 @return HWIFileDownloader.
 */
- (nullable instancetype)initWithDelegate:(nonnull NSObject<_DownloadDelegate> *)aDelegate;

/**
 Designated initializer.
 @param aDelegate Delegate for salient download events.
 @param aMaxConcurrentFileDownloadsCount Maximum number of concurrent downloads. Default: no limit.
 @return HWIFileDownloader.
 */
- (nullable _Downloader *)initWithDelegate:(nonnull NSObject<_DownloadDelegate> *)aDelegate maxConcurrentDownloads:(NSInteger)aMaxConcurrentFileDownloadsCount;
- (nullable _Downloader *)init __attribute__((unavailable("use initWithDelegate:maxConcurrentDownloads: or initWithDelegate:")));
+ (nullable _Downloader *)new __attribute__((unavailable("use initWithDelegate:maxConcurrentDownloads: or initWithDelegate:")));


/**
 Set up file downloader.
 @param aSetupCompletionBlock Completion block to be called asynchronously after setup is finished.
 */
- (void)setupWithCompletion:(nullable void (^)(void))aSetupCompletionBlock;


#pragma mark - Download

/**
 Starts a download.
 @param aDownloadIdentifier Download identifier of a download item.
 @param aRemoteURL Remote URL from where data should be downloaded.
 */
- (void)startDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                      fromRemoteURL:(nonnull NSURL *)aRemoteURL;

/**
 Starts a download.
 @param aDownloadIdentifier Download identifier of a download item.
 @param aResumeData Incomplete data from previous download with implicit remote source information.
 */
- (void)startDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                    usingResumeData:(nonnull NSData *)aResumeData;


/**
 Answers the question whether a download is currently running for a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @return YES if a download is currently running for the download item, NO otherwise.
 @discussion Waiting downloads are included.
 */
- (BOOL)isDownloadingIdentifier:(nonnull NSString *)aDownloadIdentifier;


/**
 Answers the question whether a download is currently waiting for start.
 @param aDownloadIdentifier Download identifier of the download item.
 @return YES if a download is currently waiting for start, NO otherwise.
 @discussion Downloads might be queued and waiting for download. When a download is waiting, download of data from a remote host did not start yet.
 */
- (BOOL)isWaitingForDownloadOfIdentifier:(nonnull NSString *)aDownloadIdentifier;


/**
 Answers the question whether any download is currently running.
 @return YES if any download is currently running, NO otherwise.
 */
- (BOOL)hasActiveDownloads;


/**
 Cancels the download of a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 */
- (void)cancelDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier;


#pragma mark - BackgroundSessionCompletionHandler


/**
 Sets the completion handler for background session.
 @param aBackgroundSessionCompletionHandlerBlock Completion handler block.
 */
- (void)setBackgroundSessionCompletionHandlerBlock:(nullable BackgroundSessionCompletionHandlerBlock)aBackgroundSessionCompletionHandlerBlock;


#pragma mark - Progress


/**
 Returns download progress information for a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @return Download progress information.
 */
- (nullable _DownloadProgress *)downloadProgressForIdentifier:(nonnull NSString *)aDownloadIdentifier;


@end
