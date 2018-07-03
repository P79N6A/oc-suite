# John

*个人意见*
* 单元测试，优选BDD框架，可读性高一些，推荐Quick（Swift），Kiwi(Objective C)
* UI测试，优选KIF，如果需要兼顾安卓测试，或者测试人员对OC/Swift很陌生，可以采用appium

## 分类

* mock 表示一个模拟对象
* stub 追踪方法的调用，在方法调用的时候返回指定的值

### Mocking

当你把一个整体拆分成小零件（即更小的类）时，我们可以在每个类中进行测试。但由于我们测试的类会和其他类交互，这里我们用一个所谓的 mock 或 stub 来绕开它。把 mock 对象看成是一个占位符，我们测试的类会跟这个占位符交互，而不是真正的那个对象。这样，我们就可以针对性测试，并且保证不依赖于应用程序的其他部分。

*Partial mocks*
Partial mocks 会修改 mocking 的对象，并且在 mocks 的生存周期一直有效。你可以通过提前调用[aMock stopMocking] 来停止这种行为。大多数时候，你希望 partial mock 在整个测试期间都保持有效。确保在测试方法最后放置[aMock verify]。否则 ARC 会过早 dealloc 这个 mock。而且不管怎样，你都希望加上 -verify。

## 实践

### 并发测试 - CONCTEST

并发队列
```
CONCTEST *test = [CONCTEST concurrentInstance];
    
[test enqueue:^{
    TLOG(@"CONCTEST 1");
} times:4];

[test enqueue:^{
    TLOG(@"CONCTEST 2");
} times:1];

[test enqueue:^{
    TLOG(@"CONCTEST 3");
} times:2];

[test enqueue:^{
    TLOG(@"CONCTEST 4");
} times:6];

[test enqueue:^{
    TLOG(@"CONCTEST 5");
} times:8];

[test start];
```

串行队列
```
CONCTEST *test = [CONCTEST serialInstance];
    
[test enqueue:^{
    TLOG(@"CONCTEST 1");
} times:4];

[test enqueue:^{
    TLOG(@"CONCTEST 2");
} times:1];

[test enqueue:^{
    TLOG(@"CONCTEST 3");
} times:2];

[test enqueue:^{
    TLOG(@"CONCTEST 4");
} times:6];

[test enqueue:^{
    TLOG(@"CONCTEST 5");
} times:8];

[test start];
```

### 性能测试 - PERFTEST

同步过程
```
PERF_TIME({
            for (int i = 0; i < 10000; i ++) {
                NSLog(@"dddddddddddddddddddddddd");
            }
        });
```

异步过程
```
PERFTEST {
	- (void)enter:(NSString *)tag;
	- (void)leave:(NSString *)tag;
}
```

系统方法
```
[self measureBlock:^{
        
    for (int i = 0; i < 10000; i ++) {
        NSLog(@"dddddddddddddddddddddddd");
    }

}];
```

### 接口Mock

```
    /**
     mock简单request
     
     @return the default response, which is a 200 and an empty body.
     */
    mockRequest(@"GET", @"http://www.google.com");
    
    /**
     mock 请求，使用用正则表达式
     */
    mockRequest(@"GET", @"(.*?)google.com(.*?)".regex);
    
    /**
     mock 请求，更新部分应答
     */
    mockRequest(@"POST", @"http://www.google.com/post").
    isUpdatePartResponseBody(YES).
    withBody(@"{\"name\":\"abc\"}").
    atReturn(200).
    withBody(@"{\"key\":\"value\"}");
    
    /**
     mock 请求，使用json文件
     */
//    mockRequest(@"POST", @"http://www.google.com/post2").
//    isUpdatePartResponseBody(YES).
//    withBody(@"{\"name\":\"abc\"}").
//    atReturn(200).
//    withBody(@"google.json"); // 请确保 google.json 文件 存在
    
    /**
    Examle for update part response
        
        orginal response:
    {"data":{"id":"abc","location":"GZ"}}
    
updatedBody: google.json
    {"data":{"time":"today"}}
    
    final resoponse:
    {"data":{"id":"abc","location":"GZ","time":"today"}}
    */
    
    /***/
//    mockRequest(@"POST", @"http://www.google.com/post3").
//    withHeaders(@{@"Accept": @"application/json"}).
//    withBody(@"\"name\":\"foo\"").
//    isUpdatePartResponseBody(YES).
//    atReturn(200).
//    withHeaders(@{@"Content-Type": @"application/json"}).
//    withBody(@"google.json");
    
    /**
     Log日志
     */
    HTTPMOCK.logBlock = ^(NSString *logStr) {
        NSLog(@"%@", logStr);
    };
```


### 脚本跑测试

* 依赖：xctool-0.3.3
* 脚本：Scripts/run-test.sh
* 使用
```
# 帮助:
#
#    测试所有用例：       ./run-test.sh -a
#    测试单个用例(1)：    ./run-test.sh -f NetworkingTest
#    测试单个用例(2)：    ./run-test.sh -f Networking*
```

## 依赖

1. [mjmsmith/gcdobjc](https://github.com/mjmsmith/gcdobjc)
2. [DispatchQueuePool](https://github.com/ibireme/YYKit)

