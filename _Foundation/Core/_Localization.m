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

#import "_localization.h"

@implementation _Localization

@end

#pragma mark - 

@implementation NSString (Localizable)

+ (NSString *)localizedStringWithArgs:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSString *localizedString = [[NSString alloc] initWithFormat:NSLocalizedString(fmt, nil) arguments:args];
    va_end(args);
    
    return localizedString;
}

@end
