# Modular

### 分层

1. 应用（Application）
2. 组件（Component）
2-3. 中间件 (Mediator) (Docker)
3. 服务（Service）

### 组合

1. 组件间管理和通信：Compoent+Mediator
2. 组件独立运行：Component+Docker
3. 组件更新：Component+Automodule+Watcher（难产）
4. 组件测试：（难产）

### 组件设计

1. 特性
    * 插件式管理
    * 模块生命周期管理
    * 万能路由
    * 尝试解决异构化问题：native, html, ironic, weex...

2. 设计原则

3. 事件
    * 系统事件
    * 通用事件
    * 业务自定义事件

## 其他

1. 数据访问：service+dao
2. 数据缓存：data ’s Screen State、 Session State、 Record State

## 参考

1. Samurai-native
2. BeeHive

## 其他推荐方案

1. [Small](https://github.com/BinaryArtists/Small)
2. 

## 研究过的方案

1. [meili/MGJRouter](https://github.com/meili/MGJRouter)
2. [JDongKhan/JDRouter](https://github.com/JDongKhan/JDRouter)
3. [IOS-组件化架构漫谈](https://www.cnblogs.com/oc-bowen/p/5885476.html)
	* 主要提出了 组件化架构 解决业务模块复杂化、团队协作开发复杂化的痛点
	* 尝试提出了 组件设计与封装、组件间通信 的自家方案
		- 组件路由：MGJRouter
			> 短链管理： web页面统一来管理所有的URL和参数，Android和iOS都使用这一套URL，可以保持统一性
		- 组件通信：入参（URL params）
		- 组件管理：ModuleManager
			> 在ModuleManager内部维护一张映射表，映射表由之前的"URL -> block"变成"Protocol -> Class"
			> [ModuleManager registerClass:MGJUserImpl forProtocol:@protocol(MGJUserProtocol)];
