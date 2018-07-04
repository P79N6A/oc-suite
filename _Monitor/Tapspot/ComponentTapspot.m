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

#import "ComponentTapspot.h"
#import "ComponentTapspotHook.h"
#import "ComponentTapspotView.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentTapspot

- (void)install {
    [super install];
    
	[NSObject tapspotHook];
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

@end
