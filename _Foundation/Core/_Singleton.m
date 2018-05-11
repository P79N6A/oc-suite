
#import "_Singleton.h"

#pragma mark -

@implementation _Singleton

+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

@end
