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

#import "_greats.h"
//#import "Samurai_Core.h"
//#import "Samurai_Event.h"

#pragma mark -

@interface _Watcher : NSObject

@prop_strong( NSMutableArray *,		sourceFiles );
@prop_strong( NSString *,			sourcePath );

@notification( SourceFileDidChanged )
@notification( SourceFileDidRemoved )

@singleton( _Watcher )

- (void)watch:(NSString *)path;

@end
