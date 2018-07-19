
#import <Foundation/Foundation.h>

/**
 * @brief 倒计时
 */
@interface _CountDown : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval leftTime; // Per Second

/**
 * @brief 初始化倒计时器
 */
- (instancetype)initWithInterval:(NSTimeInterval)timeLeft; // Per Second

/**
 * @brief 设置剩余时间，需要手动重启
 */
- (void)setLeftTime:(NSTimeInterval)leftTime;

/**
 * @brief 开始倒计时
 */
- (void)start:(void(^)(NSTimeInterval timeLeft))currentBlock;
- (void)start:(void(^)(NSTimeInterval timeLeft))currentBlock completion:(void(^)())completion;

/**
 * @brief 停止倒计时器
 */
- (void)stop;

@end
