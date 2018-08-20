//
//  UIImage+Round.m
//  wesg
//
//  Created by 7 on 22/08/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "UIImage+Round.h"

@implementation UIImage (Round)

/**
 * 将UIColor变换为UIImage
 *
 **/
+ (UIImage *)_imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

//生成圆角UIIamge 的方法
- (UIImage *)_imageWithRoundedCornersSize:(float)cornerRadius {
    UIImage *original = self;
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:cornerRadius] addClip];
    
    [original drawInRect:frame];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
