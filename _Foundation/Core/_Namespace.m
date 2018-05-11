
#import "_Namespace.h"

// ----------------------------------
// MARK: Extern
// ----------------------------------

__strong _Namespace * namespace_root = nil;

// ----------------------------------
// MARK: Source - _Namespace
// ----------------------------------

@implementation _Namespace

+ (void)load {
    namespace_root = [[_Namespace alloc] init];
}

@end
