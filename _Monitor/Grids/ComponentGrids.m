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

#import "ComponentGrids.h"
#import "ComponentGridsWindow.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentGrids

- (void)install {
    [super install];
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
	[[ComponentGridsWindow sharedInstance] show];
}

- (void)whenDockerClose {
	[[ComponentGridsWindow sharedInstance] hide];
}

@end
