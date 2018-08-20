# 中间层

*起源*

我们认为，应该严格分开（Buiding: MVC、MVVM、VIPER）与（Modules: Application、Component、Service），在他们之间，有面向接口的中间层设计。在这里，我们将前者称之为视图开发架构风格，将后者称之为客户端整体架构分层，且该理论只适用于大型应用开发，中小型应用开发不应该出现后者。

*标记*
- [x] 已实现
- [ ] 未实现

### 开发

1. 接口定义在intf文件夹中
2. 接口实现在impl文件夹中
3. 依赖库的预编译宏处理，可依据宏判断，是否使用了某个特定的三方库：ALSportsPrecompile.h
4. 允许暴露实现，比如创建特定的分类，给外部使用：ALSportsPredefine.h
5. 接口与实现的对接，预置的内容在：ALSportsConfig，外部可适时替换

### 移植

1. 仅限于Objective-C语言
2. 引入工程，确保没有编译错误（绝壁没有！）
3. 配置实现库：ALSportsPrecompile.h
4. 编写实现代码：impl文件夹

## 基础 分解

### 协议基类

- [ ] 是否已经实现

### 数组下标

- [x] object[0]

### 字典下标

- [x] object[@"key"]

### 应用生命周期观察

- [x] onLaunch

### 可加载（加载时期非常靠前）

- [x] onLoad

### 模块化 （试水）

- [x] 模块描述

## 工具 分解

###  网络层
- [x] 常规接口
- [ ] 上传、下载接口
- [ ] Command模式的request请求，请求取消与管理
- [x] 环境切换

* 接口：
    - ALSNetworkProtocol
* 实现：
    - ALSNetworkImpl

### 序列化
- [x] JSON字符流 -> OC对象

* 接口：
    - ALSerializationProtocol
* 实现：
    - ALSerializationImpl

### 内置浏览器
- [ ] 网页访问
- [ ] JS注册与回调
- [ ] 右上角按钮扩展
- [ ] 其他扩展性（标题从JS获取、隐藏导航栏等）

* 接口：
    - ALSBrowserProtocol
* 实现：
    - ALSBrowserImpl

### 图片加载（包括图片缓存）
- [ x] 加载图片
- [ ] 图片固定URL更新
- [x ] 上传图片

* 接口：
    - ALSImageLoaderProtocol
* 实现：
    - ALSImageLoaderImpl

### 缓存（离散的数据，对象）
- [ ] 单条目 CUDA
- [ ] 对象更新通知
- [ ] 下标方式存取
- [ ] ？？？

* 接口：
    - ALSCacheProtocol
* 实现：
    - ALSCacheImpl
    
### 日志

- [ ] ???

## 通用业务 分解

### User

- [x] UUID
- [x] Token

### Error

- [x] Message
- [x] 工厂

### AppContext

- [x] 应用加载完毕 [埋点]
- [x] 应用主功能加载完毕 [埋点]

### 支付

- [x] 应用内支付

### 页面跳转 Segue

- [ ] ???

### 分享

- [x] 微信、QQ、新浪 Share
- [x] 分享门面 Shares
- [x] 分享key, secret, scheme配置
- [x] 分享参数


