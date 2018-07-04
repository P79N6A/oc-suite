
#import <Foundation/Foundation.h>

@interface _Localization : NSObject

@end

#pragma mark - 

/**
*  @desc localizable string
*/
#define localized(...) [NSString localizedStringWithArgs:__VA_ARGS__]

@interface NSString ( Localizable )

+ (NSString *)localizedStringWithArgs:(NSString *)fmt, ...;

@end
