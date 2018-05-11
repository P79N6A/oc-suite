
#import "NSMutableString+Extension.h"

@implementation NSMutableString (Extension)

- (NSMutableString *)append:(NSString *)string {
    [self appendString:string];
    
    return self;
}

@end
