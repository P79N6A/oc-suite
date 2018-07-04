//
//  _docker_window.m
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_docker_window.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation _DockerWindow

- (id)init {
    self = [super init];
    if ( self ) {
        //	self.alpha = 0.75f;
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 2.0f;
        self.rootViewController = [[UIViewController alloc] init];
        
        [self observeNotification:UIApplicationWillChangeStatusBarOrientationNotification];
        [self observeNotification:UIApplicationDidChangeStatusBarOrientationNotification];
    }
    return self;
}

- (void)dealloc {
    [self unobserveAllNotifications];
}

- (void)addDockerView:(_DockerView *)docker {
    [self addSubview:docker];
}

- (void)removeDockerView:(_DockerView *)docker {
    if ( docker.superview == self ) {
        [docker removeFromSuperview];
    }
}

- (void)removeAllDockerViews {
    NSMutableArray *subDockerViews = [NSMutableArray new];
    
    for ( UIView * subview in self.subviews ) {
        if ( [subview isKindOfClass:[_DockerView class]] ) {
            [subDockerViews addObject:subview];
        }
    }
    
    [subDockerViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)relayoutAllDockerViews {
    NSMutableArray * dockerViews = [NSMutableArray nonRetainingArray];
    
    for ( UIView * subview in self.subviews ) {
        if ( [subview isKindOfClass:[_DockerView class]] )
        {
            [dockerViews addObject:subview];
        }
    }
    
#define DOCKER_RIGHT	10.0f
#define DOCKER_BOTTOM	64.0f
#define DOCKER_MARGIN	4.0f
#define DOCKER_HEIGHT	30.0f
    
    CGRect windowBound;
    windowBound.size.width = DOCKER_HEIGHT;
    windowBound.size.height = dockerViews.count * (DOCKER_HEIGHT + DOCKER_MARGIN);
    windowBound.origin.x = [UIScreen mainScreen].bounds.size.width - windowBound.size.width - DOCKER_RIGHT;
    windowBound.origin.y = [UIScreen mainScreen].bounds.size.height - windowBound.size.height - DOCKER_BOTTOM;
    self.frame = windowBound;
    
    for ( _DockerView * dockerView in dockerViews ) {
        CGRect dockerFrame;
        dockerFrame.size.width = DOCKER_HEIGHT;
        dockerFrame.size.height = DOCKER_HEIGHT;
        dockerFrame.origin.x = 0.0f;
        dockerFrame.origin.y = (DOCKER_HEIGHT + DOCKER_MARGIN) * [dockerViews indexOfObject:dockerView];
        dockerView.frame = dockerFrame;
    }
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
}

#pragma mark - 

- (void)handleNotification:(NSNotification *)notification {
    if ([notification is:UIApplicationWillChangeStatusBarOrientationNotification] ||
        [notification is:UIApplicationDidChangeStatusBarOrientationNotification]) {
        
        [self relayoutAllDockerViews];
    }
}

@end
