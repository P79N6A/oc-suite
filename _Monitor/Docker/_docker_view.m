//
//  _docker_view.m
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_docker_view.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation _DockerView {
    UIButton *	_openButton;
    UIButton *	_closeButton;
}

@def_prop_unsafe( id<ManagedDocker> *,	handler );

- (id)init {
    self = [super init];
    if ( self ) {
        self.backgroundColor = [UIColor clearColor];
        
        _openButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _openButton.hidden = NO;
        _openButton.backgroundColor = [UIColor clearColor];
        _openButton.adjustsImageWhenHighlighted = YES;
        [_openButton addTarget:self action:@selector(onOpen) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_openButton];
        
        _closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _closeButton.hidden = YES;
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.adjustsImageWhenHighlighted = YES;
        [_closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect buttonFrame;
    buttonFrame.origin = CGPointZero;
    buttonFrame.size = frame.size;
    
    _openButton.frame = buttonFrame;
    _closeButton.frame = buttonFrame;
}

- (void)setImageOpened:(UIImage *)image {
    [_openButton setImage:image forState:UIControlStateNormal];
}

- (void)setImageClosed:(UIImage *)image {
    [_closeButton setImage:image forState:UIControlStateNormal];
}

- (void)onOpen {
    _openButton.hidden = YES;
    _closeButton.hidden = NO;
    
    if ( [self.handler respondsToSelector:@selector(whenDockerOpen)] ) {
        [self.handler whenDockerOpen];
    }
}

- (void)onClose {
    _openButton.hidden = NO;
    _closeButton.hidden = YES;
    
    if ( [self.handler respondsToSelector:@selector(whenDockerClose)] ) {
        [self.handler whenDockerClose];
    }
}


@end
