
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation ( Extension )

+ (id)doInstanceMethodTarget:(id)target
                selectorName:(NSString *)selectorName
                        args:(NSArray *)args;

+ (id)doClassMethod:(NSString *)className
       selectorName:(NSString *)selectorName
               args:(NSArray *)args;

- (void)setArgumentWithObject:(id)object atIndex:(NSUInteger)index;

+ (instancetype)invocationWithTarget:(id)target block:(void (^)(id target))block;
+ (instancetype)invocationWithBlock:(id) block;
+ (instancetype)invocationWithBlockAndArguments:(id) block ,...;

@end

NS_ASSUME_NONNULL_END
