#import "_Protocol.h"

@protocol _ShareConfigProtocol <_Protocol>

@property (nonatomic, strong) NSString *key; // app key
@property (nonatomic, strong) NSString *secret; // app secret
@property (nonatomic, strong) NSString *scheme; // url scheme
@property (nonatomic, strong) NSString *redirect; // redirect url

@end
