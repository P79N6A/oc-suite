//
//  _VideoModel.h
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//

#import "_foundation.h"

@class _VideoOperation;
@class _VideoModel;

typedef NS_ENUM(NSInteger, VideoStatus) {
    VideoStatusNone = 0,       // 初始状态
    VideoStatusRunning = 1,    // 下载中
    VideoStatusSuspended = 2,  // 下载暂停
    VideoStatusCompleted = 3,  // 下载完成
    VideoStatusFailed  = 4,    // 下载失败
    VideoStatusWaiting = 5,    // 等待下载
    VideoStatusCancel = 6      // 取消下载
};

typedef void(^ VideoStatusChanged)(_VideoModel *model);
typedef void(^ VideoProgressChanged)(_VideoModel *model);

@interface _VideoModel : NSObject

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *title;


@property (nonatomic, strong) NSData *resumeData;
// 下载后存储到此处
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *progressText;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) VideoStatus status;
@property (nonatomic, strong) _VideoOperation *operation;

@property (nonatomic, copy) VideoStatusChanged onStatusChanged;
@property (nonatomic, copy) VideoProgressChanged onProgressChanged;

@property (nonatomic, readonly, copy) NSString *statusText;

@end
