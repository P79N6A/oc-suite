//
//  ImageUtil.h
//  RRPT
//
//  Created by zhenjunfan on 14-8-26.
//  Copyright (c) 2014年 zhenjunfan. All rights reserved.
//

// to read [iOS微信聊天，朋友圈图片压缩算法](http://www.jianshu.com/p/5b77da571a5c)

#import <Foundation/Foundation.h>
#import "_precompile.h"

typedef NS_ENUM(NSInteger, ImageType) {
    kImageTypePic       = 0,
    kImageTypeThird     = 1,
    kImageTypeHead      = 2,
    kImageTypeBanner    = 3,
};

typedef NS_ENUM(NSInteger, ImageSize) {
    kImageSizeSmall = 0,
    kImageSizeBig   = 1,
};

typedef NS_ENUM(NSInteger, ImageOperationType) {
    kImageOperationCrop       = 0,    //切图
    kImageOperationResize     = 1,    //等比缩放
    kImageOperationOrigin     = 2,    //原图
};

typedef NS_ENUM(NSUInteger, ImageFormat) {
    kImageFormatPNG,
    kImageFormatJPG,
    kImageFormatGIF,
};

@interface ImageUtil : NSObject

/**
 * 获取下载url接口，
 *iamge_name 图片名字
 *type 类型 NS_ENUM
 */
+ (NSURL *)imageUrl:(NSString *)imageName size:(NSInteger)size type:(NSInteger)type;

/**
 * 新版图片下载地址
 */
+ (NSString*)urlForDownloadImageWithPath:(NSString*)path
                               Operation:(ImageOperationType)opertaion
                                    Size:(CGSize)size;

/*
 * 缩放图像
 */
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

/*
 * 等比缩放图像
 */
+ (UIImage *)scaleImage:(UIImage*)image ratio:(CGFloat)ratio;

/*
 * 等比缩放图像,指定最短边像素数
 */
+ (UIImage *)scaleImage:(UIImage*)image minSide:(CGFloat)minSide;

/*
 * 压缩图像，为上传图片用，最小边分辨率为720,控制在300K以下
 */
+ (NSData*)compressImageForUpload:(UIImage*)img;

/**
 * 对照片进行处理之前，先将照片旋转到正确的方向，并且返回的imageOrientaion为0。执行时长0.5s
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

/**
 * 对照片进行处理之前，先将照片旋转到正确的方向，并且返回的imageOrientaion为0。执行时长0.4s
 */
+ (UIImage *)fastFixOrientation:(UIImage *)aImage;

+ (NSData *)compressThumbImage:(UIImage *)desImage;

#pragma mark - 

+ (UIView *)emptyDataBGView:(NSString *)imageName waringStr:(NSString *)waringStr;

+ (UIImage *)getImageFromURL:(NSString *)fileURL;

#pragma mark 将16进制颜色值转换为UIColor

+ (UIColor*) colorWithRgb:(int)color;

#pragma mark 保持网络图片至本地
//+ (NSString*)saveImageLocal:(NSData*)data;

//对图片尺寸进行压缩--
+ (UIImage*)reduce:(UIImage*)image size:(CGSize)size isAdjust:(BOOL)isAdjust;
// 根据view截图
+ (UIImage*)cutView:(UIView*)view;

// 根据view截图, 指定范围
+ (UIImage*)cutView:(UIView*)view size:(CGSize)size;

@end

#define URL_HEAD_SMALL(imagename) [ImageUtil imageUrl:imagename size:kImageSizeSmall type:kImageTypeHead]




