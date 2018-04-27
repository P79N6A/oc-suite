//
//  UIImageView+Factory.m
//  teacher
//
//  Created by fallen.ink on 03/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "UIImageView+Factory.h"
#import "UIImageView+Extension.h"
#import "UIImage+Extension.h"

@implementation UIImageView (Factory)

@end

@implementation UIImageView ( Config )

+ (UIImageView *)instanceWithImage:(NSString *)name tintColor:(UIColor *)color {
    UIImage *image         = [[UIImage imageNamed:name] tintedImageWithColor:color];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode  = UIViewContentModeCenter;
    return imageView;
}

+ (UIImageView *)instanceWithImage:(NSString *)name {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    imageView.contentMode  = UIViewContentModeCenter;
    return imageView;
}

+ (UIImageView *)imageViewWithImageNamed:(NSString *)name tintColor:(UIColor *)color {
    return [self instanceWithImage:name tintColor:color];
}

+ (UIImageView *)imageViewWithImageNamed:(NSString *)name {
    return [self instanceWithImage:name];
}

- (void)setMaskImage:(UIImage *)mask {
    CALayer *thumbMask       = [CALayer layer];
    thumbMask.contents       = (id)mask.CGImage;
    thumbMask.frame          = CGRectMake(0, 0, mask.size.width, mask.size.height);
    self.layer.mask          = thumbMask;
    self.layer.masksToBounds = YES;
}

#define kPSFadeAnimationDuration    0.25

- (void)setImage:(UIImage *)image animated:(BOOL)animated {
    [self setImage:image duration:(animated ? kPSFadeAnimationDuration : 0.)];
}

- (void)setImage:(UIImage *)image duration:(NSTimeInterval)duration {
    if (duration > 0.) {
        CATransition *transition = [CATransition animation];
        
        transition.duration = duration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.layer addAnimation:transition forKey:nil];
    }
    
    self.image = image;
}

@end
