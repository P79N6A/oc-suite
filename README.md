# 说明

## 集成

* [This block declaration is not a prototype.]
    - Build Setting -> Warnings (All languages) -> Strict Prototypes -> NO
* [Too many arguments to function call, expected 0, have 3]
	- Build Setting -> Preprocessing -> Enable Strict Checking of objc_msgSend Call -> NO
* [BITCODE link error]
	- Build Setting -> Build Options -> Enable Bitcode -> NO
* MRC
    - 添加 '-fno-objc-arc'
    - RACQueueScheduler.m, RACBacktrace.m, RegexKitLite.m, RACTargetQueueScheduler.m, RACObjCRuntime.m

## [_Foundation 基础](_Foundation/README.md)

* 依赖的系统库
	- licucore.tbd

## [_Modular 模块](_Modular/README.md)

## [_Tool 工具](_Tool/README.md)

## [_Building 集成](_Building/README.md)

## [_Components UI组件](_Components/README.md)

## [_Modules 模块组件](_Modules/README.md)

## [_Midware 中间层](_Midware/README.md)

## [_Hybrid 混合](_Hybrid/README.md)

* 依赖的系统库
    - WebKit.framework
    - JavaScriptCore.framework

## [_Monitor 监控](_Monitor/README.md)

## [_Test 测试](_Test/README.md)

## [_Support 其他能力支持](_Support/README.md)

