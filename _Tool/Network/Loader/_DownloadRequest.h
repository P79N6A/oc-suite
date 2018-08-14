//
//  _downloader_request.h
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//


#import <Foundation/Foundation.h>


/**
 _DownloadRequest is used internally by _Downloader.
 */
@interface _DownloadRequest : NSObject

- (nullable instancetype)initWithDownloadToken:(nonnull NSString *)aDownloadToken
                           sessionDownloadTask:(nullable NSURLSessionDownloadTask *)aSessionDownloadTask
                                 urlConnection:(nullable NSURLConnection *)aURLConnection;

@property (nonatomic, strong, nullable) NSDate *downloadStartDate;
@property (nonatomic, assign) int64_t receivedFileSizeInBytes;
@property (nonatomic, assign) int64_t expectedFileSizeInBytes;
@property (nonatomic, assign) int64_t resumedFileSizeInBytes;
@property (nonatomic, assign) NSUInteger bytesPerSecondSpeed;
@property (nonatomic, strong, readonly, nonnull) NSProgress *progress;
@property (nonatomic, strong, readonly, nonnull) NSString *downloadToken;

@property (nonatomic, strong, readonly, nullable) NSURLSessionDownloadTask *sessionDownloadTask;

@property (nonatomic, strong, readonly, nullable) NSURLConnection *urlConnection;

@property (nonatomic, strong, nullable) NSArray<NSString *> *errorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;
@property (nonatomic, strong, nullable) NSURL *finalLocalFileURL;


- (nullable _DownloadRequest *)init __attribute__((unavailable("use initWithDownloadToken:sessionDownloadTask:urlConnection:")));
+ (nullable _DownloadRequest *)new __attribute__((unavailable("use initWithDownloadToken:sessionDownloadTask:urlConnection:")));

@end
