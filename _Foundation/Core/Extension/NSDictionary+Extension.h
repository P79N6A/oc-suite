
#import "_Precompile.h"

/**
 *  便捷构造器
 
 *  @knowledge 追加形式的拼装，则使用枚举方式：1. 'k1, k2, k3, k4, ...' 2. @{ kvs1, kvs2, kvs3, ... }
 */
#define dict_ofkey1( k )                    [[NSMutableDictionary new]safeAppendObject:(k) forKey:(@#k)]
#define dict_ofkey2( k1, k2 )                   [dict_ofkey1( k1 ) safeAppendObject:(k2) forKey:(@#k2)]
#define dict_ofkey3( k1, k2, k3 )                   [dict_ofkey2( k1, k2 )  safeAppendObject:(k3) forKey:(@#k3)]
#define dict_ofkey4( k1, k2, k3, k4 )                   [dict_ofkey3( k1, k2, k3 ) safeAppendObject:(k4) forKey:(@#k4)]
#define dict_ofkey5( k1, k2, k3, k4, k5 )                   [dict_ofkey4( k1, k2, k3, k4 ) safeAppendObject:(k5) forKey:(@#k5)]
#define dict_ofkey6( k1, k2, k3, k4, k5, k6 )                   [dict_ofkey5( k1, k2, k3, k4, k5 ) safeAppendObject:(k6) forKey:(@#k6)]
#define dict_ofkey7( k1, k2, k3, k4, k5, k6, k7 )                   [dict_ofkey6( k1, k2, k3, k4, k5, k6 ) safeAppendObject:(k7) forKey:(@#k7)]
#define dict_ofkey8( k1, k2, k3, k4, k5, k6, k7, k8 )                   [dict_ofkey7( k1, k2, k3, k4, k5, k6, k7 ) safeAppendObject:(k8) forKey:(@#k8)]
#define dict_ofkeys( N, ... )               macro_concat(dict_ofkey, N)( __VA_ARGS__ )

/**
 *  便捷取值器
 */
#define dict_fornumber( _dict_, _key_selector_ )    [_dict_ numberAtPath:stringify(_key_selector_)]
#define dict_forbool( _dict_, _key_selector_ )      [_dict_ boolAtPath:stringify(_key_selector_)]
#define dict_forint32( _dict_, _key_selector_ )     [[_dict_ numberAtPath:stringify(_key_selector_)] intValue]
#define dict_forint64( _dict_, _key_selector_ )     [[_dict_ numberAtPath:stringify(_key_selector_)] longLongValue]
#define dict_fordouble( _dict_, _key_selector_ )    [[_dict_ numberAtPath:stringify(_key_selector_)] doubleValue]

#define dict_forstring( _dict_, _key_selector_ )    [_dict_ stringAtPath:stringify(_key_selector_)]

#define dict_forarray( _dict_, _key_selector_ )     [_dict_ arrayAtPath:stringify(_key_selector_)]

#define dict_fordictionary( _dict_, _key_selector_ )     [_dict_ dictAtPath:stringify(_key_selector_)]

#pragma mark -

@protocol NSDictionaryProtocol <NSObject>

@required
- (id)objectForKey:(id)key;
- (BOOL)hasObjectForKey:(id)key;

@optional
- (id)objectForKeyedSubscript:(id)key;
@end

#pragma mark -

@interface NSDictionary (Extension) <NSDictionaryProtocol>

- (id)objectForOneOfKeys:(NSArray *)array;

- (id)objectAtPath:(NSString *)path;

- (id)objectAtPath:(NSString *)path separator:(NSString *)separator;
- (id)objectAtPath:(NSString *)path otherwise:(NSObject *)other separator:(NSString *)separator;

- (BOOL)boolAtPath:(NSString *)path;
- (BOOL)boolAtPath:(NSString *)path otherwise:(BOOL)other;

- (NSNumber *)numberAtPath:(NSString *)path;
- (NSNumber *)numberAtPath:(NSString *)path otherwise:(NSNumber *)other;

