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

#import "_preheaders_debug.h"

#pragma mark -

@interface ComponentMonitorFPSModel : NSObject

@prop_assign( NSUInteger,		fps );
@prop_assign( NSUInteger,		maxFPS );
@prop_strong( NSMutableArray *,	history );

@singleton( ComponentMonitorFPSModel )

- (void)update;

@end
