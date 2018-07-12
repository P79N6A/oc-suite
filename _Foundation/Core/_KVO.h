
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark - 系统 KVO 语法糖

/**
 *  inspired by https://github.com/AlexIzh/objc_ext/blob/master/objc_kvo_ext/objc_kvo_ext.h
 
 *  Usage
 
 *  in viewDidLoad
 
    add_observer(progress) {
        [model addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    }
 
 *  in dealloc
 
    remove_observer(progress) {
        [model removeObserver:self forKeyPath:@"progress"];
    }
 */

#define add_observer_o(__OBJ__,__X__) \
        NSMutableDictionary * __observer_values_##__X__ = objc_getAssociatedObject(__OBJ__, "__tmp__observers_dictionary__"); \
        if (!__observer_values_##__X__) { \
            __observer_values_##__X__ = [NSMutableDictionary dictionary]; \
            objc_setAssociatedObject(__OBJ__, "__tmp__observers_dictionary__", __observer_values_##__X__, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
        } \
        BOOL __tmp_value_##__X__ = [[__observer_values_##__X__ valueForKey:[NSString stringWithFormat:@"%s", #__X__]] boolValue];\
        if (!__tmp_value_##__X__) {\
            [__observer_values_##__X__ setValue:@(YES) forKey:[NSString stringWithFormat:@"%s", #__X__]]; \
        } \
        if (!__tmp_value_##__X__)

#define remove_observer_o(__OBJ__, __X__) \
        NSMutableDictionary * __observer_values_##__X__ = objc_getAssociatedObject(__OBJ__, "__tmp__observers_dictionary__"); \
        if (!__observer_values_##__X__) { \
                __observer_values_##__X__ = [NSMutableDictionary dictionary]; \
            objc_setAssociatedObject(__OBJ__, "__tmp__observers_dictionary__", __observer_values_##__X__, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
        } \
        BOOL __tmp_value_##__X__ = [[__observer_values_##__X__ valueForKey:[NSString stringWithFormat:@"%s", #__X__]] boolValue];\
        if (__tmp_value_##__X__) {\
            [__observer_values_##__X__ setValue:@(NO) forKey:[NSString stringWithFormat:@"%s", #__X__]]; \
        } \
        if (__tmp_value_##__X__)

#define add_observer(__X__) add_observer_o(self,__X__)
#define remove_observer(__X__) remove_observer_o(self, __X__)

#pragma mark - KVO 封装

@interface NSObject ( KVO )

/**
 *  通过Block方式注册一个KVO，通过该方式注册的KVO无需手动移除，其会在被监听对象销毁的时候自动移除,所以下面的两个移除方法一般无需使用
 *
 *  @param keyPath 监听路径
 *  @param block   KVO回调block，obj为监听对象，oldVal为旧值，newVal为新值
 */
- (void)observeForKeyPath:(NSString *)keyPath block:(void (^)(id obj, id oldVal, id newVal))block;

/**
 *  提前移除指定KeyPath下的BlockKVO(一般无需使用，如果需要提前注销KVO才需要)
 *
 *  @param keyPath 移除路径
 */
- (void)unobserveForKeyPath:(NSString *)keyPath;

/**
 *  提前移除所有的KVOBlock(一般无需使用)
 */
- (void)unobserveForAllKeyPath;

#pragma mark - Notification

/**
 *  通过block方式注册通知，通过该方式注册的通知无需手动移除，同样会自动移除
 *
 *  @param name  通知名
 *  @param block 通知的回调Block，notification为回调的通知对象
 */
- (void)observeNotification:(NSString *)name block:(void (^)(NSNotification *notification))block;

@end



