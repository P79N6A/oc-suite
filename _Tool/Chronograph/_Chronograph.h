
#import <Foundation/Foundation.h>

typedef void (^ _ChronographTimeBlock)(NSString *timeString);

@interface _Chronograph : NSObject

/**
 * @brief 启动秒表，包括暂停和继续
 */
- (void)start:(_ChronographTimeBlock) timeBlock;

/**
 * @brief 重置秒表，归0
 */
- (void)reset;

@end
