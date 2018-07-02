# suite.module-x
oc framework 之 modular 

### 分层

1. 应用（application）
2. 组件（component）
3. 服务（service）

### 组合

1. 组件间管理和通信：compoent+mediator
2. 组件独立运行：component+docker
3. 组件更新：component+automodule+watcher（难产）
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
