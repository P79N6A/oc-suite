//
//  _loader_manager.h
//  consumer
//
//  Created by fallen.ink on 14/10/2016.
//
//

#import "_foundation.h"

@class _VideoModel;

@interface _LoaderManager : NSObject

@singleton(_LoaderManager)

@property (nonatomic, readonly, strong) NSArray *videoModels;

- (void)addVideoModels:(NSArray<_VideoModel *> *)videoModels;

- (void)startWithVideoModel:(_VideoModel *)videoModel;
- (void)suspendWithVideoModel:(_VideoModel *)videoModel;
- (void)resumeWithVideoModel:(_VideoModel *)videoModel;

- (void)stopWiethVideoModel:(_VideoModel *)videoModel;

@end
