
#import <Foundation/Foundation.h>

#pragma mark -

// class

#undef  class_equal
#define class_equal( _inst_, _target_class_type_) [_inst_ isKindOfClass:[_target_class_type_ class]]

#undef  classnameof_instance
#define classnameof_instance( _inst_ ) NSStringFromClass([_inst_ class])

#undef  classnameof_Class
#define classnameof_Class( _Class_ )    NSStringFromClass( _Class_ )

/**
 *  @brief 从 代码串 转换为 Class
 *
 *  - returns: Class
 */
#undef  classof // classofname
#define classof( x )		NSClassFromString(@ #x)

/**
 *  @brief 从 字符串 转换为 Class
 *
 *  - returns: Class
 */
#undef  classify
#define classify( _classname_of_str_ ) NSClassFromString( _classname_of_str_ )

/**
 *  @brief 从 代码串 生成 实例
 *
 *  - returns: 实例
 */
#undef  instanceof
#define instanceof( x )	[[NSClassFromString(@ #x) alloc] init]

#pragma mark -

#undef  base_class
#define base_class( __class ) \
        + (Class)baseClass \
        { \
            return NSClassFromString( @(#__class) ); \
        }

#undef	convert_class
#define	convert_class( __name, __class ) \
        + (Class)convertClass_##__name \
        { \
            return NSClassFromString( @(#__class) ); \
        }

#pragma mark -

void dumpClass(Class cls);

#pragma mark -

@interface NSObject ( Runtime )

/**
 *  @brief Get all classes those are loaded
 *
 *  @return should be free after use.
 */
+ (__unsafe_unretained Class *)loadedClasses;
+ (void)enumerateloadedClassesUsingBlock:(void (^)(__unsafe_unretained Class cls))block;

+ (NSArray *)subClasses;

+ (NSArray *)methods;
+ (NSArray *)methodsInfo;
+ (NSArray *)methodsUntilClass:(Class)baseClass;
+ (NSArray *)methodsWithPrefix:(NSString *)prefix;
+ (NSArray *)methodsWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

+ (NSArray *)properties;
+ (NSArray *)propertiesUntilClass:(Class)baseClass;
+ (NSArray *)propertiesWithPrefix:(NSString *)prefix;
+ (NSArray *)propertiesWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

- (NSDictionary *)propertyDictionary; //实例属性字典
- (NSArray *)propertyKeys; //属性名称列表
+ (NSArray *)propertyKeys;
- (NSArray *)propertiesInfo; //属性详细信息列表
+ (NSArray *)propertiesInfo;
+ (NSArray *)propertiesWithCodeFormat; //格式化后的属性列表
+ (NSArray *)instanceVariable; // 实例变量
- (BOOL)hasPropertyForKey:(NSString *)key;

/**
 *  @brief Check whether the receiver implements or inherits a specified method up to and exluding a particular class in hierarchy.
 *
 *  @param selector A selector that identifies a method.
 *  @param stopClass A final super class to stop quering (excluding it).
 *  @return YES if one of super classes in hierarchy responds a specified selector.
 */
- (BOOL)respondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 *  @brief Check whether a superclass implements or inherits a specified method.
 *
 *  @param selector A selector that identifies a method.
 *  @return YES if one of super classes in hierarchy responds a specified selector.
 */
- (BOOL)superRespondsToSelector:(SEL)selector;

/**
 *  @brief Check whether a superclass implements or inherits a specified method.
 *
 *  @param selector A selector that identifies a method.
 *  @param stopClass A final super class to stop quering (excluding it).
 *  @return YES if one of super classes in hierarchy responds a specified selector.
 */
- (BOOL)superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 *  @brief Check whether the receiver's instances implement or inherit a specified method up to and exluding a particular class in hierarchy.
 *
 *  @param selector A selector that identifies a method.
 *  @param stopClass A final super class to stop quering (excluding it).
 *  @return YES if one of super classes in hierarchy responds a specified selector.
 *
 */
+ (BOOL)instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 *  @brief perform a selector take care of selector not existing.
 */
+ (id)touchSelector:(SEL)selector;
- (id)touchSelector:(SEL)selector;

// inspired by CBExtension

/**
 *  @brief 该对象所遵循的协议
 */
- (NSArray *)conformedProtocols;
- (NSDictionary *)protocols;
+ (NSDictionary *)protocols;
+ (NSArray *)classesWithProtocolName:(NSString *)protocolName;

/**
 *  @brief 返回对象的所有 ivar
 */
- (NSArray *)allIvars;
- (BOOL)hasIvarForKey:(NSString *)key;

/**
 *  @brief 以 NSString 描述的类名
 */
- (NSString *)className;
+ (NSString *)className;

- (NSString *)superClassName;
+ (NSString *)superClassName;

/**
 *  @brief 所有父类
 */
- (NSArray *)parents;

+ (BOOL)isNSObjectClass:(Class)clazz;

@end
