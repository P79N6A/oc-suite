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

#import "ComponentBorder.h"
#import "ComponentBorderHook.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentBorder

- (BOOL)autoinstall {
    TODO("@王涛")
    return NO;
}

- (void)install {
    [super install];
    
	[NSObject borderHook];
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

#pragma mark -

- (void)whenDockerOpen {
	[NSObject borderEnable];
}

- (void)whenDockerClose {
	[NSObject borderDisable];
}

@end

