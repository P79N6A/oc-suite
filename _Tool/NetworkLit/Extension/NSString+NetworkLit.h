#import <Foundation/Foundation.h>

@interface NSString (NetworkLit)
+ (NSString *)netMD5StringFromData:(NSData *)data;
- (NSString *)netURLEncodedString;
- (NSString *)netURLDecodedString;
@end
