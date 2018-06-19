//
//  _xml.h
//  kata
//
//  Created by fallen.ink on 18/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

@interface NSString ( XML )
/**
 *  @brief  xml字符串转换成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)XMLDictionary;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _Xml : NSObject

+ (NSDictionary *)dictionaryFromString:(NSString *)string;

@end
