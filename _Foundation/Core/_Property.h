
#import "_precompile.h"

// ----------------------------------
// MARK: Macros
// ----------------------------------

#pragma mark -

#undef  static_property
#define static_property( _name_ ) \
        property (nonatomic, readonly) NSString * _name_; \
        - (NSString *)_name_; \
        + (NSString *)_name_;

#undef  def_static_property
#define def_static_property( _name_, ... ) \
        macro_concat(def_static_property, macro_count(__VA_ARGS__))(_name_, __VA_ARGS__)

#undef  def_static_property0
#define def_static_property0( _name_ ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; }

#undef  def_static_property1
#define def_static_property1( _name_, A ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%s", A, #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%s", A, #_name_]; }

#undef  def_static_property2
#define def_static_property2( _name_, A, B ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%s", A, B, #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%s", A, B, #_name_]; }

#undef  def_static_property3
#define def_static_property3( _name_, A, B, C ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%@.%s", A, B, C, #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%@.%s", A, B, C, #_name_]; }

#undef  alias_static_property
#define alias_static_property( _name_, _alias_ ) \
        dynamic _name_; \
        - (NSString *)_name_ { return _alias_; } \
        + (NSString *)_name_ { return _alias_; }

#pragma mark -

#undef  integer
#define integer( _name_ ) \
        property (nonatomic, readonly) NSInteger _name_; \
        - (NSInteger)_name_; \
        + (NSInteger)_name_;

#undef  def_integer
#define def_integer( _name_, _value_ ) \
        dynamic _name_; \
        - (NSInteger)_name_ { return _value_; } \
        + (NSInteger)_name_ { return _value_; }

#pragma mark -

#undef  unsigned_integer
#define unsigned_integer( _name_ ) \
        property (nonatomic, readonly) NSUInteger _name_; \
        - (NSUInteger)_name_; \
        + (NSUInteger)_name_;

#undef  def_unsigned_integer
#define def_unsigned_integer( _name_, _value_ ) \
        dynamic _name_; \
        - (NSUInteger)_name_ { return _value_; } \
        + (NSUInteger)_name_ { return _value_; }

#pragma mark -

#undef  nsnumber
#define nsnumber( _name_ ) \
        property (nonatomic, readonly) NSNumber * _name_; \
        - (NSNumber *)_name_; \
        + (NSNumber *)_name_;

#undef  def_nsnumber
#define def_nsnumber( _name_, _value_ ) \
        dynamic _name_; \
        - (NSNumber *)_name_ { return @(_value_); } \
        + (NSNumber *)_name_ { return @(_value_); }

#pragma mark -

/**
 *  由于string()被系统库占用，所有加ns前缀
 */
#undef  nsstring
#define nsstring( _name_ ) \
        property (nonatomic, readonly) NSString * _name_; \
        - (NSString *)_name_; \
        + (NSString *)_name_;

#undef  def_nsstring
#define def_nsstring( _name_, _value_ ) \
        dynamic _name_; \
        - (NSString *)_name_ { return _value_; } \
        + (NSString *)_name_ { return _value_; }

/**
 *  默认用_name_，作为字符串的内容
 */
#undef  def_string
#define def_string( _name_ ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; }

#pragma mark -

#define prop_readonly( type, name )         property (nonatomic, readonly) type name;
#define prop_dynamic( type, name )          property (nonatomic, strong) type name;
#define prop_assign( type, name )           property (nonatomic, assign) type name;
#define prop_strong( type, name )           property (nonatomic, strong) type name;
#define prop_weak( type, name )             property (nonatomic, weak) type name;
#define prop_copy( type, name )             property (nonatomic, copy) type name;
#define prop_unsafe( type, name )           property (nonatomic, unsafe_unretained) type name;
#define prop_retype( type, name )           property type name;
#define prop_class( type, name )            property (nonatomic, class) type name;

#pragma mark -

#define def_prop_readonly( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_assign( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_strong( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_weak( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_unsafe( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_copy( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_dynamic( type, name, ... ) \
        dynamic name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_dynamic_copy( type, name, setName, ... ) \
        def_prop_custom( type, name, setName, copy ) \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_dynamic_strong( type, name, setName, ... ) \
        def_prop_custom( type, name, setName, retain ) \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_dynamic_unsafe( type, name, setName, ... ) \
        def_prop_custom( type, name, setName, assign ) \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_dynamic_weak( type, name, setName, ... ) \
        def_prop_custom( type, name, setName, assign ) \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define def_prop_dynamic_pod( type, name, setName, pod_type ... ) \
        dynamic name; \
        - (type)name { return (type)[[self getAssociatedObjectForKey:#name] pod_type##Value]; } \
        - (void)setName:(type)obj { [self assignAssociatedObject:@((pod_type)obj) forKey:#name]; } \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

// Use this add property to category!

#define def_prop_custom( type, name, setName, attr ) \
        dynamic name; \
        - (type)name { return [self getAssociatedObjectForKey:#name]; } \
        - (void)setName:(type)obj { [self attr##AssociatedObject:obj forKey:#name]; }

#define def_prop_cate_assign( type, name, setName ) \
        def_prop_custom( type, name, setName, assign )

#define def_prop_cate_strong( type, name, setName ) \
        def_prop_custom( type, name, setName, retain )

#define def_prop_custom_block( type, name, setName, attr, getter_code_block, setter_code_block) \
        dynamic name; \
        - (type)name { if (getter_code_block) getter_code_block(); return [self getAssociatedObjectForKey:#name]; } \
        - (void)setName:(type)obj { if (setter_code_block) setter_code_block();[self attr##AssociatedObject:obj forKey:#name]; }

#define def_prop_class( type, name, setName ) \
        dynamic name; \
        static type __##name; \
        + (type)name { return __##name; } \
        + (void)setName:(type)name { __##name = name; }

// ----------------------------------
// MARK: Class code
// ----------------------------------

#pragma mark -

@interface NSObject ( Property )

#pragma mark - Property bind

+ (const char *)attributesForProperty:(NSString *)property;
- (const char *)attributesForProperty:(NSString *)property;

+ (NSDictionary *)extentionForProperty:(NSString *)property;
- (NSDictionary *)extentionForProperty:(NSString *)property;

+ (NSString *)extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key;
- (NSString *)extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key;

+ (NSArray *)extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key;
- (NSArray *)extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key;

- (BOOL)hasAssociatedObjectForKey:(const char *)key;
- (id)getAssociatedObjectForKey:(const char *)key;
- (id)copyAssociatedObject:(id)obj forKey:(const char *)key;
- (id)retainAssociatedObject:(id)obj forKey:(const char *)key;
- (id)assignAssociatedObject:(id)obj forKey:(const char *)key;
- (void)weaklyAssociateObject:(id)obj forKey:(const char *)key;
- (void)removeAssociatedObjectForKey:(const char *)key;
- (void)removeAllAssociatedObjects;

#pragma mark - Object 2 Json\Dictionary

- (NSDictionary *)toDictionary; // 打印属性名－属性值的，键值对

- (NSData *)toJsonDataWithOptions:(NSJSONWritingOptions)options;

@end

