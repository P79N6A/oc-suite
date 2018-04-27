//
//  UITextField+CalculateCursorOffset.m
//  查找光标位置
//
//  Created by renren on 5/21/15.
//  Copyright (c) 2015 renren. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextField+Extension.h"

@implementation UITextField ( CursorOffset )

- (CGFloat)cursorOffset {
    NSArray *textrect = [self selectionRectsForRange:[self selectedTextRange]];
    CGRect rect = ((UITextSelectionRect *)textrect[0]).rect;
    
    if (rect.origin.x > 100000) {
        CGSize size = [self boundingRectWithSize:CGSizeMake(0, CGRectGetHeight(self.frame))];
        if (self.textAlignment == NSTextAlignmentCenter){
            CGSize size = [self boundingRectWithSize:CGSizeMake(0, CGRectGetHeight(self.frame))];
            CGFloat width = CGRectGetWidth(self.frame);
            return width - (width - size.width)/2.0f;
        } else if (self.textAlignment == NSTextAlignmentRight){
            return CGRectGetWidth(self.frame);
        } else {
            return size.width;
        }
    }
    
    return rect.origin.x;
}

- (CGSize)boundingRectWithSize:(CGSize)size {
    NSDictionary *attribute = @{NSFontAttributeName: self.font};
    
    CGSize retSize = [self.text boundingRectWithSize:size
                                                       options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                                    attributes:attribute
                                                       context:nil].size;
    
    return retSize;
}

@end

#pragma mark -

static const void *JKTextFieldInputLimitMaxLength = &JKTextFieldInputLimitMaxLength;
@implementation UITextField (JKInputLimit)

- (NSInteger)maxLength {
    return [objc_getAssociatedObject(self, JKTextFieldInputLimitMaxLength) integerValue];
}
- (void)setMaxLength:(NSInteger)maxLength {
    objc_setAssociatedObject(self, JKTextFieldInputLimitMaxLength, @(maxLength), OBJC_ASSOCIATION_ASSIGN);
    [self addTarget:self action:@selector(textFieldTextDidChange) forControlEvents:UIControlEventEditingChanged];
}
- (void)textFieldTextDidChange {
    NSString *toBeString = self.text;
    //获取高亮部分
    UITextRange *selectedRange = [self markedTextRange];
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    
    //没有高亮选择的字，则对已输入的文字进行字数统计和限制
    //在iOS7下,position对象总是不为nil
    if ( (!position ||!selectedRange) && (self.maxLength > 0 && toBeString.length > self.maxLength)) {
        NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.maxLength];
        if (rangeIndex.length == 1) {
            self.text = [toBeString substringToIndex:self.maxLength];
        } else {
            NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.maxLength)];
            NSInteger tmpLength;
            if (rangeRange.length > self.maxLength) {
                tmpLength = rangeRange.length - rangeIndex.length;
            } else {
                tmpLength = rangeRange.length;
            }
            self.text = [toBeString substringWithRange:NSMakeRange(0, tmpLength)];
        }
    }
}

@end

#pragma mark - 

@implementation UITextField ( ExtentRange )

- (NSRange)selectedRange {
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

- (void)selectAllText {
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

@end

#pragma mark -

typedef BOOL (^UITextFieldReturnBlock) (UITextField *textField);
typedef void (^UITextFieldVoidBlock) (UITextField *textField);
typedef BOOL (^UITextFieldCharacterChangeBlock) (UITextField *textField, NSRange range, NSString *replacementString);

@implementation UITextField ( Blocks )

static const void *JKUITextFieldDelegateKey = &JKUITextFieldDelegateKey;
static const void *JKUITextFieldShouldBeginEditingKey = &JKUITextFieldShouldBeginEditingKey;
static const void *JKUITextFieldShouldEndEditingKey = &JKUITextFieldShouldEndEditingKey;
static const void *JKUITextFieldDidBeginEditingKey = &JKUITextFieldDidBeginEditingKey;
static const void *JKUITextFieldDidEndEditingKey = &JKUITextFieldDidEndEditingKey;
static const void *JKUITextFieldShouldChangeCharactersInRangeKey = &JKUITextFieldShouldChangeCharactersInRangeKey;
static const void *JKUITextFieldShouldClearKey = &JKUITextFieldShouldClearKey;
static const void *JKUITextFieldShouldReturnKey = &JKUITextFieldShouldReturnKey;

#pragma mark UITextField Delegate methods

+ (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UITextFieldReturnBlock block = textField.shouldBegindEditingBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, JKUITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [delegate textFieldShouldBeginEditing:textField];
    }
    // return default value just in case
    return YES;
}

+ (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    UITextFieldReturnBlock block = textField.shouldEndEditingBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, JKUITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [delegate textFieldShouldEndEditing:textField];
    }
    // return default value just in case
    return YES;
}

