//
//  WebFailedView.m
//  student
//
//  Created by fallen.ink on 16/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_building_precompile.h"
#import "WebViewFailedView.h"

@interface WebViewFailedView ()

@property (nonatomic, weak) IBOutlet UIButton *retryButton;

@end

@implementation WebViewFailedView

- (instancetype)init {
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle bundleWithName:@"web"];
        
        self = [[bundle loadNibNamed:@"WebViewFailedView" owner:self options:nil] lastObject];
        
        [self initDefault];
    }
    
    return self;
}

- (void)initDefault {
    // 默认不显示
    self.hidden = YES;
    
    [self.retryButton addTarget:self action:@selector(onRetry) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.layer.cornerRadius = PIXEL_4;
}

- (IBAction)onRetry {
    self.hidden = YES;
    
    if (is_method_implemented(self.delegate, onRefresh)) {
        [self.delegate onRefresh];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.hidden = NO;
}

@end
