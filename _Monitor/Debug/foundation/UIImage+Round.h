//
//  UIImage+Round.h
//  wesg
//
//  Created by 7 on 22/08/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Round)

+ (UIImage *)_imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)_imageWithRoundedCornersSize:(float)cornerRadius;

@end
