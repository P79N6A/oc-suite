
#import "NSString+Extension.h"
#import "NSObject+Extension.h"
#import "regex.h"
#import "NSData+Extension.h"
#import <CommonCrypto/CommonHMAC.h>

// ----------------------------------
// Predefine code
// ----------------------------------


// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

/*
 * Replaces all occurences and stores it in buf
 */
int rreplace (char *buf, int size, regex_t *re, char *rp) {
    char *pos;
    long long sub, so, n;
    regmatch_t pmatch [10]; /* regoff_t is int so size is int */
    
    if (regexec (re, buf, 10, pmatch, 0)) return 0;
    for (pos = rp; *pos; pos++) {
        if (*pos == '\\' && *(pos + 1) > '0' && *(pos + 1) <= '9') {
            so = pmatch [*(pos + 1) - 48].rm_so;
            n = pmatch [*(pos + 1) - 48].rm_eo - so;
            if (so < 0 || strlen (rp) + n - 1 > size) return 1;
            memmove (pos + n, pos + 2, strlen (pos) - 1);
            memmove (pos, buf + so, n);
            pos = pos + n - 2;
        }
    }
    
    sub = pmatch [1].rm_so; /* no repeated replace when sub >= 0 */
    for (pos = buf; !regexec (re, pos, 1, pmatch, 0); ) {
        n = pmatch [0].rm_eo - pmatch [0].rm_so;
        pos += pmatch [0].rm_so;
        if (strlen (buf) - n + strlen (rp) + 1 > size) return 1;
        memmove (pos + strlen (rp), pos + n, strlen (pos) - n + 1);
        memmove (pos, rp, strlen (rp));
        pos += strlen (rp);
        if (sub >= 0) break;
    }
    
    return 0;
}

@implementation NSString (Extension)

- (NSString *)unwrap {
    if ( self.length >= 2 ) {
        if ( [self hasPrefix:@"\""] && [self hasSuffix:@"\""] ) {
            return [self substringWithRange:NSMakeRange(1, self.length - 2)];
        }
        
        if ( [self hasPrefix:@"'"] && [self hasSuffix:@"'"] ) {
            return [self substringWithRange:NSMakeRange(1, self.length - 2)];
        }
    }
    
    return self;
}

- (NSString *)normalize {
    NSArray * lines = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ( lines && lines.count ) {
        NSMutableString * mergedString = [NSMutableString string];
        
        for ( NSString * line in lines ) {
            NSString * trimed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ( trimed && trimed.length ) {
                [mergedString appendString:trimed];
            }
        }
        
        return mergedString;
    }
    
    return nil;
}

#pragma mark - Trimming

- (NSString *)trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 *  @brief  清除html标签
 *
 *  @return 清除后的结果
 */
