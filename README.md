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
* [提供模块机制](_Foundation/Modular/README.md)

## [_Tool 工具](_Tool/README.md)

* 依赖的框架
	- _Foundation

## [_Building 集成](_Building/README.md)

* 依赖的框架
	- _Foundation

## [_Components UI组件](_Components/README.md)

* 依赖的框架
	- _Foundation
	- _Building

## [_Modules 模块组件](_Modules/README.md)

* 依赖的框架
	- _Foundation
	- _Building
	- _Tool

## [_Hybrid 混合](_Hybrid/README.md)

* 依赖的系统库
  - WebKit.framework
  - JavaScriptCore.framework

## [_Monitor 监控](_Monitor/README.md)

* 依赖的框架
	- _Foundation
	- _Tool

## [_Test 测试](_Test/README.md)

* 依赖的框架
	- _Foundation

## qy的iOS框架设计解读

* 业务模块 _Building/Architect 未完成
	- 页面
	- 数据模型
		> 原始模型
		> 业务模型
		> 试图模型
	- 数据源
	- 页面控制器
	- 动态部署
* 应用基础模块
	- Hybrid _Hybrid, _Modules/Components/WebBrowser 未完成
		> 页面交互
		> JS交互
	- 用户体验 ??????? 空缺
		> 皮肤/外观
		> 字体
	- 应用能力 _Modules/Components,Services/Login, _Modules/Components,Services/Share, _Modules/Components,Services/Pay
		> 登录
		> 分享
		> 支付
	- 页面路由 _Modular/Router
		> 静态路由
		> 动态路由
* 通用基础模块 
	- 数据 _Tool/Network, _Tool/Network-lit, _Tool/Database, _Tool/Cache
		> 网络
		> 本地
	- 多媒体 _Tool/Media ???? 未迁移
		> 音频
		> 视频
		> 富文本 ?????? 空缺
	- 通用工具 _Tool/Utility
	- 自定义视图 _Building/UI, _Components
	- 测试 _Test
		> 自动化
		> 单元测试
	- 数据分析 _Monitor 未完成 / ???? 是否将日志整合呢？？？
		> 统计
		> 日志

* 交互模块 _Building/UI, _Building/Core, _Building/Animation
	- 视觉
		> 动效
		> 渲染
	- 事件
		> 交互控制器
		> 响应链
		- "原先想法是把交互事件（比如点击、手势等）管理起来，让原生和H5页面无缝链接，还有对原生交互事件的分发，省去写touchtest的代码"
		- 给 touchBegin hit test 相关方法，封装一些语法糖

