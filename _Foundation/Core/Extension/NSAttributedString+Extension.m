
#import <CoreText/CoreText.h>
#import "NSAttributedString+Extension.h"

#pragma mark - 

@implementation AttributedStringRange {
    NSMutableArray *_ranges;
    NSMutableAttributedString *_attrString;
    
    AttributedStringBuilder *_builder;
    
}


- (id)initWithAttributeString:(NSMutableAttributedString *)attrString builder:(AttributedStringBuilder *)builder {
    self = [self init];
    if (self != nil) {
        _attrString = attrString;
        _builder = builder;
        _ranges = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addRange:(NSRange)range {
    [_ranges addObject:[NSValue valueWithRange:range]];
}

- (void)enumRange:(void(^)(NSRange range))block {
    if (self == nil || _attrString == nil)
        return;
    
    for (int i = 0; i < _ranges.count; i++) {
        NSRange range = ((NSValue *)[_ranges objectAtIndex:i]).rangeValue;
        if (range.location == NSNotFound || range.length == 0)
            continue;
        
        block(range);
    }
}


- (AttributedStringRange *)setFont:(UIFont *)font {
    [self enumRange:^(NSRange range){
        [self->_attrString addAttribute:NSFontAttributeName value:font range:range];
        
    }];
    
    return self;
}

- (AttributedStringRange *)setTextColor:(UIColor *)color {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
        
    }];
    
    return self;
}

- (AttributedStringRange *)setTextBackgroundColor:(UIColor *)color {
    [self enumRange:^(NSRange range){
        [self->_attrString addAttribute:NSBackgroundColorAttributeName value:color range:range];
        
    }];
    
    return self;
}

- (AttributedStringRange *)setParagraphStyle:(NSParagraphStyle *)paragraphStyle {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setLigature:(BOOL)ligature {
    [self enumRange:^(NSRange range) {
        [self->_attrString addAttribute:NSLigatureAttributeName value:[NSNumber numberWithInteger:ligature] range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setKern:(CGFloat)kern {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:kern] range:range];
    }];
    
    return self;
    
}

- (AttributedStringRange *)setLineSpacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *ps  = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = lineSpacing;
    return [self setParagraphStyle:ps];
}

