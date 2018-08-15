
#import "_Foundation.h"
#import "_NetworkServerProtocol.h"

@class InterfaceManagerConfiguration;

@interface _ApiManager : NSObject

@property (nonatomic, copy) NSString *interfaceListAddress;

@property (nonatomic, strong, readonly) NSDictionary *interfaceData;

@property (nonatomic, strong, readonly) NSDictionary *URLMapWithAlias;

@property (nonatomic, strong) id<_NetworkServerProtocol> configuration; //配置项，默认nil，如果非nil，则读取其中所有配置

@singleton(_ApiManager)

- (void)updateInterface;

- (NSString *)getURLStringWithAliasName:(NSString *)aliasName;

- (NSString *)getURLSendDataMethodWithAliasName:(NSString *)aliasName;

@end
