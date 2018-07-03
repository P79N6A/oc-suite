//
//  BaseWebTextView.h
//  student
//
//  Created by fallen.ink on 11/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//
//  用TextView显示html，比UIWebView更加轻量级，适合图文

#import <UIKit/UIKit.h>

@interface BaseWebTextView : UITextView

/***/
+ (instancetype)instanceWithHtmlString:(NSString *)htmlString;

@end
