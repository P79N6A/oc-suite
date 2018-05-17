# oc-startup

iOS app startup with oc-foundation, oc-modules, oc-debug, oc-hybrid

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

### oc-foundation

### oc-modules

* 依赖的系统库
	- licucore.tbd

### oc-debug

### oc-hybrid

* 依赖的系统库
    - WebKit.framework
    - JavaScriptCore.framework
