# BGFMDB让数据的增删改查分别只需要一行代码即可,就是这么简单任性.
   
## 类型支持:    
int,long,signed,float,double,NSInteger,CGFloat,BOOL,NSString,NSMutableString,NSMutableAttributedString,NSAttributedString,NSNumber,NSArray,NSMutableArray,NSDictionary,NSMutableDictionary,NSMapTable,NSHashTable,NSData,NSMutableData,UIImage,NSDate,NSURL,NSRange,CGRect,CGSize,CGPoint,自定义对象 等的存储.   

## 写本库的动机: 在对coredata和realm做了探究总结后,发现了很多有缺陷的地方,最明显的就是下面的原因:   
### realm缺陷: 
Realm不支持集合类型,这一点也是比较蛋疼。   
Realm支持以下的属性类型：BOOL、bool、int、NSInteger、long、long long、float、double、NSString、NSDate、NSData以及 被特殊类型标记的NSNumber。CGFloat属性的支持被取消了，因为它不具备平台独立性。    
这里就是不支持集合，比如说NSArray，NSMutableArray，NSDictionary，NSMutableDictionary，NSSet，NSMutableSet。如果服务器传来的一个字典，key是一个字符串，对应的value就是一个数组，这时候就想存储这个数组就比较困难了。   

### coredata缺陷:   
coredata虽然通过Transformable可以存取集合类型,但需要开发者去进行转换处理,使用起来不方便直观,虽然coredata有很多好用的封装库,像ResKit,MMRecord等,但这些库比较庞大,而且都是英文介绍,不利于国内初中级开发的快速开发使用.    

## 虽然国内也已经有了对FMDB面相对象层的封装,比如像JRDB,LKDBHelper等,但是在使用总结后还是发现不少的问题,问题如下:    
JRDB存储数组需要传入对象的泛型,同时还要复写一些函数和映射，这对于初中级开发者是很不利的,看的很萌逼.    
LKDBHelper好一点,但也要复写不少的函数,而且LKDBHelper的使用demo有点乱,还有就是不支持NSMaptable,NSHashTable的存储,LKDBHelper还有一个致命的弱点就是当类变量名称跟sqlite的关键字一样时,会发生冲突错误！  

### 而最重要的是: JRDB,LKDBHelper都不支持同一数组中存储不同类型的自定义类型数据,BGFMDB则完美支持,JRDB,LKDBHelper已经成为过去,现在是BGFMDB的时代,作者的宣言是：“要把BGFMDB写成不会写代码的人都会用的库”，欢迎大家反馈和吐槽问题,骚年作者等着你们.

