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

// ----------------------------------
// Category code
// ----------------------------------

/**
 ZLib error domain
 */
extern NSString *const JKZlibErrorDomain;
/**
 When a zlib error occurs, querying this key in the @p userInfo dictionary of the
 @p NSError object will return the underlying zlib error code.
 */
extern NSString *const JKZlibErrorInfoKey;

typedef NS_ENUM(NSUInteger, JKZlibErrorCode) {
    JKZlibErrorCodeFileTooLarge = 0,
    JKZlibErrorCodeDeflationError = 1,
    JKZlibErrorCodeInflationError = 2,
    JKZlibErrorCodeCouldNotCreateFileError = 3,
};

@interface NSData ( Zlib )

/**
 Apply zlib compression.
 
 @param error If an error occurs during compression, upon return contains an
 NSError object describing the problem.
 
 @returns An NSData instance containing the result of applying zlib
 compression to this instance.
 */
- (NSData *)dataByDeflatingWithError:(NSError *__autoreleasing *)error;

/**
 Apply zlib decompression.
 
 @param error If an error occurs during decompression, upon return contains an
 NSError object describing the problem.
 
 @returns An NSData instance containing the result of applying zlib
 decompression to this instance.
 */
- (NSData *)dataByInflatingWithError:(NSError *__autoreleasing *)error;

/**
 Apply zlib compression and write the result to a file at path
 
 @param path The path at which the file should be written
 
 @param error If an error occurs during compression, upon return contains an
 NSError object describing the problem.
 
 @returns @p YES if the compression succeeded; otherwise, @p NO.
 */
- (BOOL)writeDeflatedToFile:(NSString *)path error:(NSError *__autoreleasing *)error;

/**
 Apply zlib decompression and write the result to a file at path
 
 @param path The path at which the file should be written
 
 @param error If an error occurs during decompression, upon return contains an
 NSError object describing the problem.
 
 @returns @p YES if the compression succeeded; otherwise, @p NO.
 */
- (BOOL)writeInflatedToFile:(NSString *)path error:(NSError *__autoreleasing *)error;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _zlib : NSObject

@end
