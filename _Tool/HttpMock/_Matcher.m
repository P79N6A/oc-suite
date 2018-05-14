#import "_Matcher.h"

@implementation _Matcher

+ (instancetype)matcherWithObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return [[_Matcher alloc] initWithString:object];
    } else if ([object isKindOfClass:[NSData class]]) {
        return [[_Matcher alloc] initWithData:object];
    } else if ([object isKindOfClass:[NSRegularExpression class]]) {
        return [[_Matcher alloc] initWithRegex:object];
    } else {
        return nil;
    }
}

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        _string = string;
        _matchType = _MatcherTypeString;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        _data = data;
        _matchType = _MatcherTypeData;
    }
    return self;
}
- (instancetype)initWithRegex:(NSRegularExpression *)regex {
    if (self = [super init]) {
        _regex = regex;
        _matchType = _MatcherTypeRegex;
    }
    return self;
}

- (BOOL)match:(_Matcher *)matcher {
    switch (self.matchType) {
        case _MatcherTypeString:
            return [_string isEqualToString:matcher.string];
       case _MatcherTypeData:
            return [_data isEqual:matcher.data];
        case _MatcherTypeRegex:
            return [_regex numberOfMatchesInString:matcher.string options:0 range:NSMakeRange(0, matcher.string.length)] > 0;
        default:
            return NO;
    }
}

- (NSString *)description {
    if (self.matchType == _MatcherTypeString) {
        return self.string;
    } else if (self.matchType == _MatcherTypeData) {
        return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    } else if (self.matchType == _MatcherTypeRegex) {
        return self.regex.pattern;
    }
    
    return NSStringFromClass(self.class);
}

@end
