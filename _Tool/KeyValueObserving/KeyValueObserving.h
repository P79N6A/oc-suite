
#import <Foundation/Foundation.h>

typedef void(^ ObservingBlock)(id obj, NSString *key, id oldVal, id newVal);

@interface NSObject ( KVOImpl )

- (void)observe:(NSObject *)observe
            for:(NSString *)key
           with:(ObservingBlock)block;

- (void)unobserve:(NSObject *)observe
              for:(NSString *)key;

@end
