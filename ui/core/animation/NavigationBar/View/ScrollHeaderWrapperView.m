//
//  ScrollHeaderWrapperView.m
//  student
//
//  Created by fallen.ink on 07/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_frame.h"
#import "ScrollHeaderWrapperView.h"

@interface ScrollHeaderWrapperView ()

@property (nonatomic, assign) CGFloat initOffsetY;
@property (nonatomic, assign) CGRect initStretchViewFrame;
@property (nonatomic, assign) CGFloat initSelfHeight;
@property (nonatomic, assign) CGFloat initContentHeight;

@end

@implementation ScrollHeaderWrapperView

+ (instancetype)instanceWithFrame:(CGRect)frame contentView:(UIView *)contentView stretchView:(UIView *)stretchView
{
    ScrollHeaderWrapperView *scrollHeaderWrapperView = [[ScrollHeaderWrapperView alloc] init];
    scrollHeaderWrapperView.frame = frame;
    scrollHeaderWrapperView.contentView = contentView;
    scrollHeaderWrapperView.stretchView = stretchView;
    
    scrollHeaderWrapperView.contentMode = UIViewContentModeScaleAspectFill;
    scrollHeaderWrapperView.clipsToBounds = YES;
    return scrollHeaderWrapperView;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    if (newSuperview != nil) {
        [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        UIScrollView *scrollView = (UIScrollView *)newSuperview;
        
        self.initOffsetY = scrollView.contentOffset.y;
        self.initStretchViewFrame = self.stretchView.frame;
        self.initSelfHeight = self.height;
        self.initContentHeight = self.contentView.height;
    }
    
}

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    [self addSubview:contentView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat offsetY = [change[@"new"] CGPointValue].y - self.initOffsetY;
    
    if (offsetY > 0) {
        self.stretchView.y = self.initStretchViewFrame.origin.y + offsetY;
        self.stretchView.height = self.initStretchViewFrame.size.height - offsetY;
        
    } else {
        self.stretchView.y = self.initStretchViewFrame.origin.y + offsetY;
        self.stretchView.height = self.initStretchViewFrame.size.height - offsetY;
    }
}


@end
