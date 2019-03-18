
#import "_StringBuilder.h"
#import "NSMutableString+Extension.h"
#import "NSString+Extension.h"

@interface _StringBuilder ()

@property (nonatomic, strong) NSMutableString *stringHolder;

@end

@implementation _StringBuilder

- (instancetype)init {
    if (self = [super init]) {
        self.stringHolder = [NSMutableString new];
    }
    
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        self.stringHolder = [[NSMutableString alloc] initWithString:string];
    }
    
    return self;
}

- (void)repeat:(NSString *)part count:(NSUInteger)count {
    if (count > 0) {
        [self.stringHolder appendString:[part repeat:count]];
    }
}

- (void)add:(NSString *)s {
    [self.stringHolder appendString:s];
}

- (void)add:(NSArray *)objs withSeparator:(NSString *)separator {
    if (![objs count]) return;
    
    for (NSInteger i = 0; i < [objs count]; i++) {
        NSObject *obj = [objs objectAtIndex:i];
        NSString *s = [NSString stringWithFormat:@"%@", obj];
        [self.stringHolder appendString:s];
        
        if (separator && i < ([objs count]-1)) {
            [self.stringHolder appendString:separator];
        }
    }
}

- (NSString *)build {
    return self.stringHolder;
}

- (void)clear {
    self.stringHolder = [NSMutableString new];
}

#pragma mark -

- (BOOL)empty {
    return [self.stringHolder length] <= 0;
}

@end
