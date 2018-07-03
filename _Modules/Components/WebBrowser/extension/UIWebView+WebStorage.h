//
//  UIWebView+JKWebStorage.h
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 2016/12/14.
//  Copyright © 2016年 www.skyfox.org. All rights reserved.
//  https://github.com/cprime/UIWebView-WebStorage

#import <UIKit/UIKit.h>

@interface UIWebView (JKWebStorage)
#pragma mark - Local Storage

- (void)setLocalStorageString:(NSString *)string forKey:(NSString *)key;

- (NSString *)localStorageStringForKey:(NSString *)key;

- (void)removeLocalStorageStringForKey:(NSString *)key;

- (void)clearLocalStorage;

#pragma mark - Session Storage

- (void)setSessionStorageString:(NSString *)string forKey:(NSString *)key;

- (NSString *)sessionStorageStringForKey:(NSString *)key;

- (void)removeSessionStorageStringForKey:(NSString *)key;

- (void)clearSessionStorage;

@end
