#import <Foundation/Foundation.h>
#import "zlib.h"

// ----------------------------------
// Category code
// ----------------------------------

@interface NSData ( Gzip )
/**
 *  @brief  GZIP压缩
 *
 *  @param level 压缩级别
 *
 *  @return 压缩后的数据
 */
- (NSData *)gzippedDataWithCompressionLevel:(float)level;

/**
 *  @brief  GZIP压缩 压缩级别 默认-1
 *
 *  @return 压缩后的数据
 */
- (NSData *)gzippedData;

/**
 *  @brief  GZIP解压
 *
 *  @return 解压后数据
 */
- (NSData *)gunzippedData;

- (BOOL)isGzippedData;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _Gzip : NSObject

+ (NSData *)gzipData:(NSData *)pUncompressedData;
+ (NSData *)uncompressZippedData:(NSData *)compressedData;

@end
