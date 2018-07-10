#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

@interface NSObject ( JSON )

@property (nonatomic, readonly) BOOL isJsonObject;

@property (nonatomic, readonly, nonnull) NSString *jsonString;

@end

//@interface NSData ( Json )
//
//@property (nonatomic, readonly, nonnull) NSString *jsonString;
//
//@end

@interface NSString ( JSON )

@property (nonatomic, readonly, nullable) id jsonObject;

@end

@interface NSDictionary ( JSON )

/**
 *  @brief NSDictionary转换成JSON字符串
 *
 *  @return  JSON字符串
 */
- (NSString *)JSONString;

@end


// ----------------------------------
// Class code
// ----------------------------------

@interface _Json : NSObject

+ (nullable NSString *)jsonStringFromJsonObject:(nonnull id)jsonObject;

+ (nullable NSDictionary *)jsonObjectFromString:(nonnull NSString *)jsonString;

@end
