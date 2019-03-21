//
//  ImagingViewController.m
//  gege
//
//  Created by fallen.ink on 2019/3/14.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import "ImagingViewController.h"
#import "AppDelegate.h"

//失败后重试
//SDWebImageRetryFailed = 1 << 0,
//
////UI交互期间开始下载，导致延迟下载比如UIScrollView减速。
//SDWebImageLowPriority = 1 << 1,
//
////只进行内存缓存
//SDWebImageCacheMemoryOnly = 1 << 2,
//
////这个标志可以渐进式下载,显示的图像是逐步在下载
//SDWebImageProgressiveDownload = 1 << 3,
//
////刷新缓存
//SDWebImageRefreshCached = 1 << 4,
//
////后台下载
//SDWebImageContinueInBackground = 1 << 5,
//
////NSMutableURLRequest.HTTPShouldHandleCookies = YES;
//
//SDWebImageHandleCookies = 1 << 6,
//
////允许使用无效的SSL证书
////SDWebImageAllowInvalidSSLCertificates = 1 << 7,
//
////优先下载
//SDWebImageHighPriority = 1 << 8,
//
////延迟占位符
//SDWebImageDelayPlaceholder = 1 << 9,

//改变动画形象
//SDWebImageTransformAnimatedImage = 1 << 10,

@interface ImagingViewController ()

@prop_strong(UIImageView *, image1)
@prop_strong(UIImageView *, image2)

@end

@implementation ImagingViewController

@def_prop_strong(UIImageView *, image1)
@def_prop_strong(UIImageView *, image2)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 直接加载
    [self.image1 sd_setImageWithURL:[NSURL URLWithString:@""]];
    
    // 给一张默认图片，先使用默认图片，当图片加载完成后再替换
    [self.image1 sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@""]];
    
    // 加载，并获取加载完成的钩子
    [self.image2 sd_setImageWithURL:[NSURL URLWithString:@""] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
     // 图片下载
     SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager.imageDownloader
     downloadImageWithURL:[NSURL URLWithString:@""]
     options:SDWebImageDownloaderLowPriority
     progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
         
     } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
         
     }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
