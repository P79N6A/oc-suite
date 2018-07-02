
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ImageFilterPreset)
{
    ImageFilterPresetBlackAndWhite,
    ImageFilterPresetSepiaTone,
    ImageFilterPresetPixelate
};

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Filter)

/** Asynchronously applies 'filter' to the target image and
 returns the filtered image in the block.
 The target image remains unchanged.
 */
- (void)applyFilter:(CIFilter *)filter completion:(void (^)(UIImage *filteredImage))completion;

/// @return A UIImage from the filter.
+ (UIImage *)imageWithFilter:(CIFilter *)filter;

/// @return A filter using a common preset.
- (CIFilter *)filterWithPreset:(ImageFilterPreset)preset;

@end

@interface UIImage ( Blur )

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

- (UIImage *)blurredImageWithRadius:(CGFloat)blurRadius;
- (UIImage *)blurredImageWithSize:(CGSize)blurSize;
- (UIImage *)blurredImageWithSize:(CGSize)blurSize
                        tintColor:(nullable UIColor *)tintColor
            saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                        maskImage:(nullable UIImage *)maskImage;

#pragma mark - 

- (UIImage *)boxblurImageWithBlur:(CGFloat)blur;

@end

@interface UIImage ( Color )
/**
 *  @brief  根据颜色生成纯色图片
 *
 *  @param color 颜色
 *
 *  @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

/**
 *  @brief  取图片某一点的颜色
 *
 *  @param point 某一点
 *
 *  @return 颜色
 */
- (UIColor *)colorAtPoint:(CGPoint )point;

//more accurate method ,colorAtPixel 1x1 pixel
/**
 *  @brief  取某一像素的颜色
 *
 *  @param point 一像素
 *
 *  @return 颜色
 */
- (UIColor *)colorAtPixel:(CGPoint)point;

/**
 *  @brief  返回该图片是否有透明度通道
 *
 *  @return 是否有透明度通道
 */
- (BOOL)hasAlphaChannel;

/**
 *  @brief  获得灰度图
 *
 *  @param sourceImage 图片
 *
 *  @return 获得灰度图片
 */
+ (UIImage *)covertToGrayImageFromImage:(UIImage *)sourceImage;

- (UIImage *)imageWithBackgroundColor:(UIColor *)bgColor
                          shadeAlpha1:(CGFloat)alpha1
                          shadeAlpha2:(CGFloat)alpha2
                          shadeAlpha3:(CGFloat)alpha3
                          shadowColor:(UIColor *)shadowColor
                         shadowOffset:(CGSize)shadowOffset
                           shadowBlur:(CGFloat)shadowBlur;

- (UIImage *)imageWithShadowColor:(UIColor *)shadowColor
                     shadowOffset:(CGSize)shadowOffset
                       shadowBlur:(CGFloat)shadowBlur;

@end


NS_ASSUME_NONNULL_END
