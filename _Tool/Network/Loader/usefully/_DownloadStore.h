//
//  _download_store.h
//  consumer
//
//  Created by fallen on 16/12/21.
//
//

#import <Foundation/Foundation.h>

#import "_downloaderdef.h"
#import "_download_model.h"

@class _Downloader;

extern NSString* _Nonnull const DownloadModule_downloadDidCompleteNotification;
extern NSString* _Nonnull const DownloadModule_downloadProgressChangedNotification;
extern NSString* _Nonnull const DownloadModule_totalDownloadProgressChangedNotification;

@interface _DownloadStore : NSObject <_DownloadDelegate>

@property (nonatomic, strong, readonly, nonnull) NSMutableDictionary *models;
@property (nonatomic, weak, nullable) _Downloader *downloader;

- (void)setupDownloadItems;

- (void)startDownloadWithModel:(nonnull _DownloadModel *)aModel;

- (void)cancelDownloadWithIdentifier:(nonnull NSString *)anIdentifier;

- (void)resumeDownloadWithIdentifier:(nonnull NSString *)anIdentifier;

@end
