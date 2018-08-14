//
//  _VideoModel.m
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//

#import "_video_model.h"
#import "_video_operation.h"

@implementation _VideoModel

- (NSString *)localPath {
    NSString *pathName = [NSString stringWithFormat:@"/Documents/HYBVideos/%@.mp4",self.videoId];
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:pathName];
    
    return filePath;
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        _progress = progress;
        
        if (self.onProgressChanged) {
            self.onProgressChanged(self);
        } else {
            NSLog(@"progress changed block is empty");
        }
    }
}

- (void)setStatus:(VideoStatus)status {
    if (_status != status) {
        _status = status;
        
        if (self.onStatusChanged) {
            self.onStatusChanged(self);
        }
    }
}

- (NSString *)statusText {
    switch (self.status) {
        case VideoStatusNone: {
            return @"";
            break;
        }
        case VideoStatusRunning: {
            return @"下载中";
            break;
        }
        case VideoStatusSuspended: {
            return @"暂停下载";
            break;
        }
        case VideoStatusCompleted: {
            return @"下载完成";
            break;
        }
        case VideoStatusFailed: {
            return @"下载失败";
            break;
        }
        case VideoStatusWaiting: {
            return @"等待下载";
            break;
        }
            
        default: {
            return nil;
        }
            break;
    }
}

@end
