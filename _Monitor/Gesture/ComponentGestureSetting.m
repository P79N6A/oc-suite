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

#import "ComponentGestureSetting.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentGestureSetting
{
	BOOL _enabled;
}

@def_singleton( ComponentGestureSetting )

@def_notification( Enabled )
@def_notification( Disabled )

- (BOOL)isEnabled
{
	return _enabled;
}

- (void)enable
{
	_enabled = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ComponentGestureSetting.Enabled object:nil];
}

- (void)disable
{
	_enabled = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ComponentGestureSetting.Disabled object:nil];
}

@end

