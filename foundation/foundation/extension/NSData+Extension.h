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

@interface NSData ( Extension )

@property (nonatomic, readonly) NSString *	string;
@property (nonatomic, readonly) NSString *	hexadecimalString;
@property (nonatomic, readonly) NSString *	utf8String;

- (void)writeToBinaryFile:(NSString *)path atomically:(BOOL)atomically;

@end

#pragma mark - FileFormat

@interface NSData ( FileFormat )

- (BOOL)isJPEG;
- (BOOL)isPNG;
- (BOOL)isImage;
- (BOOL)isMPEG4;
- (BOOL)isMedia;
- (BOOL)isCompressed;
- (NSString *)appropriateFileExtension;

@end

