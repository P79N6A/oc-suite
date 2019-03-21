# 日志管理

该库不依赖其他同等功能的日志库

## 开发痛点

* 每次测试出bug时都要把手机插入电脑查看日志? 等你联机调试时返回的数据已经变了? 到底是不是服务端的数据问题? 
* 经常被一大堆不关心的日志刷屏感到烦躁? 只想查看某类日志却只能在一大堆日志中搜索? 
* 日志分级:每条日志的重要性一样吗? 能否只查看某些重要的日志? 
* 只有系统的crash日志是不是很难分析出bug原因? 
* 想打印NSLog所在文件和函数名但是有时候又觉得太罗嗦? 
* 查看、下载手机的文件需要链接xcode很麻烦？ 

## 功能

* 日志重定向
	- 支持日志控件，在app直接查看日志
* 日志过滤
	- 按源文件域过滤
	- 按函数域过滤
	- 按正则表达式过滤
* crash分析
* 日志信息化简

## 设计思路:
-  AriderLogManager作为管理者,管理数据对象,视图显示,日志截获等.
-  AriderLogComponetView显示整个组件界面里面包含日志显示,日志过滤,设置等视图.
-  将NSLog宏等替换成目标宏从而从Lumberjack底层组件获取日志流
-  AriderLogFormatter作为日直流处理者,在formatLogMessage回调里里对日志流进行收集信息,过滤日志,格式化日志等操作.
-  最终将处理过的日志显示到视图.
-  提供可扩展的接口，能够增加自定义的功能。可使用insertFunctiontWithTitle:view:atIndex:添加一个功能项

使用:
----------
* 在.pch或头文件中import头文件，或者复制 以下头文件里的宏代码放入你的头文件（避免强赖）。
* 方式1：强依赖ALog：
	* `#import "ALog.h"`
* 方式2：弱依赖ALog
	* `#import "ALog+Runtime.h"`
* 方式3：Debug版使用ALog，Release版使用TLog：
	* `#import "ALog+TLog.h"`

* 在`[application:didFinishLaunchingWithOptions:]`中添加` [AriderLogManager setup]`
* 增加功能: 如增加一个环境设置的view (view里面的逻辑跟具体业务相关,所以当然得自己写)

```
[AriderLogManager sharedManager] insertFunctiontWithTitle:@"环境" view:view atIndex:[AriderLogManager sharedManager].functionCount];

    NSLog(@"didFinishLaunchingWithOptions1");
//#if (ALOG_SET_MODE == 1)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AriderLogManager setup];
    });

    [[AriderLogManager sharedManager] writeSysLogIntoFile];
//    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
//    [AriderLogManager sharedManager].loggoWindow.center = self.window.center;
//#endif
    NSLog(@"didFinishLaunchingWithOptions2");
    ALogInfoSync(@"aaa,bbb");    
//    [[AriderLogManager sharedManager] insertFunctiontWithTitle:@"环境" view:[UIView new] atIndex:0];
//    [[AriderLogManager sharedManager] insertFunctiontWithTitle:@"启动" view:[UIView new] atIndex:0];
//    [[AriderLogManager sharedManager] insertFunctiontWithTitle:@"ABTest" view:[UIView new] atIndex:0];
//    [[AriderLogManager sharedManager] insertFunctiontWithTitle:@"hotpatch" view:[UIView new] atIndex:0];
//    [[AriderLogManager sharedManager] insertFunctiontWithTitle:@"测试AB" view:[UIView new] atIndex:0];
//    [[AriderLogManager sharedManager] insertFunctiontWithTitle:@"测试测试" view:[UIView new] atIndex:0];
    [[AriderLogManager sharedManager] showFunctionAtIndex:0];
    for(int i = 0; i < 1; ++i){
        ALogError(@"error error");
        ALogWarn(@"warn warn %f", 123.45);
        ALogInfo(@"info info");
        ALogVerbose(@"Verbose Verbose");
        ALogDebug(@"this is debug %f", 123.45);
        NSLog(@"test nslog");
    }
    NSLog(@"aaa");
    [AppDelegate testClassMethod];
//    testCFunction(10);
    TestLogViewController *vc = [[TestLogViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

    self.window.rootViewController = vc;

    ALogInfo(@"nihao %@ , my age is %d", @"luacy", 18);
    ALogVerbose(@"nihao verbose %@ , my age is %d", @"luacy", 18);
    
```
注意：
View的Frame可以通过[[AriderLogManager sharedManager] frameForFunctionView]获取。  
如果你的模块只在debug用，则可以静态依赖，否则请用动态调用，因为ALog在Release版会去掉。  
ALog模块为通用库，不添加业务代码，如果需要业务定制，则请使用ALogBundle。  

* 打印日志:

```
ALogDebug(@"this is debug");
ALogWarn(@"this is warning");
ALogInfo(@"this is info:%@", self);
ALogError(@"xxx error %@", self);   
```	


注意:
----------
-  [AriderLogManager setup]要放在打印日志的代码前.否则setup之前的日志会被屏蔽调
-  framework里的日志无法被过滤或关闭
-  日志文件有两份:1.默认关闭了写文件，若需要请设置`isWriteLogIntoFile=YES` 2.非联机时所有的日志都会写入alog_的文件,若crash时打印了日志那么也会保留在此文件. 3.调用ALog方法打印的日志存在Cache/Logs,里面包含了该日志的所在文件、方法、代码行等信息。
-  若在iOS9会启动即出现crash,请将setup初始化延迟,如

```
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AriderLogManager setup];
    });
```