- (NSString *)strippingHTML {
    return [self stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

/**
 *  @brief  清除js脚本
 *
 *  @return 清楚js后的结果
 */
- (NSString *)removingScriptsAndStrippingHTML {
    NSMutableString *mString = [self mutableCopy];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>[\\w\\W]*</script>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:mString options:NSMatchingReportProgress range:NSMakeRange(0, [mString length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [mString replaceCharactersInRange:match.range withString:@""];
    }
    return [mString strippingHTML];
}

/**
 *  @brief  去除空格
 *
 *  @return 去除空格后的字符串
 */
- (NSString *)trimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/**
 *  @brief  去除字符串与空行
 *
 *  @return 去除字符串与空行的字符串
 */
- (NSString *)trimmingWhitespaceAndNewlines {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSString*)trimmingWhitespaceAndChangLineWithChangN:(NSString*)str{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}

#pragma mark -

- (NSString *)repeat:(NSUInteger)count {
	if ( 0 == count )
		return @"";

	NSMutableString * text = [NSMutableString string];
	
	for ( NSUInteger i = 0; i < count; ++i ) {
		[text appendString:self];
	}
	
	return text;
}

- (NSString *)strongify {
	return [self stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
}

- (BOOL)match:(NSString *)expression {
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expression
																			options:NSRegularExpressionCaseInsensitive
																			  error:nil];
	if ( nil == regex )
		return NO;
	
	NSUInteger numberOfMatches = [regex numberOfMatchesInString:self
														options:0
														  range:NSMakeRange(0, self.length)];
	if ( 0 == numberOfMatches )
		return NO;
	
	return YES;
}

- (BOOL)matchAnyOf:(NSArray *)array {
	for ( NSString * str in array ) {
		if ( NSOrderedSame == [self compare:str options:NSCaseInsensitiveSearch] ) {
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)empty {
	return [self length] > 0 ? NO : YES;
}

- (BOOL)notEmpty {
	return [self length] > 0 ? YES : NO;
}

- (BOOL)is:(NSString *)other {
	return [self isEqualToString:other];
}

- (BOOL)isNot:(NSString *)other {
	return NO == [self isEqualToString:other];
}

- (BOOL)isValueOf:(NSArray *)array {
	return [self isValueOf:array caseInsens:NO];
}

- (BOOL)isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens {
	NSStringCompareOptions option = caseInsens ? NSCaseInsensitiveSearch : 0;
	
	for ( NSObject * obj in array ) {
		if ( NO == [obj isKindOfClass:[NSString class]] )
			continue;
		
		if ( NSOrderedSame == [(NSString *)obj compare:self options:option] )
			return YES;
	}
	
	return NO;
}

//added end
- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string {
	return [self substringFromIndex:from untilString:string endOffset:NULL];
}

- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string endOffset:(NSUInteger *)endOffset {
	if ( 0 == self.length )
		return nil;
	
	if ( from >= self.length )
		return nil;
	
	NSRange range = NSMakeRange( from, self.length - from );
	NSRange range2 = [self rangeOfString:string options:NSCaseInsensitiveSearch range:range];
	
	if ( NSNotFound == range2.location ) {
		if ( endOffset ) {
			*endOffset = range.location + range.length;
		}
		
		return [self substringWithRange:range];
	} else {
		if ( endOffset ) {
			*endOffset = range2.location + range2.length;
		}
		
		return [self substringWithRange:NSMakeRange(from, range2.location - from)];
	}
}

- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset {
	return [self substringFromIndex:from untilCharset:charset endOffset:NULL];
}

- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset endOffset:(NSUInteger *)endOffset
{
	if ( 0 == self.length )
		return nil;
	
	if ( from >= self.length )
		return nil;

	NSRange range = NSMakeRange( from, self.length - from );
	NSRange range2 = [self rangeOfCharacterFromSet:charset options:NSCaseInsensitiveSearch range:range];

	if ( NSNotFound == range2.location )
	{
		if ( endOffset )
		{
			*endOffset = range.location + range.length;
		}
		
		return [self substringWithRange:range];
	}
	else
	{
		if ( endOffset )
		{
			*endOffset = range2.location + range2.length;
		}

		return [self substringWithRange:NSMakeRange(from, range2.location - from)];
	}
}

- (NSUInteger)countFromIndex:(NSUInteger)from inCharset:(NSCharacterSet *)charset
{
	if ( 0 == self.length )
		return 0;
	
	if ( from >= self.length )
		return 0;
	
	NSCharacterSet * reversedCharset = [charset invertedSet];

	NSRange range = NSMakeRange( from, self.length - from );
	NSRange range2 = [self rangeOfCharacterFromSet:reversedCharset options:NSCaseInsensitiveSearch range:range];

	if ( NSNotFound == range2.location )
	{
		return self.length - from;
	}
	else
	{
		return range2.location - from;		
	}
}

- (NSArray *)pairSeparatedByString:(NSString *)separator {
	if ( nil == separator )
		return nil;
	
	NSUInteger	offset = 0;
	NSString *	key = [self substringFromIndex:0 untilCharset:[NSCharacterSet characterSetWithCharactersInString:separator] endOffset:&offset];
	NSString *	val = nil;

	if ( nil == key || offset >= self.length )
		return nil;
	
	val = [self substringFromIndex:offset];
	if ( nil == val )
		return nil;

	return [NSArray arrayWithObjects:key, val, nil];
}

#define NotFoundEx -1

/**  Java-like method. Returns the char value at the specified index. */
- (unichar)charAt:(int)index {
    return [self characterAtIndex:index];
}

/**
 * Java-like method. Compares two strings lexicographically.
 * the value 0 if the argument string is equal to this string;
 * a value less than 0 if this string is lexicographically less than the string argument;
 * and a value greater than 0 if this string is lexicographically greater than the string argument.
 */
- (int)compareTo:(NSString*) anotherString {
    return [self compare:anotherString];
}

/** Java-like method. Compares two strings lexicographically, ignoring case differences. */
- (int)compareToIgnoreCase:(NSString*) str {
    return [self compare:str options:NSCaseInsensitiveSearch];
}

/** Java-like method. Returns true if and only if this string contains the specified sequence of char values. */
- (BOOL)contains:(NSString*) str {
    NSRange range = [self rangeOfString:str];
    return (range.location != NSNotFound);
}

- (BOOL)contains:(NSString*) str options:(NSStringCompareOptions)option {
    NSRange range = [self rangeOfString:str options:option];
    return (range.location != NSNotFound);
}

- (int)wordsCount {
    NSInteger n = self.length;
    int i;
    int l = 0, a = 0, b = 0;
    unichar c;
    for (i = 0; i < n; i++) {
        c = [self characterAtIndex:i];
        if (isblank(c)) {
            b++;
        } else if (isascii(c)) {
            a++;
        } else {
            l++;
        }
    }
    if (a == 0 && l == 0) {
        return 0;
    }
    return l + (int)ceilf((float)(a + b) / 2.0);
}

- (BOOL)startsWith:(NSString*)prefix {
    return [self hasPrefix:prefix];
}

- (BOOL)endsWith:(NSString*)suffix {
    return [self hasSuffix:suffix];
}

- (BOOL)equalsIgnoreCase:(NSString *)anotherString {
    return [[self toLowerCase] is:[anotherString toLowerCase]];
}

- (int)indexOfChar:(unichar)ch {
    return [self indexOfChar:ch fromIndex:0];
}

- (int)indexOfChar:(unichar)ch fromIndex:(int)index {
    int len = (int)self.length;
    for (int i = index; i < len; ++i) {
        if (ch == [self charAt:i]) {
            return i;
        }
    }
    return NotFoundEx;
}

- (int)indexOfString:(NSString*)str {
    NSRange range = [self rangeOfString:str];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (int)indexOfString:(NSString*)str fromIndex:(int)index {
    NSRange fromRange = NSMakeRange(index, self.length - index);
    NSRange range = [self rangeOfString:str options:NSLiteralSearch range:fromRange];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (int)lastIndexOfChar:(unichar)ch {
    int len = (int)self.length;
    for (int i = len-1; i >=0; --i) {
        if ([self charAt:i] == ch) {
            return i;
        }
    }
    return NotFoundEx;
}

- (int)lastIndexOfChar:(unichar)ch fromIndex:(int)index {
    int len = (int)self.length;
    if (index >= len) {
        index = len - 1;
    }
    for (int i = index; i >= 0; --i) {
        if ([self charAt:i] == ch) {
            return index;
        }
    }
    return NotFoundEx;
}

- (int)lastIndexOfString:(NSString*)str {
    NSRange range = [self rangeOfString:str options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (int) lastIndexOfString:(NSString*)str fromIndex:(int)index {
    NSRange fromRange = NSMakeRange(0, index);
    NSRange range = [self rangeOfString:str options:NSBackwardsSearch range:fromRange];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (NSString *) substringFromIndex:(int)beginIndex toIndex:(int)endIndex {
    if (endIndex <= beginIndex) {
        return @"";
    }
    NSRange range = NSMakeRange(beginIndex, endIndex - beginIndex);
    return [self substringWithRange:range];
}

- (NSString *)toLowerCase {
    return [self lowercaseString];
}

- (NSString *)toUpperCase {
    return [self uppercaseString];
}

- (NSString *)trimBy:(NSString *)str {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:str];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString *)delZero:(NSString *)src { // 去掉当前字符串的0，不同于[self trimBy:@"0"]
    if ([src endsWith:@"0"]) {
        return [self delZero:[src substringFromIndex:0 toIndex:(int)[src length]-1]];
    } else {
        return src;
    }
}

- (NSString *)trimFloatPointNumber {
    return [[self delZero:self] trimBy:@"."];
}

- (NSString *) replaceAll:(NSString*)origin with:(NSString*)replacement {
    return [self stringByReplacingOccurrencesOfString:origin withString:replacement];
}

- (NSArray *)split:(NSString *)separator {
    return [self componentsSeparatedByString:separator];
}

+ (NSString *)reverseString:(NSString *)strSrc {
    NSMutableString* reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [strSrc length];
    while (charIndex > 0) {
        charIndex --;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[strSrc substringWithRange:subStrRange]];
    }
    return reverseString;
}

- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex {
    NSArray *matches = [self matchesForRegex:regex];
    if (matches.count == 0) return nil;
    NSTextCheckingResult *match = matches[0];
    if (idx >= match.numberOfRanges) return nil;
    
    return [self substringWithRange:[match rangeAtIndex:idx]];
}

- (NSArray *)matchesForRegex:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
        return nil;
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (matches.count == 0)
        return nil;
    
    return matches;
}

- (NSArray *)allMatchesForRegex:(NSString *)regex {
    NSArray *matches = [self matchesForRegex:regex];
    if (matches.count == 0) return @[];
    
    NSMutableArray *strings = [NSMutableArray new];
    for (NSTextCheckingResult *result in matches)
        [strings addObject:[self substringWithRange:[result rangeAtIndex:1]]];
    
    return strings;
}

- (NSString *)stringByReplacingMatchesForRegex:(NSString *)pattern withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:pattern withString:replacement options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)stringByRegex:(NSString*)pattern substitution:(NSString*)substitute {
    regex_t preg;
    NSString *result = nil;
    
    // compile pattern
    int err = regcomp(&preg, [pattern UTF8String], 0 | REG_ICASE | REG_EXTENDED);
    if (err) {
        char errmsg[256];
        regerror(err, &preg, errmsg, sizeof(errmsg));
        //		[NSException raise:@"AFRegexStringException"
        //					format:@"Regex compilation failed for \"%@\": %s", pattern, errmsg];
        return [NSString stringWithString:self];
    } else {
        char buffer[4096];
        char *buf = buffer;
        const char *utf8String = [self UTF8String];
        
        if(strlen(utf8String) >= sizeof(buffer))
            buf = malloc(strlen(utf8String) + 1);
        
        strcpy(buf, utf8String);
        char *replaceStr = (char*)[substitute UTF8String];
        
        if (rreplace (buf, 4096, &preg, replaceStr)) {
            //			[NSException raise:@"AFRegexStringException"
            //						format:@"Replace failed"];
            result = [NSString stringWithString:self];
        } else {
            result = [NSString stringWithUTF8String:buf];
        }
        
        if(buf != buffer)
            free(buf);
    }
    
    
    regfree(&preg);  // fixme: used to be commented
    return result;
}

@end

#pragma mark - 

@implementation NSString (Attributed)

- (NSAttributedString *)attributedString { return [[NSAttributedString alloc] initWithString:self]; }

- (NSAttributedString *)withColor:(UIColor *)color {
    NSParameterAssert(color);
    return [[NSAttributedString alloc] initWithString:self attributes:@{NSForegroundColorAttributeName: color}];
}

- (NSMutableAttributedString *)withSubString:(NSString *)subString color:(UIColor *)color {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self];
    
    if (![subString length]) return [[self withColor:color] mutableCopy];
    
    NSRange keyRange   = [self rangeOfString:subString];
    if (keyRange.location == NSNotFound) return [[self withColor:color] mutableCopy];
    
    // Attribute setting
    while (keyRange.location != NSNotFound) {
        [attributedText addAttribute:NSForegroundColorAttributeName
                               value:color
                               range:keyRange];
        
        // find next sub string
        NSUInteger nextIndex   = keyRange.location+keyRange.length;
        keyRange    = [self rangeOfString:subString
                                  options:NSLiteralSearch
                                    range:NSMakeRange(nextIndex, self.length-nextIndex)];
    }
    
    return attributedText;
}

- (NSString *)stringByDeletingCharacterAtIndex:(NSUInteger)idx {
    NSMutableString *string = self.mutableCopy;
    [string replaceCharactersInRange:NSMakeRange(idx, 1) withString:@""];
    return string;
}

@end

#pragma mark - JSDomOperate

@implementation NSString (JSDomOperate)

//如果没有实现getIndex回调直接调用getUrlString的会调 会调用失败。
+ (NSString*)js_getCurrentClickImageIndexAndUrl {
    NSString *scriptString = @"\
    var imges = document.getElementsByTagName('img');\
    var imgeUrlArray = [];\
    function imageClick () {\
    var imgeUrl = this.src;\
    var currentIndex = imgeUrlArray.indexOf(imgeUrl);\
    getIndex(currentIndex);\
    getUrlString(imgeUrl);\
    dyw.getClickImageIndex(currentIndex);\
    }\
    function getImges () {\
    for (var i =0; i < imges.length; i++) {\
    var image = imges[i];\
    image.onclick = imageClick;\
    imgeUrlArray.push(image.src);\
    }\
    return imgeUrlArray;\
    }";
    return scriptString;
}

@end