- (AttributedStringRange *)setStrikethroughStyle:(int)strikethroughStyle {
    [self enumRange:^(NSRange range){
        [self->_attrString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:strikethroughStyle] range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setStrikethroughColor:(UIColor *)strikethroughColor {
    [self enumRange:^(NSRange range) {
        [self->_attrString addAttribute:NSStrikethroughColorAttributeName value:strikethroughColor range:range];
    }];
    
    return self;
}


- (AttributedStringRange *)setUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    [self enumRange:^(NSRange range) {
        [self->_attrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:underlineStyle] range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setShadow:(NSShadow *)shadow {
    [self enumRange:^(NSRange range) {
        
        [self->_attrString addAttribute:NSShadowAttributeName value:shadow range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setTextEffect:(NSString *)textEffect {
    [self enumRange:^(NSRange range) {
        [self->_attrString addAttribute:NSTextEffectAttributeName value:textEffect range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setAttachment:(NSTextAttachment *)attachment {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttribute:NSAttachmentAttributeName value:attachment range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setLink:(NSURL *)url {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttribute:NSLinkAttributeName value:url range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setBaselineOffset:(CGFloat)baselineOffset {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:baselineOffset] range:range];
    }];
    
    return self;
    
}

- (AttributedStringRange *)setUnderlineColor:(UIColor *)underlineColor {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setObliqueness:(CGFloat)obliqueness {
    [self enumRange:^(NSRange range) {
        
        [self->_attrString addAttribute:NSObliquenessAttributeName value:[NSNumber numberWithFloat:obliqueness] range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setExpansion:(CGFloat)expansion {
    [self enumRange:^(NSRange range) {
        
        [self->_attrString addAttribute:NSExpansionAttributeName value:[NSNumber numberWithFloat:expansion] range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setStrokeColor:(UIColor *)strokeColor {
    [self enumRange:^(NSRange range) {
        [self->_attrString addAttribute:NSStrokeColorAttributeName value:strokeColor range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setStrokeWidth:(CGFloat)strokeWidth {
    [self enumRange:^(NSRange range) {
        [self->_attrString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:strokeWidth] range:range];
    }];
    
    return self;
}

- (AttributedStringRange *)setAttributes:(NSDictionary *)dict {
    [self enumRange:^(NSRange range){
        
        [self->_attrString addAttributes:dict range:range];
    }];
    
    return self;
}

- (AttributedStringBuilder *)builder {
    return _builder;
}

@end


@implementation AttributedStringBuilder {
    NSMutableAttributedString *attrString;
    NSInteger paragraphIndex;
}

+ (AttributedStringBuilder *)builderWith:(NSString *)string {
    return [[AttributedStringBuilder alloc] initWithString:string];
}


- (id)initWithString:(NSString *)string {
    self = [self init];
    if (self != nil) {
        if (string != nil)
            attrString = [[NSMutableAttributedString alloc] initWithString:string];
        else
            attrString = nil;
        paragraphIndex = 0;
    }
    
    return self;
}

- (NSString *)string {
    return attrString.string;
}

- (AttributedStringRange *)range:(NSRange)range {
    if (attrString == nil)
        return nil;
    
    if (attrString.length < range.location + range.length)
        return nil;
    
    
    AttributedStringRange *attrstrrang = [[AttributedStringRange alloc] initWithAttributeString:attrString builder:self];
    [attrstrrang addRange:range];
    return attrstrrang;
}

- (AttributedStringRange *)allRange {
    if (attrString == nil)
        return nil;
    
    NSRange range = NSMakeRange(0, attrString.length);
    return [self range:range];
}

- (AttributedStringRange *)lastRange {
    if (attrString == nil)
        return nil;
    
    NSRange range = NSMakeRange(attrString.length - 1, 1);
    return [self range:range];
}

- (AttributedStringRange *)lastNRange:(NSInteger)length {
    if (attrString == nil)
        return nil;
    
    return [self range:NSMakeRange(attrString.length - length, length)];
}

- (AttributedStringRange *)firstRange {
    if (attrString == nil)
        return nil;
    
    NSRange range = NSMakeRange(0, attrString.length > 0 ? 1 : 0);
    return [self range:range];
}

- (AttributedStringRange *)firstNRange:(NSInteger)length {
    if (attrString == nil)
        return nil;
    
    return [self range:NSMakeRange(0, length)];
}

- (AttributedStringRange *)characterSet:(NSCharacterSet *)characterSet {
    if (attrString == nil)
        return nil;
    
    
    //遍历所有字符，然后计算数值
    AttributedStringRange *attrstrrang = [[AttributedStringRange alloc] initWithAttributeString:attrString builder:self];
    
    
    NSString *str = attrString.string;
    NSRange range = NSMakeRange(0, 0);
    BOOL isStart = YES;
    for (int i = 0; i < str.length; i++) {
        unichar uc  = [str characterAtIndex:i];
        if ([characterSet characterIsMember:uc]) {
            if (isStart) {
                range.location = i;
                range.length = 0;
                isStart = NO;
            }
            
            range.length++;
        } else {
            if (!isStart) {
                isStart = YES;
                
                [attrstrrang addRange:range];
            }
        }
    }
    
    if (!isStart)
        [attrstrrang addRange:range];
    
    return attrstrrang;
}


- (AttributedStringRange *)searchString:(NSString *)searchString options:(NSStringCompareOptions)options all:(BOOL)all {
    if (attrString == nil)
        return nil;
    
    
    AttributedStringRange *attRange = [[AttributedStringRange alloc] initWithAttributeString:attrString builder:self];
    NSString *str = attrString.string;
    if (!all) {
        return [self range:[str rangeOfString:searchString options:options]];
    } else {
        NSRange searchRange = NSMakeRange(0, str.length);
        NSRange range = NSMakeRange(0, 0);
        
        while(range.location != NSNotFound && searchRange.location < str.length) {
            range = [str rangeOfString:searchString options:options range:searchRange];
            [attRange addRange:range];
            if (range.location != NSNotFound) {
                searchRange.location = range.location + range.length;
                searchRange.length = str.length - searchRange.location;
            }
        }
        
        
    }
    
    return attRange;
    
}

- (AttributedStringRange *)includeString:(NSString *)includeString all:(BOOL)all {
    return [self searchString:includeString options:0 all:all];
}

- (AttributedStringRange *)regularExpression:(NSString *)regularExpression all:(BOOL)all {
    return [self searchString:regularExpression options:NSRegularExpressionSearch all:all];
}

- (AttributedStringRange *)firstParagraph {
    if (attrString == nil)
        return nil;
    
    
    paragraphIndex = 0;
    
    NSString *str = attrString.string;
    NSRange range = NSMakeRange(0, 0);
    NSInteger i;
    for (i = paragraphIndex; i < str.length; i++) {
        unichar uc = [str characterAtIndex:i];
        if (uc == '\n') {
            range.location =  0;
            range.length = i + 1;
            paragraphIndex = i + 1;
            break;
        }
    }
    
    if (i >= str.length) {
        range.location = 0;
        range.length = i;
        paragraphIndex = i;
    }
    
    
    return [self range:range];
}

- (AttributedStringRange *)nextParagraph {
    if (attrString == nil)
        return nil;
    
    NSString *str = attrString.string;
    
    if (paragraphIndex >= str.length)
        return nil;
    
    
    NSRange range = NSMakeRange(0, 0);
    NSInteger i;
    for (i = paragraphIndex; i < str.length; i++) {
        unichar uc = [str characterAtIndex:i];
        if (uc == '\n') {
            range.location =  paragraphIndex;
            range.length = i - paragraphIndex + 1;
            paragraphIndex = i + 1;
            break;
        }
    }
    
    if (i >= str.length) {
        range.location = paragraphIndex;
        range.length = i - paragraphIndex;
        paragraphIndex = i + 1;
    }
    
    
    return [self range:range];
}


- (void)insert:(NSInteger)pos attrstring:(NSAttributedString *)attrstring {
    if (attrString == nil || attrstring == nil)
        return;
    
    if (pos == -1)
        [attrString appendAttributedString:attrstring];
    else
        [attrString insertAttributedString:attrstring atIndex:pos];
}

- (void)insert:(NSInteger)pos attrBuilder:(AttributedStringBuilder *)attrBuilder {
    [self insert:pos attrstring:attrBuilder.commit];
}

- (NSAttributedString *)commit {
    return attrString;
}

@end

#pragma mark -

@implementation NSAttributedString (Extension)

+ (NSAttributedString *)attributedString:(NSString *)attributedString searchString:(NSString *)searchString color:(UIColor *)color {
    AttributedStringBuilder *builder = [[AttributedStringBuilder alloc] initWithString:attributedString];
    NSString *string = [builder string];
    NSRange range = [string rangeOfString:searchString];
    [[builder range:range] setTextColor:color];
    return [builder commit];
}

+ (NSAttributedString *)attributedString:(NSString *)attributedString searchStringArray:(NSArray *)searchStringArray color:(UIColor *)color {
    AttributedStringBuilder *builder = [[AttributedStringBuilder alloc] initWithString:attributedString];
    NSString *string = [builder string];
    
    for (NSString *rangeStr in searchStringArray) {
        NSRange range = [string rangeOfString:rangeStr options:NSBackwardsSearch];
        [[builder range:range] setTextColor:color];
    }
    
    return [builder commit];
}

@end

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: NS(Mutable)AttributedString Additions
/////////////////////////////////////////////////////////////////////////////

@implementation NSAttributedString (OHCommodityConstructors)
+(id)attributedStringWithString:(NSString*)string {
    return string ? [[self alloc] initWithString:string] : nil;
}
+(id)attributedStringWithAttributedString:(NSAttributedString*)attrStr {
    return attrStr ? [[self alloc] initWithAttributedString:attrStr] : nil;
}

-(CGSize)sizeConstrainedToSize:(CGSize)maxSize {
    return [self sizeConstrainedToSize:maxSize fitRange:NULL];
}
-(CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange*)fitRange {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    CFRange fitCFRange = CFRangeMake(0,0);
    CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,maxSize,&fitCFRange);
    if (framesetter) CFRelease(framesetter);
    if (fitRange) *fitRange = NSMakeRange(fitCFRange.location, fitCFRange.length);
    return CGSizeMake( floorf(sz.width+1) , floorf(sz.height+1) ); // take 1pt of margin for security
}
@end




@implementation NSMutableAttributedString (OHCommodityStyleModifiers)

-(void)setFont:(UIFont*)font {
    [self setFontName:font.fontName size:font.pointSize];
}
-(void)setFont:(UIFont*)font range:(NSRange)range {
    [self setFontName:font.fontName size:font.pointSize range:range];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size {
    [self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range {
    // kCTFontAttributeName
    CTFontRef aFont = CTFontCreateWithName((CFStringRef)fontName, size, NULL);
    if (!aFont) return;
    [self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
    CFRelease(aFont);
}
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range {
    // kCTFontFamilyNameAttribute + kCTFontTraitsAttribute
    CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
    NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:symTrait] forKey:(NSString*)kCTFontSymbolicTrait];
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          fontFamily,kCTFontFamilyNameAttribute,
                          trait,kCTFontTraitsAttribute,nil];
    
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attr);
    if (!desc) return;
    CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
    CFRelease(desc);
    if (!aFont) return;
    
    [self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
    CFRelease(aFont);
}

-(void)setTextColor:(UIColor*)color {
    [self setTextColor:color range:NSMakeRange(0,[self length])];
}
-(void)setTextColor:(UIColor*)color range:(NSRange)range {
    // kCTForegroundColorAttributeName
    [self removeAttribute:(NSString*)kCTForegroundColorAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}

-(void)setTextIsUnderlined:(BOOL)underlined {
    [self setTextIsUnderlined:underlined range:NSMakeRange(0,[self length])];
}
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range {
    int32_t style = underlined ? (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid) : kCTUnderlineStyleNone;
    [self setTextUnderlineStyle:style range:range];
}
-(void)setTextUnderlineStyle:(int32_t)style range:(NSRange)range {
    [self removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:range];
}

-(void)setTextBold:(BOOL)isBold range:(NSRange)range {
    NSUInteger startPoint = range.location;
    NSRange effectiveRange;
    do {
        // Get font at startPoint
        CTFontRef currentFont = (__bridge CTFontRef)[self attribute:(NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
        // The range for which this font is effective
        NSRange fontRange = NSIntersectionRange(range, effectiveRange);
        // Create bold/unbold font variant for this font and apply
        CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(currentFont, 0.0, NULL, (isBold?kCTFontBoldTrait:0), kCTFontBoldTrait);
        if (newFont) {
            [self removeAttribute:(NSString*)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
            [self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)newFont range:fontRange];
            CFRelease(newFont);
        } else {
            //NSString* fontName = [(NSString*)CTFontCopyFullName(currentFont) autorelease];
            //NSLog(@"[OHAttributedLabel] Warning: can't find a bold font variant for font %@. Try another font family (like Helvetica) instead.",fontName);
        }
        ////[self removeAttribute:(NSString*)kCTFontWeightTrait range:fontRange]; // Work around for Apple leak
        ////[self addAttribute:(NSString*)kCTFontWeightTrait value:(id)[NSNumber numberWithInt:1.0f] range:fontRange];
        
        // If the fontRange was not covering the whole range, continue with next run
        startPoint = NSMaxRange(effectiveRange);
    } while(startPoint<NSMaxRange(range));
}

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode {
    [self setTextAlignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range {
    // kCTParagraphStyleAttributeName > kCTParagraphStyleSpecifierAlignment
    CTParagraphStyleSetting paraStyles[2] = {
        {.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
        {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
    };
    CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 2);
    [self removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(__bridge id)aStyle range:range];
    CFRelease(aStyle);
}

@end
