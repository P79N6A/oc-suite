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

@interface ComponentMonitorNetworkModel : NSObject

@prop_assign( NSUInteger,		uploadBytes );
@prop_strong( NSMutableArray *,	uploadHistory );

@prop_assign( NSUInteger,		downloadBytes );
@prop_strong( NSMutableArray *,	downloadHistory );

@singleton( ComponentMonitorNetworkModel )

- (void)update;

@end
