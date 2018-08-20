# KVO的实现原理

1. [x] 支持对象类型属性的KVO
2. [ ] 支持基本类型属性的KVO

### 概述

* Objective-C 对观察者模式（Observer Pattern）的实现, 也是 Cocoa Binding 的基础
* 基于runtime机制实现

### 实现

*当类的属性对象第一次被观察时，系统就会在运行期动态地创建该类的一个派生类，在这个派生类中重写基类中任何被观察属性的setter方法。派生类在被重写的setter方法内实现真正的通知机制*

1. 使用了isa 混写（isa-swizzling），当一个对象(假设是person对象，person的类是 Person )的属性值(假设person的age)发生改变时，系统会自动生成一个类，继承自 Person ：NSKVONotifying_Person，在这个类的setAge方法里面，调用
```
[super setAge:age]
```
[self willChangeValueForKey:@"age"] 和 [self didChangeValueForKey:@"age"] , 而这两个方法内部会主动调用监听者内部的 - (void)observeValueForKeyPath 这个方法。

2. 每个类对象中都有一个isa指针指向当前类，当一个类对象的第一次被观察，那么系统会偷偷将isa指针指向动态生成的派生类，从而在给被监控属性赋值时执行的是派生类的setter方法

3. 键值观察通知依赖于NSObject 的两个方法: willChangeValueForKey: 和 didChangevlueForKey:；在一个被观察属性发生改变之前， willChangeValueForKey:一定会被调用，这就 会记录旧的值。而当改变发生后，didChangeValueForKey:会被调用，继而 observeValueForKey:ofObject:change:context: 也会被调用。

```
- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return [super automaticallyNotifiesObserversForKey:key];
}

// 执行时序为

// 1. 调用 赋值操作
// 2. willChangeValueForKey:
// 3. 实际 赋值操作
// 4. didChangeValueForKey:
// 5. observeValueForKey:ofObject:change:context:
```

4. 想要看到NSKVONotifying_Person
```
self.person.age = 20; // 打断点，在调试区域就能看到
_person->NSObject->isa=(Class)NSKVONotifying_MYPerson // 同时我们在
self.person = [[MYPerson alloc]init]; //后面打断点，看到
_person->NSObject->isa=(Class)MYPerson // 由此可见，在添加监听者之后
person类型已经由MYPerson被改变成NSKVONotifying_MYPerson
```

### 当前

当前实现，不会触发

```
- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
}
```

### 官方文档

[Key-Value Observing Implementation Details](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html#//apple_ref/doc/uid/20002307-BAJEAIEE)
