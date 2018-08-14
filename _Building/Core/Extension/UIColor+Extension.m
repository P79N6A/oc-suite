//
//  UIColor+Extension.m
//  hairdresser
//
//  Created by fallen.ink on 6/8/16.
//
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

#pragma mark Class methods

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    return [self colorWithHexString:hexString alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    // 删除字符串中的空格
    hexString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([hexString length] < 6) {
        return [UIColor clearColor];
    }
    if ([hexString hasPrefix:@"0X"] ||
        [hexString hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    if ([hexString length] != 6) {
        return [UIColor clearColor];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor colorWithRGBHex:hexNum alpha:alpha];
}

+ (UIColor *)colorWithRGBString:(NSString *)rgbString {
    if (!rgbString || ![rgbString isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSArray *colorArray = [rgbString componentsSeparatedByString:@","];
    if ([colorArray count] < 3) {
        return nil;
    }
    UIColor *color = [UIColor colorWithRed:[[colorArray objectAtIndex:0] floatValue]/255.0 green:[[colorArray objectAtIndex:1] floatValue]/255.0 blue:[[colorArray objectAtIndex:2] floatValue]/255.0 alpha:1];
    return color;
}


#pragma mark -

+ (UIColor*) getPixelColorAtLocation:(CGPoint)point inImage:(UIImage *)image {
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:
                          inImage];
    
    if (cgctx == NULL) { return nil; /* error */ }
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    if (data != NULL) {
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,
              blue,alpha);
        
        NSLog(@"x:%f y:%f", point.x, point.y);
        
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:
                 (blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    CGContextRelease(cgctx);
    
    if (data) { free(data); }
    
    return color;
}

+ (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    
    CGColorSpaceRef colorSpace;
    
    void *          bitmapData;
    
    unsigned long             bitmapByteCount;
    
    unsigned long             bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
        
    {
        
        fprintf(stderr, "Error allocating color space\n");
        
        return NULL;
        
    }
    
    bitmapData = malloc( bitmapByteCount );
    
    if (bitmapData == NULL)
        
    {
        
        fprintf (stderr, "Memory not allocated!");
        
        CGColorSpaceRelease( colorSpace );
        
        return NULL;
        
    }
    
    context = CGBitmapContextCreate (bitmapData,
                                     
                                     pixelsWide,
                                     
                                     pixelsHigh,
                                     
                                     8,
                                     
                                     bitmapBytesPerRow,
                                     
                                     colorSpace,
                                     
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL)
        
    {
        
        free (bitmapData);
        
        fprintf (stderr, "Context not created!");
        
    }
    
    CGColorSpaceRelease( colorSpace );
    
    return context;
    
}

#pragma mark -

- (UIImage *)imageSized:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

#pragma mark - 

@implementation UIColor ( Gradient )

/**
 *  @brief  渐变颜色
 *
 *  @param c1     开始颜色
 *  @param c2     结束颜色
 *  @param height 渐变高度
 *
 *  @return 渐变颜色
 */
+ (UIColor*)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height {
    CGSize size = CGSizeMake(1, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    NSArray* colors = [NSArray arrayWithObjects:(id)c1.CGColor, (id)c2.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:image];
}

@end

#pragma mark - Components

@implementation UIColor ( YUV )

- (CGFloat *)rgbaComponentsWithNumbers:(int32_t *)count {
    CGColorRef color = [self CGColor];
    size_t numbers = CGColorGetNumberOfComponents(color);
    
    if (count) {
        *count = (int32_t)numbers;
    }
    
    CGFloat *components = (CGFloat *)CGColorGetComponents(color);
    
    if (numbers == 2) {
        NSLog(@"r=%f, g=%f, b=%f, a=%f", components[0], components[0], components[0], components[1]);
    } else if (numbers == 4) {
        NSLog(@"r=%f, g=%f, b=%f, a=%f", components[0], components[1], components[2], components[3]);
    } else {
        [NSException raise:@"UIColor" format:@"rgba components exception" arguments:nil];
    }
    
    return components;
}

- (CGFloat)rValue {
    return [self rgbaComponentsWithNumbers:nil][0];
}

- (CGFloat)gValue {
    int32_t count = 0;
    
    CGFloat *components = [self rgbaComponentsWithNumbers:&count];
    
    if (count == 2) return components[0];
    if (count == 4) return components[1];
    
    return 0.f;
}

- (CGFloat)bValue {
    int32_t count = 0;
    
    CGFloat *components = [self rgbaComponentsWithNumbers:&count];
    
    if (count == 2) return components[0];
    if (count == 4) return components[2];
    
    return 0.f;
}

- (CGFloat)aValue {
    int32_t count = 0;
    
    CGFloat *components = [self rgbaComponentsWithNumbers:&count];
    
    if (count == 4) return components[3];
    
    return 0.f;
}

/**
 // BT.601, which is the standard for SDTV is provided as a reference
 rgb = mat3(      1,       1,       1,
     0, -.39465, 2.03211,
     1.13983, -.58060,       0) * yuv;

 // Using BT.709 which is the standard for HDTV
 rgb = mat3(      1,       1,       1,
           0, -.21482, 2.12798,
           1.28033, -.38059,       0) * yuv;
 */

- (CGFloat)yValue {
    CGFloat red = self.rValue;
    CGFloat green = self.gValue;
    CGFloat blue = self.bValue;
    
    return 0.299 * red + 0.587 * green + 0.114 * blue;
}

- (CGFloat)crValue {
    CGFloat red = self.rValue;
    CGFloat green = self.gValue;
    CGFloat blue = self.bValue;

    return 0.500 * red - 0.419 * green - 0.081 * blue;
}

- (CGFloat)cbValue {
    CGFloat red = self.rValue;
    CGFloat green = self.gValue;
    CGFloat blue = self.bValue;
    
    return - 0.169 * red - 0.331 * green + 0.500 * blue;
}

@end
