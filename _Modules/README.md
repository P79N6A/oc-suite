# suite.building

基于框架之上的代码构件案例与指导

### 系统库 依赖

- Accelerate.framework
- CFNetwork.framework
- CoreFoundation.framework
- ImageIO.framework
- AVFoundation.framework
- CoreImage.framework
- SystemConfiguration.framework
- MobileCoreServices.framework
- AssetsLibrary.framework
- Photos.framework
- CoreMotion.framework
- AddressBook.framework
- MapKit.framework
- CoreMedia.framework
- EventKit.framework
- CoreText.framework
- CoreBluetooth.framework
- MediaPlayer.framework
- MessageUI.framework

- libz.tbd
- libstdc++.6.0.9.tdb
- libxml2.tbd
- libsqlite3.0.tbd
- libicucore.tbd

### base

基础类，用于架构分层、基础模块使用的基类

### architect

不同的架构风格参考

### application

应用，以及应用上下文等概念抽象

### service

核心服务组件

### component

可复用业务组件、独立业务组件，两者使用同样的抽象

### convenience

便利性代码案例

### dao

TODO：数据层往下，尝试函数式，流式处理
```
    client.POST(^(){ // 提交请求
        return [Reqeust requestWith:...];
    }).networkChanged(^(NetworkStatus status){ // 网络状态更新
        // 如果是图片，在非WIFI网络，则让用户产生选择，并在UserConfigModel层，缓存起来
        // 如果是视频，同上
    }).reconnectCount(^(BOOL networkBroken){ // 重连设置
        if (networkBroken) return 0;
        else return 3;
    }).response(^(NSDictionary *data, NSError *error){ // 应答处理

    }).enableCache();
```

1. dao层
    - 用宏或者注解完成api可配置
    ```
    @api(root_test, @"root/test")
    // 1. 可以统计api数目
    // 2. 可以全览api请求频次, 失败频次，平均时间，数据包大小等
    ```
    - 
2. 网络层
    
