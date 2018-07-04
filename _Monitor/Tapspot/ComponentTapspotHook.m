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

#import "ComponentTapspotHook.h"
#import "ComponentTapspotView.h"
#import "ComponentTapspotManager.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject(Wireframe)

static void (*__sendEvent)( id, SEL, UIEvent * ) = NULL;

+ (void)tapspotHook {
	__sendEvent = [UIWindow replaceSelector:@selector(sendEvent:) withSelector:@selector(__sendEvent:)];
}

- (void)__sendEvent:(UIEvent *)event {
	[[ComponentTapspotManager sharedInstance] handleUIEvent:event];

	if ( __sendEvent ) {
		__sendEvent( self, _cmd, event );
	}
}

@end

