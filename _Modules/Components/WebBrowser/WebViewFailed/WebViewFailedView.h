//
//  WebViewFailedView.h
//  student
//
//  Created by fallen.ink on 16/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewFailedViewDelegate;

#pragma mark -

@interface WebViewFailedView : UIView <UIWebViewDelegate>

@property (nonatomic, weak) id<WebViewFailedViewDelegate> delegate;

@end

#pragma mark - 

@protocol WebViewFailedViewDelegate <NSObject>

- (void)onRefresh;

@end

