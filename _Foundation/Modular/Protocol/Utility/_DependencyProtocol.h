#import <Foundation/Foundation.h>

@protocol _DependencyProtocol <NSObject>

// QQ: http://wiki.connect.qq.com/%E9%80%9A%E7%9F%A5
@property (nonatomic, readonly) BOOL isQQInstalled;
@property (nonatomic, readonly) BOOL isTIMInstalled;

@end
