//
//  UIWebView+JS.m
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 14/12/22.
//  Copyright (c) 2014年 duzixi. All rights reserved.
//

#import "_precompile.h"
#import "UIWebView+JavaScript.h"
#import "UIColor+Web.h"

@implementation UIWebView ( JavaScript )

#pragma mark - 获取网页中的数据

- (int)nodeCountOfTag:(NSString *)tag {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('%@').length", tag];
    int len = [[self stringByEvaluatingJavaScriptFromString:jsString] intValue];
    return len;
}

- (NSString *)getCurrentURL {
    return [self stringByEvaluatingJavaScriptFromString:@"document.location.href"];
}

- (NSString *)getTitle {
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSArray *)getImages {
    NSMutableArray *arrImgURL = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].src", i];
        [arrImgURL addObject:[self stringByEvaluatingJavaScriptFromString:jsString]];
    }
    return arrImgURL;
}

- (NSArray *)getOnClicks {
    NSMutableArray *arrOnClicks = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self nodeCountOfTag:@"a"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('a')[%d].getAttribute('onclick')", i];
        NSString *clickString = [self stringByEvaluatingJavaScriptFromString:jsString];
        NSLog(@"%@", clickString);
        [arrOnClicks addObject:clickString];
    }
    return arrOnClicks;
}

#pragma mark - 改变网页样式和行为

- (void)setBackgroundColor:(UIColor *)color {
    NSString * jsString = [NSString stringWithFormat:@"document.body.style.backgroundColor = '%@'",[color webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)addClickEventOnImg {
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        //利用重定向获取img.src，为区分，给url添加'img:'前缀
        NSString *jsString = [NSString stringWithFormat:
                              @"document.getElementsByTagName('img')[%d].onclick = \
                              function() { document.location.href = 'img' + this.src; }",i];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}

- (void)setWebViewHtmlImageFit {
    NSString *jsStr = [NSString stringWithFormat:@"var script = document.createElement('script');"
                       "script.type = 'text/javascript';"
                       "script.text = \"function ResizeImages() { "
                           "var img;"
                           "for(i = 0; i < document.images.length; i++){"
                               "img = document.images[i];"
                               "img.style.width = '100%%';"
                               "img.style.height = 'auto';"
                           "}"
                       "}\";"
                       "document.getElementsByTagName('head')[0].appendChild(script);"];
    [self stringByEvaluatingJavaScriptFromString:jsStr];
    [self stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
}

- (void)setImgWidth:(int)size {
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].width = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.width = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}

- (void)setImgHeight:(int)size {
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].height = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.height = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}

- (void)setFontColor:(UIColor *)color withTag:(NSString *)tagName {
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.color = '%@';}", tagName, [color webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)setFontSize:(int)size withTag:(NSString *)tagName {
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.fontSize = '%dpx';}", tagName, size];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)loadHtmlWithTextFirst {
    /**
     1. imageParentNodeStyleFilter 去掉图片的首行缩进
     2. isValidPic 判断img元素dom是否为合法图片
     */
    NSString *jsString = [NSString stringWithFormat:
                        @"var tryTimes = 0;\
                          var maxTryTimes = 6;\
                          function replaceImageDomUseDefault () {\
                              if (tryTimes==0) {\
                                  imageParentNodeStyleFilter();\
                              }\
                              if (tryTimes>=maxTryTimes) {\
                                  return;\
                              }\
                              var imageDoms = document.getElementsByTagName(\"img\");\
                              for (var i = 0; i<imageDoms.length; i++) {\
                                  var imageDom = imageDoms[i];\
                                  imageHandler(imageDom);\
                              }\
                              tryTimes++;\
                              setTimeout(arguments.callee, 1000);\
                          }\
                          function imageParentNodeStyleFilter() {\
                              var imageDoms = document.getElementsByTagName(\"img\");\
                              for (var i = 0; i<imageDoms.length; i++) {\
                                  var imageDom = imageDoms[i];  \
                                  if(imageDom.parentNode) {  \
                                      var parentDom = imageDom.parentNode;\
                                      parentDom.style.textIndent = 0;  \
                                  }  \
                              }  \
                          }  \
                          function imageHandler (imageDom) {\
                              if(isValidPic(imageDom)) {  \
                                  imageDom.src = imageDom.getAttribute(\"_src\");\
                                  return;  \
                              }  \
                          }  \
                          function isValidPic(dom){\
                              var img = new Image();\
                              img.src = dom.getAttribute(\"_src\");\
                              if(img.width > 0 && img.height > 0){  \
                                  return true;  \
                              }  \
                              return false;\
                          }"];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

- (CGFloat)getHtmlHeight {
    // WebView 高度自适应
    self.frame = CGRectMake(0, 0, screen_width, 1);
    
    return [[self stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue] + 30;
}

#pragma mark - 删除

- (void )deleteNodeByElementID:(NSString *)elementID {
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('%@').remove();",elementID]];
}

- (void)deleteNodeByElementClass:(NSString *)elementClass {
    NSString *javaScriptString = [NSString stringWithFormat:@"\
                                  function getElementsByClassName(n) {\
                                  var classElements = [],allElements = document.getElementsByTagName('*');\
                                  for (var i=0; i< allElements.length; i++ )\
                                  {\
                                  if (allElements[i].className == n) {\
                                  classElements[classElements.length] = allElements[i];\
                                  }\
                                  }\
                                  for (var i=0; i<classElements.length; i++) {\
                                  classElements[i].style.display = \"none\";\
                                  }\
                                  }\
                                  getElementsByClassName('%@')",elementClass];
    [self stringByEvaluatingJavaScriptFromString:javaScriptString];
}

- (void)deleteNodeByTagName:(NSString *)elementTagName {
    NSString *javaScritptString = [NSString stringWithFormat:@"document.getElementByTagName('%@').remove();",elementTagName];
    [self stringByEvaluatingJavaScriptFromString:javaScritptString];
}

@end
