//
//  UIColor+Extension.h
//  hairdresser
//
//  Created by fallen.ink on 6/8/16.
//
//

#import <UIKit/UIKit.h>

@interface UIColor ( Extension )

// Color builders
+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

+ (UIColor *)colorWithRGBString:(NSString *)rgbString;

// Extract color from Image
+ (UIColor *)getPixelColorAtLocation:(CGPoint)point inImage:(UIImage *)image;

/**
 *  根据大小声称image
 *
 *  @param size 大小
 *
 *  @return UIImage *
 */
- (UIImage *)imageSized:(CGSize)size;

@end

#pragma mark - Gradient

@interface UIColor ( Gradient )
/**
 *  @brief  渐变颜色
 *
 *  @param c1     开始颜色
 *  @param c2     结束颜色
 *  @param height 渐变高度
 *
 *  @return 渐变颜色
 */
+ (UIColor *)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height;

@end

#pragma mark - Components 组成

@interface UIColor ( Components )

/* rgba, like: [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0], it's not suitable for  [UIColor grayColor]
 
 Example:
    UIColor *testColor = [UIColor colorWithRed:0.4 green:0.5 blue:0.6 alpha:0.7];
 Print:
    red = 0.400000, green = 0.500000, blue = 0.600000, alpha = 0.700000
 */
@property (readonly) CGFloat rValue;
@property (readonly) CGFloat gValue;
@property (readonly) CGFloat bValue;
@property (readonly) CGFloat aValue;

/* 未测试:http://blog.chinaunix.net/uid-24875436-id-3000791.html */

@property (readonly) CGFloat yValue; // 亮度 0~1, 其他两个是色度
@property (readonly) CGFloat crValue;
@property (readonly) CGFloat cbValue;

@end


