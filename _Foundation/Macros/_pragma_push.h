#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wunreachable-code"
#pragma clang diagnostic ignored "-Wunused-function"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-member-function"
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wshadow-ivar"
#pragma clang diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#pragma clang diagnostic ignored "-Wdeprecated"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//  When it marks any one of the init-family methods in a class's declaration, all other initializers are considered "secondary" (to use Apple's terminology) initializers. That is, they should call through to one another designated or secondary initializer until they reach a designated initializer.
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma clang diagnostic ignored "-Wdeprecated"
#pragma clang diagnostic ignored "-Wnonnull" // 类似[Wnonnull]这样的警告, 在工程buildSettings中的Other Warning Flags中添加 -Wno-nonnull就可以去掉这种类似的警告了, 规则为：-Wno-类型
#pragma clang diagnostic ignored "-Wstrict-prototypes" // 忽略 ‘This block Declaration is not a prototype’ 警告


// ----------------------------------
// 1. CocoaPods禁止显示警告inhibit_all_warnings
// @preference http://blog.csdn.net/thanklife/article/details/45476457
// @example pod 'ReactiveCocoa', '~> 2.1', :inhibit_warnings => true
// @example 2
// ```
// link_with 'SecondHouseBrokerAPP','SecondHouseBrokerCOM'
// platform :ios,'6.0'
// inhibit_all_warnings!
// ```
// ----------------------------------

// ----------------------------------
// 2. 如何移除 iOS 第三方库烦人的警告信息
//
// 打开命令行，移动到库文件所在目录，输入如下命令: (注意替换实际要处理的库文件名)
// ```
// strip -S libGeTuiSdk.a
// ```
//
// 如果是 .framework 打包的静态库，可以这样写:
// ```
// strip -S Alipay.framework/Alipay
// ```
// ----------------------------------

