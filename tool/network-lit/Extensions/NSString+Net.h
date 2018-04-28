#import <Foundation/Foundation.h>

@interface NSString (Net)
+ (NSString *)netMD5StringFromData:(NSData *)data;
- (NSString *)netURLEncodedString;
- (NSString *)netURLDecodedString;
@end
