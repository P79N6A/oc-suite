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

@interface _Localization : NSObject

@end

#pragma mark - 

/**
*  @desc localizable string
*/
#define localized(...) [NSString localizedStringWithArgs:__VA_ARGS__]

@interface NSString (Localizable)

+ (NSString *)localizedStringWithArgs:(NSString *)fmt, ...;

@end
