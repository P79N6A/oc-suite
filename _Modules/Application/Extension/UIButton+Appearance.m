//
//  UIButton+Theme.m
// fallen.ink
//
//  Created by 李杰 on 4/20/15.
//
//

#import <_Building/UIColor+Extension.h>
#import "UIButton+Appearance.h"
#import "UIColor+Appearance.h"
#import "UIView+Extension.h"
#import "_AppAppearance.h"

#pragma mark -

@implementation UIButton (Appearance)

- (void)liningStyled:(UIColor *)color {
    [self setBorderWidth:1.f withColor:color];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTitleColor:color];
}

- (void)liningStyledWithTitleColor:(UIColor *)color borderColor:(UIColor *)bordercolor {
    [self setBorderWidth:1.f withColor:bordercolor];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTitleColor:color];
}

- (void)colorlumpStyled:(UIColor *)color {
    [self setNormalBackgroundColor:color
            disableBackgroundColor:[UIColor colorWithRGBHex:0xcccccc]];
    
    [self setTitleColor:[UIColor whiteColor]];
}

- (void)thematized {
    [self colorlumpStyled:color_theme];
    
    [self circularCorner];
}

- (void)liningThematized:(UIColor *)color {
    [self liningStyled:color];
    
    [self circularCorner];
}

- (void)liningThematizedWithTextColor:(UIColor *)color borderColor:(UIColor *)bordercolor {
    [self liningStyledWithTitleColor:color borderColor:bordercolor];
    
    [self circularCorner];
}

- (void)colorlumpThematized:(UIColor *)color {
    [self colorlumpStyled:color];
    
    [self circularCorner];
}

- (void)thematizedWithBackgroundColor:(UIColor*)backgroundColor {
    [self colorlumpStyled:backgroundColor];
    
    [self circularCorner];
}

@end
