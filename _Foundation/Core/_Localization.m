
#import "_Localization.h"

@implementation _Localization

@end

#pragma mark - 

@implementation NSString (Localizable)

+ (NSString *)localizedStringWithArgs:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSString *localizedString = [[NSString alloc] initWithFormat:NSLocalizedString(fmt, nil) arguments:args];
    va_end(args);
    
    return localizedString;
}

@end
