#import <Foundation/Foundation.h>

@protocol _NetworkServerProtocol <NSObject>

@property (nonatomic, copy) NSString *prot; //必填。协议，如http, https
@property (nonatomic, copy) NSString *host; //必填。域名
@property (nonatomic, copy) NSNumber *port; //端口

@end
