//
//  WebSampleVCByTextView.m
//  startup
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "WebSampleVCByTextView.h"

// [iOS UITextView 富文本显示html标签](http://www.cnblogs.com/boyuanmeng/p/7245791.html)
// 一般来说iOS端显示html标签用的都是UIWebView或WKWebView，做的比较方便快捷，但是加载速度也是比较慢的，所以这里记录并推荐一种比较简单的方式：
// 加载html标签的速度有所提升，不过却在此发现一个问题，无论是webView还是富文本都不支持jpeg图片的格式，有知道的大神们，帮忙留下一个答案，十分感谢！！

@interface WebSampleVCByTextView ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation WebSampleVCByTextView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TextView加载HTML例子";
    
    __unused NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    __unused NSString *htmlString = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    self.textView.attributedText = [self attributeStringFromHtml:htmlString withWidth:[UIScreen mainScreen].bounds.size.width];
    self.textView.editable = NO;
    
    // UITextView自适应高度
    
    //自适应高度
    CGRect frame = _textView.frame;
    CGSize size = [_textView.text sizeWithFont:_textView.font
                             constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 2000)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
    frame.size.height = size.height > 1 ? size.height + 20 : 64;
//    _textView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (NSAttributedString *)attributeStringFromHtml:(NSString *)html withWidth:(float)width {
    NSString *newString = [html stringByReplacingOccurrencesOfString:@"<img" withString:[NSString stringWithFormat:@"<img width=\"%f\"",width]];
    
    NSAttributedString *attributeString =
    [[NSAttributedString alloc]
     initWithData:
     [newString dataUsingEncoding:NSUnicodeStringEncoding]
     options:@{
               NSDocumentTypeDocumentAttribute
               :
               NSHTMLTextDocumentType
               }
     documentAttributes:nil error:nil];
    
    
    return attributeString;
    
}

#pragma mark -

- (NSString *)getImagePathInHTML:(NSString *)html withPreferFileName:(NSString *)fileName {
    
    NSError *error = nil;
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"(]*?>)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *array = [expression matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    
    __block NSString *result = nil;
    
    [array enumerateObjectsUsingBlock:^(NSTextCheckingResult *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *content = [html substringWithRange:obj.range];
        
        NSRange range = [content rangeOfString:fileName];
        
        if (range.location < html.length) {
            
            result = content;
            
            *stop = YES;
            
        }
        
    }];
    
    NSRegularExpression *pathExpression = [NSRegularExpression regularExpressionWithPattern:@"(src\\s*=\s*\"?(.*?)(\"|>|\s+))" options:NSRegularExpressionCaseInsensitive error:0];
                                                                                                                 
    NSArray *pathArray = nil;
                                                                                                                 
    if (result) {
        pathArray = [pathExpression matchesInString:result options:0 range:NSMakeRange(0, result.length)];
    }
    
    if (pathArray.count > 0) {
        NSTextCheckingResult *checking = pathArray[0];
        result = [result substringWithRange:checking.range];
        
        NSRegularExpression *httpExpression = [NSRegularExpression regularExpressionWithPattern:@"((http|file).*)" options:0 error:0];
        
        NSArray *httpChecking = [httpExpression matchesInString:result options:0 range:NSMakeRange(0, result.length)];
        
        if (httpChecking.count > 0) {
            checking = httpChecking[0];
                                                                                                                         
            result = [result substringWithRange:checking.range];
            result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                      return result;
        }
    }
    
    return nil;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0) {
    
    //NSFileWrapper
    
    UIImage *image = [UIImage imageWithData:textAttachment.fileWrapper.regularFileContents];
    
    
    
    if (image && image.classForCoder == [UIImage class]) {
        
//        if ([self.delegate respondsToSelector:@selector(topicTabViewCell:selectImage:)]) {
//
//            [self.delegate topicTabViewCell:self selectImage:image];
//
//        }
        
    }
    
    //    NSString *preferFileName = textAttachment.fileWrapper.preferredFilename;
    
    //    if(preferFileName.length > 0) {
    
    //        NSString *imagePath = [self getImagePathInHTML:self.html withPreferFileName:preferFileName];
    
    //        if (imagePath.length > 0 && [self.delegate respondsToSelector:@selector(topicTabViewCell:selectImage:)]) {
    
    //            [self.delegate topicTabViewCell:self selectImage:imagePath];
    
    //        }
    
    //    }
    
    return YES;
    
}

@end
