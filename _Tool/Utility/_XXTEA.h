#import <Foundation/Foundation.h>

@interface NSString (XXTEA)

- (NSString *)encryptXXTEA:(NSString *)key;
- (NSString *)decryptXXTEA:(NSString *)key;

@end
