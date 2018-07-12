
#import <Foundation/Foundation.h>

typedef void(^ ObservingBlock)(id obj, NSString *key, id oldValue, id newValue);

@interface NSObject ( KVOImpl )

- (void)observe:(NSObject *)observe
            for:(NSString *)key
           with:(ObservingBlock)block;

- (void)unobserve:(NSObject *)observe
              for:(NSString *)key;

@end
