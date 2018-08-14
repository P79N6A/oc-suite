//
//  _loader_manager.m
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//

#import "_loader_manager.h"
#import "_video_model.h"
#import "_video_operation.h"

@interface _LoaderManager () <NSURLSessionDownloadDelegate> {
    NSMutableArray *_videoModels;
}

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation _LoaderManager

@def_singleton(_LoaderManager)

- (instancetype)init {
    if (self = [super init]) {
        _videoModels = [[NSMutableArray alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 4;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 不能传self.queue
        self.session = [NSURLSession sessionWithConfiguration:config
                                                     delegate:self
                                                delegateQueue:nil];
    }
    
    return self;
}

- (NSArray *)videoModels {
    return _videoModels;
}

- (void)addVideoModels:(NSArray<_VideoModel *> *)videoModels {
    if ([videoModels isKindOfClass:[NSArray class]]) {
        [_videoModels addObjectsFromArray:videoModels];
    }
}

- (void)startWithVideoModel:(_VideoModel *)videoModel {
    if (videoModel.status != VideoStatusCompleted) {
        videoModel.status = VideoStatusRunning;
        
        if (videoModel.operation == nil) {
            videoModel.operation = [[_VideoOperation alloc] initWithModel:videoModel
                                                                    session:self.session];
            [self.queue addOperation:videoModel.operation];
            [videoModel.operation start];
        } else {
            [videoModel.operation resume];
        }
    }
}

- (void)suspendWithVideoModel:(_VideoModel *)videoModel {
    if (videoModel.status != VideoStatusCompleted) {
        [videoModel.operation suspend];
    }
}

- (void)resumeWithVideoModel:(_VideoModel *)videoModel {
    if (videoModel.status != VideoStatusCompleted) {
        [videoModel.operation resume];
    }
}

- (void)stopWiethVideoModel:(_VideoModel *)videoModel {
    if (videoModel.operation) {
        [videoModel.operation cancel];
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    //本地的文件路径，使用fileURLWithPath:来创建
    if (downloadTask.hyb_videoModel.localPath) {
        NSURL *toURL = [NSURL fileURLWithPath:downloadTask.hyb_videoModel.localPath];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager moveItemAtURL:location toURL:toURL error:nil];
    }
    
    [downloadTask.hyb_videoModel.operation downloadFinished];
    NSLog(@"path = %@", downloadTask.hyb_videoModel.localPath);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == nil) {
            task.hyb_videoModel.status = VideoStatusCompleted;
            [task.hyb_videoModel.operation downloadFinished];
        } else if (task.hyb_videoModel.status == VideoStatusSuspended) {
            task.hyb_videoModel.status = VideoStatusSuspended;
        } else if ([error code] < 0) {
            // 网络异常
            task.hyb_videoModel.status = VideoStatusFailed;
        }
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double byts =  totalBytesWritten * 1.0 / 1024 / 1024;
    double total = totalBytesExpectedToWrite * 1.0 / 1024 / 1024;
    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1fMB",byts,total];
    CGFloat progress = totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadTask.hyb_videoModel.progressText = text;
        downloadTask.hyb_videoModel.progress = progress;
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    double byts =  fileOffset * 1.0 / 1024 / 1024;
    double total = expectedTotalBytes * 1.0 / 1024 / 1024;
    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1fMB",byts,total];
    CGFloat progress = fileOffset / (CGFloat)expectedTotalBytes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadTask.hyb_videoModel.progressText = text;
        downloadTask.hyb_videoModel.progress = progress;
    });
}

@end
