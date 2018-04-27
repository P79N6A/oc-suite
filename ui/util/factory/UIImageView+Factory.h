//
//  UIImageView+Factory.h
//  teacher
//
//  Created by fallen.ink on 03/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Factory)

@end

@interface UIImageView ( Config )

+ (UIImageView *)instanceWithImage:(NSString *)name tintColor:(UIColor *)color;
+ (UIImageView *)instanceWithImage:(NSString *)name;

+ (UIImageView *)imageViewWithImageNamed:(NSString *)name tintColor:(UIColor *)color;
+ (UIImageView *)imageViewWithImageNamed:(NSString *)name;

- (void)setMaskImage:(UIImage *)mask;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;
- (void)setImage:(UIImage *)image duration:(NSTimeInterval)duration;

@end
