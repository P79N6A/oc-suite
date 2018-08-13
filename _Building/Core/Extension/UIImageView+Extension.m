//
//  UIImageView+Filter.m
//  component
//
//  Created by fallen.ink on 4/13/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "UIImageView+Extension.h"
#import "UIImage+Extension.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Arbitrary tag so that we can identify filtered images.
// Otherwise we risk removing a custom subview that isn't a filter.
#define IMAGE_FILTER_TAG 123454321

@implementation UIImageView (Filter)

- (void)applyFilter:(CIFilter *)filter
  animationDuration:(NSTimeInterval)animationDuration
   animationOptions:(UIViewAnimationOptions)animationOptions
         completion:(void (^)(void))completionBlock {
    
    [self.image applyFilter:filter completion:^(UIImage *filteredImage) {
        // Remove any previous filters
        [self removeFilter];
        
        // Add the filtered image on top of the original image.
        UIImageView *filteredImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        filteredImageView.tag = IMAGE_FILTER_TAG;
        [self addSubview:filteredImageView];
        
        // No animation
        if (animationDuration == 0.0f) {
            filteredImageView.image = filteredImage;
            if (completionBlock) {
                completionBlock();
            }
            return;
        }
        
        // Animation
        [UIView transitionWithView:self
                          duration:animationDuration
                           options:animationOptions
                        animations:^{
                            filteredImageView.image = filteredImage;
                        } completion:^(BOOL finished) {
                            if (completionBlock) {
                                completionBlock();
                            }
                        }];
    }];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset
            animationDuration:(NSTimeInterval)animationDuration
             animationOptions:(UIViewAnimationOptions)animationOptions
                   completion:(void (^)(void))completionBlock {
    CIFilter *filter = [self.image filterWithPreset:preset];
    [self applyFilter:filter
    animationDuration:animationDuration
     animationOptions:animationOptions
           completion:completionBlock];
}

- (void)applyFilter:(CIFilter *)filter
           animated:(BOOL)animated
         completion:(void (^)(void))completionBlock {
    [self applyFilter:filter
    animationDuration:animated ? 0.3f : 0.0f
     animationOptions:UIViewAnimationOptionTransitionCrossDissolve
           completion:completionBlock];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                     animated:(BOOL)animated
                   completion:(void (^)(void))completionBlock {
    CIFilter *filter = [self.image filterWithPreset:preset];
    [self applyFilter:filter
             animated:animated
           completion:completionBlock];
}

- (void)applyFilter:(CIFilter *)filter
         completion:(void (^)(void))completionBlock {
    [self applyFilter:filter animated:NO completion:completionBlock];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                   completion:(void (^)(void))completionBlock {
    CIFilter *filter = [self.image filterWithPreset:preset];
    [self applyFilter:filter
           completion:completionBlock];
}

- (void)applyFilter:(CIFilter *)filter {
    [self applyFilter:filter completion:nil];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset {
    CIFilter *filter = [self.image filterWithPreset:preset];
    [self applyFilter:filter];
}

- (void)removeFilter {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]] &&
            subview.tag == IMAGE_FILTER_TAG) {
            [subview removeFromSuperview];
        }
    }
}

@end

#pragma mark - WaterMark

@implementation UIImageView ( WaterMark )

// 画水印
- (void)setImage:(UIImage *)image withWaterMark:(UIImage *)mark inRect:(CGRect)rect {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    // CGContextRef thisctx = UIGraphicsGetCurrentContext();
    // CGAffineTransform myTr = CGAffineTransformMake(1, 0, 0, -1, 0, self.height);
    // CGContextConcatCTM(thisctx, myTr);
    //CGContextDrawImage(thisctx,CGRectMake(0,0,self.width,self.height),[image CGImage]); //原图
    //CGContextDrawImage(thisctx,rect,[mask CGImage]); //水印图
    //原图
    [image drawInRect:self.bounds];
    //水印图
    [mark drawInRect:rect];
    // NSString *s = @"dfd";
    // [[UIColor redColor] set];
    // [s drawInRect:self.bounds withFont:[UIFont systemFontOfSize:15.0]];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}

- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    
    //原图
    [image drawInRect:self.bounds];
    //文字颜色
    [color set];
    // const CGFloat *colorComponents = CGColorGetComponents([color CGColor]);
    // CGContextSetRGBFillColor(context, colorComponents[0], colorComponents[1], colorComponents [2], colorComponents[3]);
    //水印文字
    if ([markString respondsToSelector:@selector(drawInRect:withAttributes:)]) {
        [markString drawInRect:rect withAttributes:@{NSFontAttributeName:font}];
    } else {
        // pre-iOS7.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [markString drawInRect:rect withFont:font];
#pragma clang diagnostic pop
    }
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}

- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    
    //原图
    [image drawInRect:self.bounds];
    //文字颜色
    [color set];
    //水印文字
    
    if ([markString respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
        [markString drawAtPoint:point withAttributes:@{NSFontAttributeName:font}];
    } else {
        // pre-iOS7.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [markString drawAtPoint:point withFont:font];
#pragma clang diagnostic pop
    }
    
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}


@end

// MARK: - Shape

@implementation UIImageView (shape)

- (void)setContentLayer:(CALayer *)contentLayer {
    objc_setAssociatedObject(self, @"kContentLayerKey", contentLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CALayer *)contentLayer {
    return objc_getAssociatedObject(self, @"kContentLayerKey");
}

- (void)shapeWithPath:(CGPathRef)path {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = path;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.strokeColor = [UIColor clearColor].CGColor;
    maskLayer.frame = self.bounds;
    maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    maskLayer.contentsScale = [UIScreen mainScreen].scale;
    
    self.contentLayer = [CALayer layer];
    self.contentLayer.mask = maskLayer;
    self.contentLayer.frame = self.bounds;
    [self.layer addSublayer:self.contentLayer];
}

- (void)setShapedImage:(UIImage *)image {
    self.contentLayer.contents = (id)image.CGImage;
}

@end

