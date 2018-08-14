//
//  _VideoOperation.h
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//

#import <Foundation/Foundation.h>

@class _VideoModel;

@interface NSURLSessionTask (VideoModel)

// 为了更方便去获取，而不需要遍历，采用扩展的方式，可直接提取，提高效率
@property (nonatomic, weak) _VideoModel *hyb_videoModel;

@end

@interface _VideoOperation : NSOperation

- (instancetype)initWithModel:(_VideoModel *)model session:(NSURLSession *)session;

@property (nonatomic, weak) _VideoModel *model;
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;

- (void)suspend;
- (void)resume;
- (void)downloadFinished;

@end
