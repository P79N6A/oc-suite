//
//  _json.h
//  kata
//
//  Created by fallen on 17/3/6.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

@interface NSObject ( Json )

@property (nonatomic, readonly) BOOL isJsonObject;

@property (nonatomic, readonly, nonnull) NSString *jsonString;

@end

//@interface NSData ( Json )
//
//@property (nonatomic, readonly, nonnull) NSString *jsonString;
//
//@end

@interface NSString ( Json )

@property (nonatomic, readonly, nullable) id jsonObject;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _Json : NSObject

+ (nullable NSString *)jsonStringFromJsonObject:(nonnull id)jsonObject;

+ (nullable NSDictionary *)jsonObjectFromString:(nonnull NSString *)jsonString;

@end
