
#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: Macros

// @brief __type 不能为指针类型
// ----------------------------------

#pragma mark -

#undef  prop_instance
#define prop_instance( __type, __name ) \
        property (nonatomic, strong) __type * __name;

#undef  def_prop_instance
#define def_prop_instance( __type, __name ) \
        synthesize __name; \
        - (__type *)__name { \
            if (!__name) { \
                __name = [__type instance]; \
            } \
            return __name; \
        }

// ----------------------------------
// MARK: Class code
// ----------------------------------

#pragma mark - 

@interface NSObject ( Instance )

+ (instancetype)instance;


/**
 *  浅复制目标的所有属性
 *
 *  @param instance 目标对象
 *
 *  @return YES:复制成功, NO:复制失败
 */
- (BOOL)easyShallowCopy:(NSObject *)instance;

/**
 *  深复制目标的所有属性
 *
 *  @param instance 目标对象
 *
 *  @return YES:复制成功, NO:复制失败
 */
- (BOOL)easyDeepCopy:(NSObject *)instance;

@end
