//
//  NJKWebViewProgress.h
//
//  Created by Satoshi Aasano on 4/20/13.
//  Copyright (c) 2013 Satoshi Asano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern const float NJKInitialProgressValue;
extern const float NJKInteractiveProgressValue;
extern const float NJKFinalProgressValue;

typedef void (^NJKWebViewProgressBlock)(float progress);

@protocol WebViewProgressDelegate;

@interface WebViewProgress : NSObject <UIWebViewDelegate>

@property (nonatomic, weak) id<WebViewProgressDelegate>     progressDelegate;
@property (nonatomic, copy) NJKWebViewProgressBlock         progressBlock;
@property (nonatomic, readonly) float                       progress; // 0.0..1.0

- (void)reset;

@end

@protocol WebViewProgressDelegate <NSObject>

- (void)webViewProgress:(WebViewProgress *)webViewProgress updateProgress:(float)progress;

@end

