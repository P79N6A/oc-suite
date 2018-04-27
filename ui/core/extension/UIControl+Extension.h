//
//  UIControl+Convenience.h
//  component
//
//  Created by fallen.ink on 4/7/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// inspired by https://github.com/egold/UIKitConvenience/tree/master/UIKitConvenience

@interface UIControl ( Target_Action )

- (void)removeAllTargetActionEvents;

@end

#pragma mark -

// inspired by http://www.cocoachina.com/ios/20150911/13260.html

/**
 *  Usage
 
 *  UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
 *  [tempBtn addTarget:self action:@selector(clickWithInterval:) forControlEvents:UIControlEventTouchUpInside];
 *  tempBtn.uxy_acceptEventInterval = 0.5;
 
 */
@interface UIControl ( Event )

@property (nonatomic, assign) NSTimeInterval acceptEventInterval;

@property (nonatomic, assign) BOOL ignoreEvent;

@end

#pragma mark -

@interface UIControl ( Sound )

/// Set the sound for a particular control event (or events).
/// @param name The name of the file. The method looks for an image with the specified name in the application’s main bundle.
/// @param controlEvent A bitmask specifying the control events for which the action message is sent. See “Control Events” for bitmask constants.
//不同事件增加不同声音
- (void)setSoundNamed:(NSString *)name forControlEvent:(UIControlEvents)controlEvent;

@end

