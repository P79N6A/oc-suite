//
//  _web_service.m
//  student
//
//  Created by fallen.ink on 08/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_web_service.h"

@implementation _WebService

@def_singleton( _WebService )

#pragma mark -

// 还没有整理
- (void)clearAllUIWebViewData {
    // Clear the webview cache...
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self removeApplicationLibraryDirectoryWithDirectory:@"Caches"];
    [self removeApplicationLibraryDirectoryWithDirectory:@"WebKit"];
    
    // Empty the cookie jar...
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    [self removeApplicationLibraryDirectoryWithDirectory:@"Cookies"];
}

- (void)removeApplicationLibraryDirectoryWithDirectory:(NSString *)dirName {
    NSString *dir = [[[[NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) lastObject] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:dirName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
}

////////////////
- (void)clearCache {
    // [删除WKWebView的缓存](http://blog.csdn.net/amateur__7/article/details/49658193)
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                               NSUserDomainMask, YES)[0];
    NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                            objectForKey:@"CFBundleIdentifier"];
    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
    NSString *webKitFolderInCaches = [NSString
                                      stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
    NSString *webKitFolderInCachesfs = [NSString
                                        stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    
    NSError *error;
    /* iOS8.0 WebView Cache的存放路径 */
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
    
    /* iOS7.0 WebView Cache的存放路径 */
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
    
    // [清除UIWebView的缓存](https://www.cnblogs.com/wobuyayi/p/5647634.html)
    
    // 清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    // 清除webView的缓存
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
        
#if 0
        if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0){
            
            NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                            WKWebsiteDataTypeDiskCache,
                                                            WKWebsiteDataTypeOfflineWebApplicationCache,
                                                            WKWebsiteDataTypeMemoryCache,
                                                            WKWebsiteDataTypeLocalStorage,
                                                            WKWebsiteDataTypeCookies,
                                                            WKWebsiteDataTypeSessionStorage,
                                                            WKWebsiteDataTypeIndexedDBDatabases,
                                                            WKWebsiteDataTypeWebSQLDatabases
                                                            ]];
            
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                       modifiedSince:dateFrom completionHandler:^{
                                                           // code
                                                       }];
            
        } else {
            //清除cookies
            NSHTTPCookie *cookie;
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (cookie in [storage cookies]) {
                [storage deleteCookie:cookie];
            }
            
            //清除UIWebView的缓存
            NSURLCache * cache = [NSURLCache sharedURLCache];
            [cache removeAllCachedResponses];
            [cache setDiskCapacity:0];
        }
#endif
}

@end
