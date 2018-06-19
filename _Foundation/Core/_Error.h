
#import <Foundation/Foundation.h>

#pragma mark - 自定义的 Error，比NSError更易于定制

#pragma mark - Domain
extern NSString *const DTErrorDomain;

#pragma mark - Status Codes
static const NSUInteger DTInsertOutOfBoundsException = 0;
static const NSUInteger DTRemoveOutOfBoundsException = 1;
static const NSUInteger DTBadTypeException = 2;

@interface _Error : NSObject

+ (void)throwInsertOutOfBoundsException:(NSInteger)index array:(NSArray *)array;
+ (void)throwRemoveOutOfBoundsException:(NSInteger)index array:(NSArray *)array;
+ (void)throwBadTypeException:(id)obj expectedClass:(Class)classType;

@end
