//
//  UIImage+Effects.h
//  component
//
//  Created by fallen.ink on 4/13/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @fallenink: iOS 8.0 之后：UIVisualEffectView！！！！！！
 */

// inspired by https://github.com/ThePantsThief/Objc-iOS-Extensions/blob/master/Pod/Classes/UIImage%2BEffects.h

@interface UIImage (Effects)

- (UIImage *)imageByApplyingLightEffect;
- (UIImage *)imageByApplyingExtraLightEffect;
- (UIImage *)imageByApplyingDarkEffect;
- (UIImage *)imageByApplyingTintEffectWithColor:(UIColor *)tintColor;

//! Applies a blur, tint color, and saturation adjustment to @a inputImage,
//! optionally within the area specified by @a maskImage.
//!
//! @param  blurRadius
//!         The radius of the blur in points.
//! @param  tintColor
//!         An optional UIColor object that is uniformly blended with the
//!         result of the blur and saturation operations.  The alpha channel
//!         of this color determines how strong the tint is.
//! @param  saturationDeltaFactor
//!         A value of 1.0 produces no change in the resulting image.  Values
//!         less than 1.0 will desaturation the resulting image while values
//!         greater than 1.0 will have the opposite effect.
//! @param  maskImage
//!         If specified, @a inputImage is only modified in the area(s) defined
//!         by this mask.  This must be an image mask or it must meet the
//!         requirements of the mask parameter of CGContextClipToMask.
- (UIImage *)imageByApplyingBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

/// @discussion Saturation delta factor defaults to 1.8, and maskImage nil.
- (UIImage *)imageByApplyingBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor;

@end
