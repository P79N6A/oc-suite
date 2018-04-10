//
//  WebSampleVC.h
//  startup
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import <UIKit/UIKit.h>

// iOS: UIWebView 中不加载图片（即浏览器常见的无图模式）: https://www.cnblogs.com/yoon/p/4776572.html
// 在UIWebView中加载本地图片 : http://blog.csdn.net/zhangao0086/article/details/7262192
// UIWebView保存图片 : http://www.cocoachina.com/ios/20160616/16660.html
// iOS WebView 图片点击放大并左右滑动,类似微信/网易文章功能 : http://blog.csdn.net/q644419002/article/details/77980130

// 详解iOS webview加载时序和缓存问题总结 : http://www.jb51.net/article/123152.htm
// iOS webView预加载 : http://blog.csdn.net/amlijlybo/article/details/51841312
// 让UIWebview拥有超强的图片处理能力 : http://www.cocoachina.com/ios/20161027/17867.html

// WebView中实现延迟加载，图片点击时才加载。: https://www.cnblogs.com/zhengxt/p/4304625.html
// iOS webview懒加载html数据 ： https://www.jianshu.com/p/a5c7f9fa70f5

@interface WebSampleVC : UIViewController

/**
 针对很多图的网页数据
 
 - UIWebView：加载 url，速度慢；加载 content，速度更慢
 - UITextView：加载content，速度和加载url，差不多，占用主线程。
 - WKWebView：加载content，速度慢；好在，它在开始加载时能获取 文字 高度；加载完毕后，获取完整高度（但 UIWebView 没有这个功能）
 
 - 这都是native方案，js方案不是首选，不过可以让体验再度提升。
*/

@end
