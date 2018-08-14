//
//  _downloader_model.h
//  consumer
//
//  Created by fallen.ink on 20/12/2016.
//
//

#import <Foundation/Foundation.h>
#import "../_download_progress.h"
#import "../_downloaderdef.h"

typedef NS_ENUM(NSUInteger, DownloadModelStatus) {
    DownloadModelStatusNotStarted = 0,
    DownloadModelStatusStarted,
    DownloadModelStatusCompleted,
    DownloadModelStatusPaused,
    DownloadModelStatusCancelled,
    DownloadModelStatusInterrupted,
    DownloadModelStatusError
};

@interface _DownloadModel : NSObject <DownloadManageDelegate>

- (nullable instancetype)initWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                                          remoteURL:(nonnull NSURL *)aRemoteURL;

@property (nonatomic, strong, readonly, nonnull) NSString *downloadIdentifier;
@property (nonatomic, strong, readonly, nonnull) NSURL *remoteURL;
@property (nonatomic, strong, nullable) NSURL *localFileURL;
@property (nonatomic, strong, nullable) NSURL *unzippedLocalFileURL; // may generate at method (beginPostprocess)

@property (nonatomic, strong, nullable) NSData *resumeData;
@property (nonatomic, assign) DownloadModelStatus status;

@property (nonatomic, strong, nullable) _DownloadProgress *progress;

@property (nonatomic, strong, nullable) NSError *downloadError;
@property (nonatomic, strong, nullable) NSArray<NSString *> *downloadErrorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;

- (nullable _DownloadModel *)init __attribute__((unavailable("use initWithDownloadIdentifier:remoteURL:")));
+ (nullable _DownloadModel *)new __attribute__((unavailable("use initWithDownloadIdentifier:remoteURL:")));

// ----------------------------------
// DownloadManageDelegate
// ----------------------------------

- (void)startDownload;

- (void)beginPostprocess;

+ (nullable id)storedDownloadModelWithIdentifier:(nonnull NSString *)aDownloadIdentifier;

// 查看数据的有效性，图片、视频、模型等
- (BOOL)isValidAtLocalFileURL:(nonnull NSURL *)aLocalFileURL;

@end
