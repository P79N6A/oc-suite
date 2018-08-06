# oc-foundation

Reference：(Thanks & がんばって<罗马音：ganbatte 中文近似读音：gan ba dei>)

* [hackers-painters/samurai-native](https://github.com/hackers-painters/samurai-native), 很有趣，“黑客与画家”，Joe Zhou named this orgnization “二进制艺术家”, Cheers。
* [shaojiankui/JKCategories](https://github.com/shaojiankui/JKCategories)

----------
### 文件

1. foundation - 基础
    * 类加载
    * 容器的安全访问
    * 调试
    * 编码
    * 异常
    * 键值观察
    * 命名空间
    * 通知
    * 性能
    * 属性定义
    * 协议预定义
    * 运行时处理
    * 单例辅助类
    * 字符串生成器
    * 方法交换
    * 线程类
    * 定时器
    * 校验
    * 拦截器
2. macros - 宏
    * appdef.h - 应用
    * availability.h - 
    * coderdef.h - 归档
    * colordef.h - 颜色
    * commentdef.h - 注释
    * configdef.h - 全局配置
    * constdef.h - 常量
    * devicedef.h - 设备
    * fontdef.h - 字体
    * ocdef.h - oc语言
    * pragma_push.h, pragma_pop.h - 忽略特定警告
    * stringdef.h - 字符串
    * systemdef.h - 系统
    * threaddef.h - 线程
    * typedef.h - 类型预定义
    * uidef.h - UI
3. system - 系统
    * archiver - 归档
    * keychain - 钥匙串
    * assert - 断言 
    * error - 错误
    * localization - 本地化
    * log - 日志
    * sandbox - 沙箱
    * device - 设备信息
    * task - 任务
    * unitest - 测试
5. 资源：枚举所有的警告内容
6. 支持：block使用集、声明式响应式处理、状态机、类型相关的信号处理

引用：
	[软件架构入门](http://www.ruanyifeng.com/blog/2016/09/software-architecture.html)

----------
### 反人类的代码风格

	> 大部分文件，均为小写字母命名文件。
	> 很大可能重名的文件，以下划线开头。

结论：它注定不会被他人使用，😄，然而为什么会写成这样？

	> 厌烦各种前缀缩写，于是有了"_"
	> "_" 加上驼峰在文件名上，很难看，于是就："_ui_core.h"，而类名：_Namespace
    > 那么，主框架内：
    >> 类名：_ClassName
    >> 内部方法名：__methodName
    >> 外部方法名：methodname
    >> 全局变量：禁止，用宏替换，单例等
    >> 属性名：propertyName
    >> 文件名：_file_name.h
    >> 宏定义：动作类：macro_operation( _name_ )，环境变量类：MACRO_ENV (我更偏向于全小写，想想巧办法)

引用：
	[为什么文件名要小写？](http://www.ruanyifeng.com/blog/2017/02/filename-should-be-lowercase.html)

语言元素命名规则建议：

    > 协议命名：代理模式下, XXXXDelegate；接口定义下：XXXXProtocol
    > 还没有添加，需要将_def.h中的清理出来，整理并规范

----------
### TODO
* [PonyCui/PPEtcHosts](https://github.com/PonyCui/PPEtcHosts)，应用内实现域名Host绑定，开发利器。
* [iOS单元测试：Specta + Expecta + OCMock + OHHTTPStubs + KIF](http://blog.csdn.net/colorapp/article/details/47007431)
* [JxbDebugTool](https://github.com/JxbSir/JxbDebugTool), 一个iOS调试工具，监控所有HTTP请求，自动捕获Crash分析。
* [A/B test search](https://github.com/search?l=Objective-C&q=a%2Fb+testing&ref=searchresults&type=Repositories&utf8=✓)

----------
## 问题

1. 案子1: [iOS在App中打开设置中的指定模块](https://www.jianshu.com/p/2e31fcc728b5)

```
被拒绝理由：
Your app uses the "prefs:root=" non-public URL scheme, which is a private entity. The use of non-public APIs is not permitted on the App Store because it can lead to a poor user experience should these APIs change.

Continuing to use or conceal non-public APIs in future submissions of this app may result in the termination of your Apple Developer account, as well as removal of all associated apps from the App Store.

Next Steps

To resolve this issue, please revise your app to provide the associated functionality using public APIs or remove the functionality using the "prefs:root" or "App-Prefs:root" URL scheme.

If there are no alternatives for providing the functionality your app requires, you can file an enhancement request.
```

```
相关代码，已经删除：
/**
 About — prefs:root=General&path=About
 Accessibility — prefs:root=General&path=ACCESSIBILITY
 Airplane Mode On — prefs:root=AIRPLANE_MODE
 Auto-Lock — prefs:root=General&path=AUTOLOCK
 Brightness — prefs:root=Brightness
 Bluetooth — prefs:root=General&path=Bluetooth
 Date & Time — prefs:root=General&path=DATE_AND_TIME
 FaceTime — prefs:root=FACETIME
 General — prefs:root=General
 Keyboard — prefs:root=General&path=Keyboard
 iCloud — prefs:root=CASTLE
 iCloud Storage & Backup — prefs:root=CASTLE&path=STORAGE_AND_BACKUP
 International — prefs:root=General&path=INTERNATIONAL
 Location Services — prefs:root=LOCATION_SERVICES
 Music — prefs:root=MUSIC
 Music Equalizer — prefs:root=MUSIC&path=EQ
 Music Volume Limit — prefs:root=MUSIC&path=VolumeLimit
 Network — prefs:root=General&path=Network
 Nike + iPod — prefs:root=NIKE_PLUS_IPOD
 Notes — prefs:root=NOTES
 Notification — prefs:root=NOTIFICATIONS_ID
 Phone — prefs:root=Phone
 Photos — prefs:root=Photos
 Profile — prefs:root=General&path=ManagedConfigurationList
 Reset — prefs:root=General&path=Reset
 Safari — prefs:root=Safari
 Siri — prefs:root=General&path=Assistant
 Sounds — prefs:root=Sounds
 Software Update — prefs:root=General&path=SOFTWARE_UPDATE_LINK
 Store — prefs:root=STORE
 Twitter — prefs:root=TWITTER
 Usage — prefs:root=General&path=USAGE
 VPN — prefs:root=General&path=Network/VPN
 Wallpaper — prefs:root=Wallpaper
 Wi-Fi — prefs:root=WIFI
 */

- (void)openSettings {
    if (IOS8_OR_LATER) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        NSURL *url = [NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)openWIFI {
    if (IOS8_OR_LATER) {
        //        NSURL *url = [NSURL URLWithString:UIApplicationOpen];
        //        if ([[UIApplication sharedApplication] canOpenURL:url]) {
        //            [[UIApplication sharedApplication] openURL:url];
        //        }
    } else {
        NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
```
