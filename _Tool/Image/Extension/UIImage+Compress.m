//
//  UIImage+SuperCompress.m
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 16/1/22.
//  Copyright © 2016年 Jakey. All rights reserved.
//

#import "UIImage+Compress.h"

@implementation UIImage ( Compress )

+ (UIImage *)resizableHalfImage:(NSString *)name {
    UIImage *normal = [UIImage imageNamed:name];
    
    CGFloat imageW = normal.size.width * 0.5;
    CGFloat imageH = normal.size.height * 0.5;
    return [normal resizableImageWithCapInsets:UIEdgeInsetsMake(imageH, imageW, imageH, imageW)];
}

+ (NSData *)compressImage:(UIImage *)image toMaxLength:(NSInteger)maxLength maxWidth:(NSInteger)maxWidth {
    NSAssert(maxLength > 0, @"图片的大小必须大于 0");
    NSAssert(maxWidth > 0, @"图片的最大边长必须大于 0");
    
    CGSize newSize = [self scaleImage:image withLength:maxWidth];
    UIImage *newImage = [self resizeImage:image withNewSize:newSize];
    
    CGFloat compress = 0.9f;
    NSData *data = UIImageJPEGRepresentation(newImage, compress);
    
    while (data.length > maxLength && compress > 0.01) {
        compress -= 0.02f;
        
        data = UIImageJPEGRepresentation(newImage, compress);
    }
    
    return data;
}

+ (UIImage *)resizeImage:(UIImage *)image withNewSize:(CGSize) newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (CGSize)scaleImage:(UIImage *)image withLength:(CGFloat) imageLength {
    CGFloat newWidth = 0.0f;
    CGFloat newHeight = 0.0f;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    if (width > imageLength || height > imageLength) {
        if (width > height) {
            newWidth = imageLength;
            newHeight = newWidth * height / width;
        } else if(height > width) {
            newHeight = imageLength;
            newWidth = newHeight * width / height;
        } else {
            newWidth = imageLength;
            newHeight = imageLength;
        }
    } else {
        return CGSizeMake(width, height);
    }
    
    return CGSizeMake(newWidth, newHeight);
}

- (UIImage *)compressImageWithJPGCompression:(CGFloat)compressValue {
    /*压缩图片*/
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *pressImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(pressImage, compressValue);
    
    return [UIImage imageWithData:imageData];
}

#pragma mark - 改变图像质量

// 按比例减少尺寸
NS_INLINE CGSize CWSizeReduce(CGSize size, CGFloat limit){
    CGFloat max = MAX(size.width, size.height);
    if (max < limit) {
        NSLog(@"image width not bigger than %f", limit);
        return size;
    }
    
    CGSize imgSize;
    CGFloat ratio = size.height / size.width;
    
    if (size.width > size.height) {
        imgSize = CGSizeMake(limit, limit*ratio);
    } else {
        imgSize = CGSizeMake(limit/ratio, limit);
    }
    
    return imgSize;
}

- (UIImage *)imageWithMaxSide:(CGFloat)length{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize imgSize = CWSizeReduce(self.size, length);
    if (imgSize.height == self.size.height && imgSize.width == self.size.width) {
        return self;
    }
    
    //reduce image size
    UIImage *img = nil;
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, scale);  // 创建一个 bitmap context
    [self drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)
           blendMode:kCGBlendModeNormal alpha:1.0];              // 将图片绘制到当前的 context 上
    img = UIGraphicsGetImageFromCurrentImageContext();            // 从当前 context 中获取刚绘制的图片
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)reducePicQualityIfNeeded:(NSData **)imageData {
    //Max 500K
    float MaxPicSize = 216*1024;
    float maxImageHeight = 600.f;
    UIImage *reduceImage = [self imageWithMaxSide:maxImageHeight];
    
    NSData *pngData = UIImageJPEGRepresentation(reduceImage, 1);
    float compress = 0.65;
    if (pngData.length >= MaxPicSize) {
        while (pngData.length >= MaxPicSize && compress >= 0.1) {
            pngData = UIImageJPEGRepresentation(reduceImage, compress);
            compress -= 0.1;
            NSLog(@"image reduce");
        }
    } else {
        NSLog(@"no reduce image size is %f", pngData.length/1024.0);
    }
    
    NSLog(@"upload pic size is %f", pngData.length/1024.0);
    *imageData = pngData;
    reduceImage = [UIImage imageWithData:pngData];
    
    return reduceImage;
}

@end
