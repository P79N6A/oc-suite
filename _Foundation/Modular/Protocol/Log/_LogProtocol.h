#import <Foundation/Foundation.h>
#import "_LogConfigureProtocol.h"

@protocol _LogProtocol <NSObject>

@property (nonatomic, strong) id<_LogConfigureProtocol> configure;

@end
