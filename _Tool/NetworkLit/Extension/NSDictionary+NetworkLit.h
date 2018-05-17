
#import <Foundation/Foundation.h>

@interface NSDictionary (NetworkLit)
- (NSString *)urlEncodedKeyValueString;
- (NSString *)jsonEncodedKeyValueString;
- (NSString *)plistEncodedKeyValueString;
@end
