//
//  WebSampleVCByJQuery.m
//  startup
//
//  Created by fallen.ink on 26/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "WebSampleVCByJQuery.h"

@interface WebSampleVCByJQuery () <UIWebViewDelegate>

@end

@implementation WebSampleVCByJQuery

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *HtmlString = [self getHTMLString];
    NSString *originalStr = [HtmlString stringByReplacingOccurrencesOfString:@"src" withString:@"data-original"];
    NSString *tempPath = [[NSBundle mainBundle]pathForResource:@"temp" ofType:@"html"];
    NSString *tempHtml = [NSString stringWithContentsOfFile:tempPath encoding:NSUTF8StringEncoding error:nil];
    
    tempHtml = [tempHtml stringByReplacingOccurrencesOfString:@"{{Content_holder}}" withString:originalStr];
    
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];

    [webView loadHTMLString:tempHtml baseURL:baseURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getHTMLString {
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:@"news" ofType:@"html"];
    NSString *HtmlString = [NSString stringWithContentsOfFile:tempPath encoding:NSUTF8StringEncoding error:nil];
    return HtmlString;
}

#pragma mark -

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"[finish] web content size = %@", NSStringFromCGSize(webView.scrollView.contentSize));
}

@end
