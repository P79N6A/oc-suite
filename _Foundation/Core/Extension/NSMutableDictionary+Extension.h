
#import <Foundation/Foundation.h>
#import "NSDictionary+Extension.h"

//#pragma mark -
//
//@protocol NSMutableDictionaryProtocol <NSObject>
//@required
//- (void)setObject:(id)object forKey:(id)key;
//- (void)removeObjectForKey:(id)key;
//- (void)removeAllObjects;
//@optional
//- (void)setObject:(id)obj forKeyedSubscript:(id)key;
//@end

#pragma mark -

@interface NSMutableDictionary(Extension)// <NSDictionaryProtocol, NSMutableDictionaryProtocol>

+ (NSMutableDictionary *)nonRetainingDictionary;
+ (NSMutableDictionary *)keyValues:(id)first, ...;

- (BOOL)setObject:(NSObject *)obj atPath:(NSString *)path;
- (BOOL)setObject:(NSObject *)obj atPath:(NSString *)path separator:(NSString *)separator;
- (BOOL)setKeyValues:(id)first, ...;

- (id)objectForOneOfKeys:(NSArray *)array remove:(BOOL)flag;

//- (NSNumber *)numberForOneOfKeys:(NSArray *)array remove:(BOOL)flag;
//- (NSString *)stringForOneOfKeys:(NSArray *)array remove:(BOOL)flag;

@end
