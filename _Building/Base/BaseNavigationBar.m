//
//  BaseNavigationBar.m
//  consumer
//
//  Created by fallen.ink on 9/5/16.
//
//

#import "_precompile.h"
#import "BaseNavigationBar.h"

@interface BaseNavigationBar ()

@property (nonatomic, strong) CALayer *colorLayer;

@end


@implementation BaseNavigationBar

static CGFloat const kDefaultColorLayerOpacity = 0.5f;
static CGFloat const kSpaceToCoverStatusBars = 20.0f;

- (void)setBarTintColor:(UIColor *)barTintColor {
    
    [super setBarTintColor:barTintColor];
    
    // iOS 7.1 seems to completely ignore the alpha channel and any modifications to it.
    // Hence, adding an extra layer is moot.
    // Still looking into possible solutions for this, but for now, this method is empty.
    if (system_version_greater_than_or_equal_to(@"7.1")) {
    
    }
    // As of iOS 7.0.3, colors definitely seem a little bit more saturated.
    else if (system_version_greater_than_or_equal_to(@"7.0.3")) {
        
        // Override the opacity if wanted.
        if(self.overrideOpacity) {
            CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
            [barTintColor getRed:&red green:&green blue:&blue alpha:&alpha];
            [super setBarTintColor:[UIColor colorWithRed:red green:green blue:blue alpha:kDefaultNavigationBarAlpha]];
        }
        
        // This code isn't perfect and has been commented out for now. It seems like
        // the additional color layer doesn't work well now that translucency is based
        // primarily on the opacity of the navigation bar (and its respective layers).
        // However, if you'd like to experiment, feel free to uncomment this out and
        // give it a spin.
        
        // if (self.colorLayer == nil) {
        //    self.colorLayer = [CALayer layer];
        //    self.colorLayer.opacity = kDefaultColorLayerOpacity - 0.2f;
        //    [self.layer addSublayer:self.colorLayer];
        // }
        
        // self.colorLayer.backgroundColor = barTintColor.CGColor;
    }
    // iOS 7.0 benefits from the extra color layer.
    else {
        
        // Create a CALayer with some opacity, and add the layer.
        if (self.colorLayer == nil) {
            self.colorLayer = [CALayer layer];
            self.colorLayer.opacity = kDefaultColorLayerOpacity;
            [self.layer addSublayer:self.colorLayer];
        }
        
        self.colorLayer.backgroundColor = barTintColor.CGColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.colorLayer != nil) {
        self.colorLayer.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
        
        [self.layer insertSublayer:self.colorLayer atIndex:1];
    }
}

- (void)displayColorLayer:(BOOL)display {
    self.colorLayer.hidden = !display;
}

@end
