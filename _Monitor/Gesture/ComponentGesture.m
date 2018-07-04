//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#import "ComponentGesture.h"
#import "ComponentGestureHook.h"
#import "ComponentGestureView.h"
#import "ComponentGestureSetting.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentGesture

- (void)install {
    [super install];
    
	[NSObject gestureHook];
}

- (void)uninstall {
    [super uninstall];
}

- (void)powerOn {
    [super powerOn];
}

- (void)powerOff {
    [super powerOff];
}

- (void)whenDockerOpen {
	[[ComponentGestureSetting sharedInstance] enable];
}

- (void)whenDockerClose {
	[[ComponentGestureSetting sharedInstance] disable];
}

@end
