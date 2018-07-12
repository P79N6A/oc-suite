//
//  ImageDownloader.h
// fallen.ink
//
//  Created by fallen on 15/9/7.
//
//  下载图片服务，底层使用SDWebImageManager,走缓存机制

#import "_foundation.h"

@interface ImageDownloader : NSObject

@singleton( ImageDownloader )

- (void)downloadWithUrl:(NSString*)url
                success:(ImageBlock)success
                   fail:(ErrorBlock)fail
               progress:(FloatBlock)progress;

@end
