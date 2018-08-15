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

#import <Foundation/Foundation.h>

#pragma mark -

@interface NSURL ( Extension )

+ (NSURL *)URLWithStringOrNil:(NSString *)URLString;

/*
 * Returns a string of the base of the URL, will contain a trailing slash
 *
 * Example:
 * NSURL is http://www.cnn.com/full/path?query=string&key=value
 * baseString will return: http://www.cnn.com/
 */
- (NSString *)baseString;

@end

#pragma mark -

@interface NSURL ( Comparison )

- (BOOL) isEqualToURL:(NSURL *)otherURL;

@end
