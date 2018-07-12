
#import <_Foundation/_Foundation.h>

@interface PushMessage : NSObject

@property (nonatomic, strong) NSString *notification;

@property (nonatomic, assign) int32_t type;

@property (nonatomic, assign) int64_t recordId;

@end
