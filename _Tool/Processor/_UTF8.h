#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

#pragma mark -

@interface NSString ( UTF8 )

- (NSData *)utf8EncodedData;

- (NSString *)unicodeString;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _UTF8 : NSObject

@end