- (NSString *)stringAtPath:(NSString *)path;
- (NSString *)stringAtPath:(NSString *)path otherwise:(NSString *)other;

- (NSArray *)arrayAtPath:(NSString *)path;
- (NSArray *)arrayAtPath:(NSString *)path otherwise:(NSArray *)other;

- (NSMutableArray *)mutableArrayAtPath:(NSString *)path;
- (NSMutableArray *)mutableArrayAtPath:(NSString *)path otherwise:(NSMutableArray *)other;

- (NSDictionary *)dictAtPath:(NSString *)path;
- (NSDictionary *)dictAtPath:(NSString *)path otherwise:(NSDictionary *)other;

- (NSMutableDictionary *)mutableDictAtPath:(NSString *)path;
- (NSMutableDictionary *)mutableDictAtPath:(NSString *)path otherwise:(NSMutableDictionary *)other;

@end

#pragma mark - 

/**
 *  Usage
 
 NSDictionary+Primitive
 
 NSDictionary+Primitive extends NSDictionary and NSMutableDictionary to provide support for primitives BOOL, char, int, float, CGPoint, CGSize, CGRect, NSInteger, NSUInteger, and CGFloat. The following example demonstrates int but all the other types work the same way.
 
 NSMutableDictionary* dict = [NSMutableDictionary dictionary];
 [dict setInt:1 forKey:@"int1"]; // dict = { int1:1 }
 [dict setInt:2 forKey:@"int2"]; // dict = { int1:1, int2:2 }
 int i = [dict intForKey:@"int1"]; // i = 1
 NSLog(@"%@", [dict description]); // console shows { int1 = 1; int2 = 2; }
 
 */

@interface NSDictionary ( Primitive ) // TODO: 用处不大，需要统一

- (BOOL)hasKey:(NSString *)key;

- (BOOL)boolForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (CGFloat)cgFloatForKey:(NSString *)key;
- (int)charForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (CGPoint)pointForKey:(NSString *)key;
- (CGSize)sizeForKey:(NSString *)key;
- (CGRect)rectForKey:(NSString *)key;

@end

@interface NSMutableDictionary ( Primitive )

- (void)setBool:(BOOL)i forKey:(NSString *)key;
- (void)setInt:(int)i forKey:(NSString *)key;
- (void)setInteger:(NSInteger)i forKey:(NSString *)key;
- (void)setUnsignedInteger:(NSUInteger)i forKey:(NSString *)key;
- (void)setCGFloat:(CGFloat)f forKey:(NSString *)key;
- (void)setChar:(char)c forKey:(NSString *)key;
- (void)setFloat:(float)i forKey:(NSString *)key;
- (void)setPoint:(CGPoint)o forKey:(NSString *)key;
- (void)setSize:(CGSize)o forKey:(NSString *)key;
- (void)setRect:(CGRect)o forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSDictionary, KeyType, ObjectType) ( Function )

/** Loops through the dictionary and executes the given block using each item.
 */
- (void)each:(void (^)(KeyType key, ObjectType obj))block;

/** Enumerates through the dictionary concurrently and executes
 the given block once for each pair.
 */
- (void)apply:(void (^)(KeyType key, ObjectType obj))block;

/** Loops through a dictionary to find the first key/value pair matching the block.
 */
- (nullable id)match:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a dictionary to find the key/value pairs matching the block.
 */
- (NSDictionary *)select:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a dictionary to find the key/value pairs not matching the block.
 */
- (NSDictionary *)reject:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Call the block once for each object and create a dictionary with the same keys
 and a new set of values.
 */
- (NSDictionary *)map:(id (^)(KeyType key, ObjectType obj))block;

/** Loops through a dictionary to find whether any key/value pair matches the block.
 */
- (BOOL)any:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a dictionary to find whether no key/value pairs match the block.
 */
- (BOOL)none:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a dictionary to find whether all key/value pairs match the block.
 */
- (BOOL)all:(BOOL (^)(KeyType key, ObjectType obj))block;

@end

NS_ASSUME_NONNULL_END

