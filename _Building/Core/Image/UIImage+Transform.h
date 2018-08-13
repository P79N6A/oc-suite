//
//  UIImage+JKOrientation.h
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 15/1/4.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

inline static CGFloat DegreesToRadiansForOrientation(CGFloat degrees) {return degrees * M_PI / 180;};
inline static CGFloat RadiansToDegreesForOrientation(CGFloat radians) {return radians * 180/M_PI;};

@interface UIImage ( Transform )

#pragma mark - Orientation

/**
 *  @brief  修正图片的方向
 *
 *  @param srcImg 图片
 *
 *  @return 修正方向后的图片
 */
+ (UIImage *)fixOrientation:(UIImage *)srcImg;

/**
 *  @brief  旋转图片
 *
 *  @param degrees 角度
 *
 *  @return 旋转后图片
 */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

/**
 *  @brief  旋转图片
 *
 *  @param radians 弧度
 *
 *  @return 旋转后图片
 */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

/**
 *  @brief  垂直翻转
 *
 *  @return  翻转后的图片
 */
- (UIImage *)flipVertical;

/**
 *  @brief  水平翻转
 *
 *  @return 翻转后的图片
 */
- (UIImage *)flipHorizontal;

/**
 *  @brief  角度转弧度
 *
 *  @param degrees 角度
 *
 *  @return 弧度
 */
+ (CGFloat)degreesToRadians:(CGFloat)degrees;

/**
 *  @brief  弧度转角度
 *
 *  @param radians 弧度
 *
 *  @return 角度
 */
+ (CGFloat)radiansToDegrees:(CGFloat)radians;

#pragma mark - Resize

- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

#pragma mark - 

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

@end
