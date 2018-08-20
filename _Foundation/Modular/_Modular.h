

// ----------------------------------
// MARK: -
// ----------------------------------

#import "_Foundation.h"

#import "_Watcher.h"

#import "_Module.h"
#import "_ModuleLoader.h"

#import "_Service.h"
#import "_ServiceManager.h"

#import "_Component.h"
#import "_ComponentLoader.h"


// 有待研究
// 1. https://github.com/fallending/Modular
// 2. https://github.com/alibaba/BeeHive, 这里重要的概念，就是注解
// 3. https://github.com/wujunyang/jiaModuleDemo, 写的比较详细
// 4. https://github.com/facebook/buck
// 5. https://github.com/fulldecent/swift3-module-template, 工程工具

// ----------------------------------
// 所有功能，两个体系
// app.xxxx, 专注于离散式, 但其实现在building里面
// suite.xxxx, 专注于模块式
// ----------------------------------

@namespace( logger, _Logger )
@namespace( debugger, _Debugger )
@namespace( device, _Device )