### 添加所需依赖库   
libsqlite3   
### 导入头文件   
```Objective-C
/**
只要在自己的类中导入了BGFMDB.h这个头文件,本类就具有了存储功能.
*/
#import <Foundation/Foundation.h>
#import "BGFMDB.h"
@interface stockModel : NSObject
@property(nonatomic,copy)NSString* name;
@property(nonatomic,strong)NSNumber* stockData;
+(instancetype)stockWithName:(NSString*)name stockData:(NSNumber*)stockData;
@end
```
### 主键
```Objective-C
/**
本库自带的自动增长主键.
*/
@property(nonatomic,strong)NSNumber*_Nullable bg_id;

/**
 为了方便开发者，特此加入以下两个字段属性供开发者做参考.(自动记录数据的存入时间和更新时间)
 */
@property(nonatomic,copy)NSString* _Nonnull bg_createTime;//数据创建时间(即存入数据库的时间)
@property(nonatomic,copy)NSString* _Nonnull bg_updateTime;//数据最后那次更新的时间.
```
### 唯一约束
```Objective-C
/**
如果需要指定“唯一约束”字段,就实现该函数,这里指定 name 为“唯一约束”.
*/
+(NSString *)bg_uniqueKey{
    return @"name";
}
```
### 初始化对象
```Objective-C
People* p = [self people];
```
### 存储
```Objective-C
/**
同步存储.
*/
[p bg_save];

/**
异步存储.
*/
[p bg_saveAsync:^(BOOL isSuccess) {
       //you code
   }];
   
/**
覆盖掉原来People类的所有数据,只存储当前对象的数据.
*/
[p bg_cover];

/**
 忽略存储，即忽略掉 user,info,students 这三个变量不存储.
 */
[p bg_saveIgnoredKeys:@[@"user",@"info",@"students"]];

/**
 同步存储或更新.
 当"唯一约束"或"主键"存在时，此接口会更新旧数据,没有则存储新数据.
 提示：“唯一约束”优先级高于"主键".
 */
 [p bg_saveOrUpdate];
```
### 查询
```Objective-C
/**
同步查询所有People的数据.
*/
NSArray* finfAlls = [People bg_findAll];

/**
异步查询所有People的数据.
*/
[People bg_findAllAsync:^(NSArray * _Nullable array) {
        // you code
    }];
    
/**
异步查询People类的数据,查询限制3条,通过age降序排列.
*/
[People bg_findAllAsyncWithLimit:3 orderBy:@"age" desc:YES complete:^(NSArray * _Nullable array) {
    for(People* p in array){
      // you code
    }
}];

/**
异步查询People类的数据,查询范围从第10处开始的后面5条,不排序.
*/
[People bg_findAllAsyncWithRange:NSMakeRange(10,5) orderBy:nil desc:NO complete:^(NSArray * _Nullable array) {
     for(People* p in array){
        // you code
     }
}];

/**
查询name等于爸爸和age等于45,或者name等于马哥的数据.  此接口是为了方便开发者自由扩展更深层次的查询条件逻辑.
*/
NSArray* arrayConds1 = [People bg_findFormatSqlConditions:@"where %@=%@ and %@=%@ or %@=%@",bg_sqlKey(@"age"),bg_sqlValue(@(45)),bg_sqlKey(@"name"),bg_sqlValue(@"爸爸"),bg_sqlKey(@"name"),bg_sqlValue(@"马哥")];

/**
查询user.student.human.body等于小芳 和 user1.name中包含fuck这个字符串的数据.
*/
NSArray* arrayConds2 = [People bg_findFormatSqlConditions:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳",@"user1.name",bg_contains,@"fuck"])];

/**
查询user.student.human.body等于小芳,user1.name中包含fuck这个字符串 和 name等于爸爸的数据.
*/
NSArray* arrayConds3 = [People bg_findFormatSqlConditions:@"where %@ and %@=%@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳",@"user1.name",bg_contains,@"fuck"]),bg_sqlKey(@"name"),bg_sqlValue(@"爸爸")];
```
### 更新
```Objective-C
/**
将People类数据中name=@"标哥"，num=220.88的数据更新为当前对象的数据.
*/
[p bg_updateWhere:@[@"name",@"=",@"标哥",@"num",@"=",@(220.88)]];

/**
将People类中name等于"马云爸爸"的数据的name更新为"马化腾",此接口是为了方便开发者自由扩展更深层次的更新条件逻辑.
*/
[People bg_updateFormatSqlConditions:@"set %@=%@ where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"马化腾"),bg_sqlKey(@"name"),bg_sqlValue(@"马云爸爸")];

/**
将People类数据中name等于"马化腾"的数据更新为当前对象的数据.
*/
[p bg_updateFormatSqlConditions:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"爸爸")];
```
### 删除
```Objective-C
/**
同步删除People类数据中name=@"标哥"，num=220.88的数据.
*/
[People bg_deleteWhere:@[@"name",@"=",@"标哥",@"num",@"=",@(220.88)]];

/**
异步删除People类数据中name=@"标哥"，num=220.88的数据.
*/
[People bg_deleteAsync:@[@"name",@"=",@"标哥",@"num",@"=",@(220.88)] complete:^(BOOL isSuccess) {
      // you code  
}];

/**
清除People表的所有数据.
*/
[People bg_clear];

/**
删除People的数据库表.
*/
[People bg_drop];

/**
删除People类中name等于"美国队长"的数据,此接口是为了方便开发者自由扩展更深层次的删除条件逻辑.
*/
[People bg_deleteFormatSqlConditions:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长")];

/**
删除People类中user.student.human.body等于"小芳"的数据
*/
[People bg_deleteFormatSqlConditions:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];

/**
删除People类中name等于"美国队长" 和 user.student.human.body等于"小芳"的数据
*/
[People bg_deleteFormatSqlConditions:@"where %@=%@ and %@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长"),bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
```
### keyPath(类嵌套的时候使用)   
```Objective-C
@interface Human : NSObject
@property(nonatomic,copy)NSString* sex;
@end

@interface Student : NSObject
@property(nonatomic,strong)Human* human;
@end

@interface User : NSObject
@property(nonatomic,strong)Student* student;
@end

@interface People : NSObject
@property(nonatomic,strong)User* user1;
@property(nonatomic,strong)User* user2;
@end

/**
查询People类中user2.student.human.sex中等于@“女”的数据.
*/
[People bg_findForKeyPathAndValues:@[@"user2.student.human.sex",bg_equal,@"女"]];

/**
将People类中user1.name包含@“小明”字符串 和 user2.student.human.sex中等于@“女”的数据 更新为当前对象的数据.
*/
[p bg_updateForKeyPathAndValues:@[@"user1.name",bg_contains,@"小明",@"user2.student.human.sex",bg_equal,@"女"]];
 
/**
删除People类中user1.name包含@“小明”字符串的数据.
*/
[People bg_deleteForKeyPathAndValues:@[@"user1.name",bg_contains,@"小明"]];
```
### 获取类数据库版本
```Objective-C
/**
 获取该类的数据库版本号;
*/
NSInteger version = [People bg_version];
```
### 类数据库版本手动升级('唯一约束'发生改变时调用)
```Objective-C
//注: 版本号从1开始,依次往后递增,本次更新版本号不得 低于或等于 上次的版本号,否则不会更新.
/**
 如果类'唯一约束'发生改变,则调用此API刷新该类数据库,不需要新旧映射的情况下使用此API.
*/
[People bg_updateVersion:version];

/**
如果类'唯一约束'发生改变,则调用此API刷新该类数据库.data2是新变量名,data是旧变量名,即将旧的值映射到新的变量名,其他不变的变量名会自动复制,只管写出变化的对应映射即可.
*/
[People bg_updateVersion:version keyDict:@{@"data2":@"data"}];
```
### 事务操作
```Objective-C
/**
事务操作,返回YES提交事务,返回NO则回滚事务.
*/
bg_inTransaction(^BOOL{
        [p bg_save];//存储
        //[People bg_clear];//清除全部People的数据.
        return NO;
    });
```
### 快速查询数据条数
```Objective-C
/**
查询People类中所有数据的条数.
*/
NSInteger count = [People bg_countWhere:nil]

/**
查询People类中age>=21,name=@"马哥"的数据条数.
*/
NSInteger count = [People bg_countWhere:@[@"age",@">=",@(21),@"name",@"=",@"马哥"]];

/**
查询People类中name等于"美国队长"的数据条数,此接口是为了方便开发者自由扩展更深层次的查询条件逻辑.
*/
NSInteger count = [People bg_countFormatSqlConditions:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长")];

/**
查询People类中user.student.human.body等于"小芳"的数据条数.
 */
NSInteger count = [People bg_countFormatSqlConditions:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];

/**
查询People类中name等于"美国队长" 和 user.student.human.body等于"小芳"的数据条数.
*/
NSInteger count = [People bg_countFormatSqlConditions:@"where %@=%@ and %@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长"),bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
```
### 类数据之间的拷贝
```Objective-C
/**
 将People的name拷贝给Man的Man_name，其他同理.
 */
 [People bg_copyToClass:[Man class] keyDict:@{@"name":@"Man_name",
                                           @"num":@"Man_num",
                                           @"age":@"Man_age",
                                           @"image":@"image"}
                                           append:NO];
```
### 直接存取数组
```Objective-C
NSMutableArray* testA = [NSMutableArray array];
    [testA addObject:@"我是"];
    [testA addObject:@(10)];
    [testA addObject:@(9.999)];
    [testA addObject:@{@"key":@"value"}];
    /**
     存储标识名为testA的数组.
     */
    [testA bg_saveArrayWithName:@"testA"];
    
    /**
     往标识名为@"testA"的数组中添加元素.
     */
    [NSArray bg_addObjectWithName:@"testA" object:@[@(1),@"哈哈"]];
    
    /**
     删除标识名为testA的数组某个位置上的元素.
     */
    [NSArray bg_deleteObjectWithName:@"testA" Index:3];
    
    /**
     查询标识名为testA的数组全部元素.
     */
    NSArray* testResult = [NSArray bg_arrayWithName:@"testA"];
    
    /**
     获取标识名为testA的数组某个位置上的元素.
     */
    id arrObject = [NSArray bg_objectWithName:@"testA" Index:3];
    
    /**
     清除标识名为testA的数组所有元素.
     */
    [NSArray bg_clearArrayWithName:@"testA"];
```
### 直接存取字典
```Objective-C
NSDictionary* dict = @{@"one":@(1),@"key":@"value",@"array":@[@(1.2),@"哈哈"]};
    /**
     存储字典.
     */
    [dict bg_saveDictionary];
    
    /**
     添加字典元素.
     */
    [NSDictionary bg_setValue:@"标哥" forKey:@"name"];
    
    /**
     获取某个字典元素.
     */
    id num = [NSDictionary bg_valueForKey:@"one"];
    
    /**
     移除字典某个元素.
     */
    [NSDictionary bg_removeValueForKey:@"key"];
    
    /**
     遍历字典元素.
     */
    [NSDictionary bg_enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull value, BOOL *stop) {
        NSLog(@"key = %@ , value = %@",key,value);
    }];
    
    /**
     清空字典.
     */
    [NSDictionary bg_clearDictionary];
```
### 注册数据变化监听
```Objective-C
/**
注册stockModel类数据变化监听.  
*/
[stockModel bg_registerChangeWithName:@"stockModel" block:^(changeState result){  
        switch (result) {  
            case Insert:  
                NSLog(@"有数据插入");  
                break;  
            case Update:  
                NSLog(@"有数据更新");  
                break;  
            case Delete:  
                NSLog(@"有数据删删除");  
                break;  
            case Drop:  
                NSLog(@"有表删除");  
                break;  
            default:  
                break;  
        }  
    }];  
```
### 移除数据监听
```Objective-C
/**
移除stockModel类数据变化的监听.  
*/
[stockModel bg_removeChangeWithName:@"stockModel"];
```
### 字典转模型
```Objective-C
NSDictionary* dictAni = [self getDogDict];
/**
一代码搞定字典转模型.
*/
Dog* dog = [Dog bg_objectWithKeyValues:dictAni];

NSDictionary* dictMy = [self getMyDict];
/**
一代码搞定字典转模型.
*/
My* my = [My bg_objectWithDictionary:dictMy];
```
### 模型转字典
```Objective-C
/**
一句代码搞定模型转字典.
*/
 NSDictionary* dictBodyAll = [body bg_keyValuesIgnoredKeys:nil];
 
/**
忽略掉hand这个变量不转.
*/
NSDictionary* dictBody = [body bg_keyValuesIgnoredKeys:@[@"hand"]];
```
### 如果模型中的数组变量存储的是自定义类,则需要实现下面的这个函数:
```Objective-C
/**
如果模型中有数组且存放的是自定义的类(NSString等系统自带的类型就不必要了),那就实现该函数,key是数组名称,value是自定的类Class,用法跟MJExtension一样.
(‘字典转模型’ 或 ’模型转字典‘ 都需要实现该函数)
*/
+(NSDictionary *)bg_objectClassInArray{
    return @{@"dogs":[Dog class],@"bodys":[Body class]};
}

/**
 如果模型中有自定义类变量,则实现该函数对应进行集合到模型的转换.
 将json数据中body这个key对应的值转化为Body类变量body对象.
 */
+(NSDictionary *)bg_objectClassForCustom{
    return @{@"body":[Body class]};
}
```
### 基本的使用
```Objective-C
stockModel* shenStock = [stockModel stockWithName:@"深市" stockData:_shenData];   
[shenStock bg_save];//一句代码搞定存储.   
[shenStock bg_updateWhere:@[@"name",@"=",@"深市"]];//一句代码搞定更新.   
NSArray* array = [stockModel bg_findAll];//一句代码搞定查询.   
[stockModel bg_deleteWhere:@[@"name",@"=",@"深市"]];//一句代码搞定删.  
//注册数据变化监听.  
[stockModel bg_registerChangeWithName:@"stockModel" block:^(changeState result){  
        switch (result) {  
            case Insert:  
                NSLog(@"有数据插入");  
                break;  
            case Update:  
                NSLog(@"有数据更新");  
                break;  
            case Delete:  
                NSLog(@"有数据删删除");  
                break;  
            case Drop:  
                NSLog(@"有表删除");  
                break;  
            default:  
                break;  
        }  
    }];  
  //移除数据变化监听.  
 [stockModel bg_removeChangeWithName:@"stockModel"]; 
 
 //更多功能请下载demo使用了解.
```   
### 更多功能请下载demo运行了解使用.   
