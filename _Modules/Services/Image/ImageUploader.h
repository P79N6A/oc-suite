//
//  PictureUploader.h
// fallen.ink
//
//  Created by fallen on 15/8/4.
//

#import <Foundation/Foundation.h>

#import "ImageUploadApi.h"

#if 0

@interface ImageUploader : NSObject

@singleton( ImageUploader )

// ----------------------------------
// Net command based
// ----------------------------------

- (void)uploadPicture:(UIImage *)picture
            channelId:(int32_t)channel
                 type:(int)type
              success:(ObjectBlock)success
                 fail:(ErrorBlock)fail
             progress:(FloatBlock)progress;

- (void)uploadHDPicture:(UIImage *)picture // 上传大图
                success:(ObjectBlock)success
                   fail:(ErrorBlock)fail
               progress:(FloatBlock)progress;

- (void)uploadPictures:(NSArray<UIImage *> *)pictures
             channelId:(int32_t)channel
                  type:(int)type
               success:(ArrayBlock)success // string s, 如果是大图，则是"缩略图name;大图name"
                  fail:(ErrorBlock)fail
              progress:(FloatBlock)progress;

@end

#endif
