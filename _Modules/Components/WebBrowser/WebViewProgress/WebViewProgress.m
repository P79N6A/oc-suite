//
//  NJKWebViewProgress.m
//
//  Created by Satoshi Aasano on 4/20/13.
//  Copyright (c) 2013 Satoshi Asano. All rights reserved.
//

#import "_precompile.h"
#import "WebViewProgress.h"

static NSString *completeRPCURLPath = @"/njkwebviewprogressproxy/complete";

const float NJKInitialProgressValue = 0.1f;
const float NJKInteractiveProgressValue = 0.5f;
const float NJKFinalProgressValue = 0.9f;

@implementation WebViewProgress {
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    NSURL *_currentURL;
    BOOL _interactive;
}

- (id)init {
    if (self = [super init]) {
        _maxLoadCount = _loadingCount = 0;
        _interactive = NO;
    }
    return self;
}

- (void)startProgress {
    LOG(@"start progress");
    if (_progress < NJKInitialProgressValue) {
        [self setProgress:NJKInitialProgressValue];
    }
}

- (void)incrementProgress {
    LOG(@"increment progress");
    if (!_maxLoadCount) {
        return;
    }
    
    float progress = self.progress;
    float maxProgress = _interactive ? NJKFinalProgressValue : NJKInteractiveProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress {
    LOG(@"complete progress");
    
    [self setProgress:1.0];
}

- (void)setProgress:(float)progress
{
    NSLog(@"wanna progress = %f, current progress = %f", progress, _progress);
    // progress should be incremental only
    if (progress >= _progress || progress == 0) {
        _progress = progress;
        if ([_progressDelegate respondsToSelector:@selector(webViewProgress:updateProgress:)]) {
            [_progressDelegate webViewProgress:self updateProgress:progress];
        }
        if (_progressBlock) {
            _progressBlock(progress);
        }
    }
}

- (void)reset {
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.0];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"request url = %@", request.URL.path);
    
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }

    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];

    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (!isFragmentJump && isHTTP && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);

    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];

    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _loadingCount--;
    [self incrementProgress];

    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];

    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}

#pragma mark - 
#pragma mark Method Forwarding
// for future UIWebViewDelegate impl

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ( [super respondsToSelector:aSelector] )
        return YES;
    
    return NO;
}

@end
