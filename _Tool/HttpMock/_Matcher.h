#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, _MatcherType) {
    _MatcherTypeString,
    _MatcherTypeData,
    _MatcherTypeRegex
};

@interface _Matcher : NSObject

@property (nonatomic, assign) _MatcherType matchType;
@property (nonatomic, copy, readonly) NSString *string;
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) NSRegularExpression *regex;

+ (instancetype)matcherWithObject:(id)object;

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithRegex:(NSRegularExpression *)regex;

- (BOOL)match:(_Matcher *)matcher;

@end
