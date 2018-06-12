//
//  YYWebImage.h
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import "YYImageCache.h"
#import "YYWebImageOperation.h"
#import "YYWebImageManager.h"
#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"
#import "UIButton+YYWebImage.h"
#import "CALayer+YYWebImage.h"
#import "MKAnnotationView+YYWebImage.h"
#import "YYImage.h"
#import "YYFrameImage.h"
#import "YYSpriteSheetImage.h"
#import "YYImageCoder.h"
#import "YYAnimatedImageView.h"
#import "YYCache.h"
#import "YYMemoryCache.h"
#import "YYDiskCache.h"
#import "YYKVStorage.h"

/**
 Usage:
 
 ###Load image from URL
 
 // load from remote url
 imageView.yy_imageURL = [NSURL URLWithString:@"http://github.com/logo.png"];
 
 // load from local url
 imageView.yy_imageURL = [NSURL fileURLWithPath:@"/tmp/logo.png"];
 ###Load animated image
 
 // just replace `UIImageView` with `YYAnimatedImageView`
 UIImageView *imageView = [YYAnimatedImageView new];
 imageView.yy_imageURL = [NSURL URLWithString:@"http://github.com/ani.webp"];
 ###Load image progressively
 
 // progressive
 [imageView yy_setImageWithURL:url options:YYWebImageOptionProgressive];
 
 // progressive with blur and fade animation (see the demo at the top of this page)
 [imageView yy_setImageWithURL:url options:YYWebImageOptionProgressiveBlur ｜ YYWebImageOptionSetImageWithFadeAnimation];
 ###Load and process image
 
 // 1. download image from remote
 // 2. get download progress
 // 3. resize image and add round corner
 // 4. set image with a fade animation
 
 [imageView yy_setImageWithURL:url
 placeholder:nil
 options:YYWebImageOptionSetImageWithFadeAnimation
 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
 progress = (float)receivedSize / expectedSize;
 }
 transform:^UIImage *(UIImage *image, NSURL *url) {
 image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeCenter];
 return [image yy_imageByRoundCornerRadius:10];
 }
 completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
 if (from == YYWebImageFromDiskCache) {
 NSLog(@"load from disk cache");
 }
 }];
 ###Image Cache YYImageCache *cache = [YYWebImageManager sharedManager].cache;
 
 // get cache capacity
 cache.memoryCache.totalCost;
 cache.memoryCache.totalCount;
 cache.diskCache.totalCost;
 cache.diskCache.totalCount;
 
 // clear cache
 [cache.memoryCache removeAllObjects];
 [cache.diskCache removeAllObjects];
 
 // clear disk cache with progress
 [cache.diskCache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
 // progress
 } endBlock:^(BOOL error) {
 // end
 }];
 */