+ (void)textFieldDidBeginEditing:(UITextField *)textField {
    UITextFieldVoidBlock block = textField.didBeginEditingBlock;
    if (block) {
        block(textField);
    }
    id delegate = objc_getAssociatedObject(self, JKUITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}

+ (void)textFieldDidEndEditing:(UITextField *)textField {
    UITextFieldVoidBlock block = textField.didEndEditingBlock;
    if (block) {
        block(textField);
    }
    id delegate = objc_getAssociatedObject(self, JKUITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UITextFieldCharacterChangeBlock block = textField.shouldChangeCharactersInRangeBlock;
    if (block) {
        return block(textField,range,string);
    }
    id delegate = objc_getAssociatedObject(self, JKUITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

+ (BOOL)textFieldShouldClear:(UITextField *)textField {
    UITextFieldReturnBlock block = textField.shouldClearBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, JKUITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [delegate textFieldShouldClear:textField];
    }
    return YES;
}

+ (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UITextFieldReturnBlock block = textField.shouldReturnBlock;
    if (block) {
        return block(textField);
    }
    id delegate = objc_getAssociatedObject(self, JKUITextFieldDelegateKey);
    if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [delegate textFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark Block setting/getting methods

- (BOOL (^)(UITextField *))shouldBegindEditingBlock {
    return objc_getAssociatedObject(self, JKUITextFieldShouldBeginEditingKey);
}

- (void)setShouldBegindEditingBlock:(BOOL (^)(UITextField *))shouldBegindEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, JKUITextFieldShouldBeginEditingKey, shouldBegindEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL (^)(UITextField *))shouldEndEditingBlock {
    return objc_getAssociatedObject(self, JKUITextFieldShouldEndEditingKey);
}

- (void)setShouldEndEditingBlock:(BOOL (^)(UITextField *))shouldEndEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, JKUITextFieldShouldEndEditingKey, shouldEndEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UITextField *))didBeginEditingBlock {
    return objc_getAssociatedObject(self, JKUITextFieldDidBeginEditingKey);
}

- (void)setDidBeginEditingBlock:(void (^)(UITextField *))didBeginEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, JKUITextFieldDidBeginEditingKey, didBeginEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UITextField *))didEndEditingBlock {
    return objc_getAssociatedObject(self, JKUITextFieldDidEndEditingKey);
}

- (void)setDidEndEditingBlock:(void (^)(UITextField *))didEndEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, JKUITextFieldDidEndEditingKey, didEndEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL (^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock {
    return objc_getAssociatedObject(self, JKUITextFieldShouldChangeCharactersInRangeKey);
}

- (void)setShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, JKUITextFieldShouldChangeCharactersInRangeKey, shouldChangeCharactersInRangeBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL (^)(UITextField *))shouldReturnBlock {
    return objc_getAssociatedObject(self, JKUITextFieldShouldReturnKey);
}

- (void)setShouldReturnBlock:(BOOL (^)(UITextField *))shouldReturnBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, JKUITextFieldShouldReturnKey, shouldReturnBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL (^)(UITextField *))shouldClearBlock {
    return objc_getAssociatedObject(self, JKUITextFieldShouldClearKey);
}

- (void)setshouldClearBlock:(BOOL (^)(UITextField *textField))shouldClearBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, JKUITextFieldShouldClearKey, shouldClearBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark - control method
/*
 Setting itself as delegate if no other delegate has been set. This ensures the UITextField will use blocks if no delegate is set.
 */
- (void)setDelegateIfNoDelegateSet {
    if (self.delegate != (id<UITextFieldDelegate>)[self class]) {
        objc_setAssociatedObject(self, JKUITextFieldDelegateKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
        self.delegate = (id<UITextFieldDelegate>)[self class];
    }
}
@end
