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
#import "_foundation.h"

#import "_json_serializer.h"

// ----------------------------------
// Category code
// ----------------------------------

#pragma mark -

@interface NSObject ( Encoding )

/**
 *  對象編碼
 *
 *  @param type 目標編碼類型
 *
 *  @return 編碼後的對象
 */

- (NSObject *)converToType:(EncodingType)type;

@end

@interface NSObject ( Serializer )

+ (id)unserialize:(id)obj;
+ (id)unserialize:(id)obj withClass:(Class)clazz;

- (id)JSONEncoded;
- (id)JSONDecoded;

- (BOOL)toBool;
- (float)toFloat;
- (double)toDouble;
- (NSInteger)toInteger;
- (NSUInteger)toUnsignedInteger;

- (NSURL *)toURL;
- (NSDate *)toDate;
- (NSData *)toData;
- (NSNumber *)toNumber;
- (NSString *)toString;

- (id)serialize;				// override point
- (void)unserialize:(id)obj;	// override point
- (void)zerolize;				// override point

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _serializer : NSObject

@end
