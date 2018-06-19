#import "NSObject+DBCallback.h"

@implementation NSObject (DBCallback)

+ (BOOL)shouldInsert:(NSObject *)model {
    return YES;
}

+ (void)modelWillInsert:(NSObject *)model {
    
}

+ (void)modelDidInsert:(NSObject *)model result:(BOOL)result {
    
}

+ (BOOL)shouldDelete:(NSObject *)model {
    return YES;
}

+ (void)modelWillDelete:(NSObject *)model {
    
}

+ (void)modelDidDelete:(NSObject *)model result:(BOOL)result {
    
}

+ (BOOL)shouldUpdate:(NSObject *)model {
    return YES;
}

+ (void)modelWillUpdate:(NSObject *)model {
    
}

+ (void)modelDidUpdate:(NSObject *)model result:(BOOL)result {
    
}

@end
