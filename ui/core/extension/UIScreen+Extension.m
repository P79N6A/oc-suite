//
//  UIScreen+Ex.m
// fallen.ink
//
//  Created by 李杰 on 2/20/15.
//
//

#import "UIScreen+Extension.h"

@implementation UIScreen (Extension)

- (CGRect)currentBounds {
    return [self boundsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}


- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation {
    CGRect bounds = [self bounds];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat buffer = bounds.size.width;
        
        bounds.size.width = bounds.size.height;
        bounds.size.height = buffer;
    }
    return bounds;
}

- (BOOL)isRetinaDisplay {
    static dispatch_once_t predicate;
    static BOOL answer;
    
    dispatch_once(&predicate, ^{
        answer = ([self respondsToSelector:@selector(scale)] && [self scale] == 2);
    });
    return answer;
}

+ (CGFloat)width {
    CGRect bounds = [[UIScreen mainScreen] currentBounds];
    
    return bounds.size.width;
}

+ (CGFloat)height {
    CGRect bounds = [[UIScreen mainScreen] currentBounds];
    return bounds.size.height;
}

+ (CGSize)size {
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGSize)orientationSize {
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion]
                             doubleValue];
    BOOL isLand =   UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    return (systemVersion>8.0 && isLand) ? __SizeSWAP([UIScreen size]) : [UIScreen size];
}

+ (CGFloat)orientationWidth {
    return [UIScreen orientationSize].width;
}

+ (CGFloat)orientationHeight {
    return [UIScreen orientationSize].height;
}

+ (CGSize)DPISize {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    return CGSizeMake(size.width * scale, size.height * scale);
}


/**
 *  交换高度与宽度
 */
static inline CGSize __SizeSWAP(CGSize size) {
    return CGSizeMake(size.height, size.width);
}


@end
