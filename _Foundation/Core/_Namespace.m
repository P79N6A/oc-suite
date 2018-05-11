
#import "_namespace.h"

// ----------------------------------
// MARK: Extern
// ----------------------------------

__strong _Namespace * greats = nil;

// ----------------------------------
// MARK: Source - _Namespace
// ----------------------------------

@implementation _Namespace

+ (void)load {
    greats = [[_Namespace alloc] init];
}

@end
