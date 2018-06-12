//
//  _utf8.h
//  student
//
//  Created by fallen.ink on 01/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//
//  utf8 & unicode

#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

#pragma mark -

@interface NSString ( utf8 )

- (NSData *)utf8EncodedData;

- (NSString *)unicodeString;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _utf8 : NSObject

@end
