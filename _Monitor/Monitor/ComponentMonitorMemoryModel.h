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

@interface ComponentMonitorMemoryModel : NSObject

@prop_assign( int64_t,			usedBytes );
@prop_assign( int64_t,			totalBytes );
@prop_strong( NSMutableArray *,	history );

@singleton( ComponentMonitorMemoryModel )

- (void)update;

@end
