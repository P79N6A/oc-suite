//
//  UIImageView+Filter.h
//  component
//
//  Created by fallen.ink on 4/13/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Extension.h"

@interface UIImageView ( Filter )

/*
 Apply 'filter' to the image view's image.
 The filter application can be animated with custom duration
 and options.
 When the filter has finished being applied, the completionBlock is called.
 */
- (void)applyFilter:(CIFilter *)filter
  animationDuration:(NSTimeInterval)animationDuration
   animationOptions:(UIViewAnimationOptions)animationOptions
         completion:(void (^)(void))completionBlock;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset
            animationDuration:(NSTimeInterval)animationDuration
             animationOptions:(UIViewAnimationOptions)animationOptions
                   completion:(void (^)(void))completionBlock;

/*
 Apply 'filter' to the image view's image.
 If 'animated' is YES, the filter application is animated
 with a cross-disolve effect for a duration of 0.3 seconds.
 When the filter has finished being applied, the completionBlock is called.
 */
- (void)applyFilter:(CIFilter *)filter
           animated:(BOOL)animated
         completion:(void (^)(void))completionBlock;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                     animated:(BOOL)animated
                   completion:(void (^)(void))completionBlock;

/*
 Apply 'filter' to the image view's image without animation.
 When the filter has finished being applied, the completionBlock is called.
 */
- (void)applyFilter:(CIFilter *)filter
         completion:(void (^)(void))completionBlock;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                   completion:(void (^)(void))completionBlock;

/*
 Apply 'filter' to the image view's image without animation.
 */
- (void)applyFilter:(CIFilter *)filter;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset;

/*
 Remove any filters applied.  This bring back the original image.
 */
- (void)removeFilter;

@end

#pragma mark - WaterMark

@interface UIImageView ( WaterMark )

// 图片水印
- (void)setImage:(UIImage *)image withWaterMark:(UIImage *)mark inRect:(CGRect)rect;

// 文字水印
- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font;

- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font;

@end

// MARK: - Shape

@interface UIImageView (shape)

@property (nonatomic, strong) CALayer *contentLayer;

- (void)shapeWithPath:(CGPathRef)path;

- (void)setShapedImage:(UIImage *)image;

@end


