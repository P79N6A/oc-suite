# OTDB
A light iOS object fmdb persistence support without any sql or core data knowledge.

# WHY? 
Normally there are two ways to impl the db storage in iOS applications.
```
1. Core data - quite complex to config and heavy code work. 
2. FMDB (or similiar sql lib) - you need to maintain all kinds of sql commands, still a pain in ass.
```

So, the problem is - I have an class inherited from NSObject, how fast can I persist it? (Support all CRUD operation)

#### OTDB give you the answer - all in one simple API! 

For example - I have a  testClass (and "strAttr1" is one of the string property), it has three objects, obj1, obj2, obj3.

``` objective-c
* C : [[OTDB sharedInstance]insertOrUpdateWithModelArr:@[obj1,obj2,obj3] byPrimaryKey:@"strAttr1"];
* R : [[OTDB sharedInstance]queryWithClass:[testClass class] key:nil value:nil orderByKey:nil desc:YES];
* U : [[OTDB sharedInstance]insertOrUpdateWithModelArr:@[obj1] byPrimaryKey:@"strAttr1"];
* D : [[OTDB sharedInstance]deleteModels:@[obj] withPrimaryKey:@"strAttr1"];
```

That's all you need to do, no need to config the data table, no need to write any sql command.

# Install
OTDB supports cocoapods install:

pod 'OTDB'

# Example Code: 
Here is the code of above example:

``` objective-c
    @interface testClass : NSObject
    
    @property (retain, nonatomic) NSString * strAttr1;
    @property (retain, nonatomic) NSString * strAttr2;
    @property (retain, nonatomic) NSNumber * numAttr1;
    @property (retain, nonatomic) NSNumber * numAttr2;
    
    @end
    
    @implementation testClass
    
    @end


    testClass * obj1 = [[testClass alloc]init];
    obj1.strAttr1 = @"obj1attr1";
    obj1.strAttr2 = @"obj1attr2";
    obj1.numAttr1 = @11;
    obj1.numAttr2 = @12;
    
    testClass * obj2 = [[testClass alloc]init];
    obj2.strAttr1 = @"obj2attr1";
    obj2.strAttr2 = @"obj2attr2";
    obj2.numAttr1 = @21;
    obj2.numAttr2 = @22;
    
    testClass * obj3 = [[testClass alloc]init];
    obj3.strAttr1 = @"obj3attr1";
    obj3.strAttr2 = @"obj3attr2";
    obj3.numAttr1 = @31;
    obj3.numAttr2 = @32;
    
    // insert one
    [[OTDB sharedInstance]insertOrUpdateWithModelArr:@[obj1] byPrimaryKey:@"strAttr1"];
    
    // insert multi
    [[OTDB sharedInstance]insertOrUpdateWithModelArr:@[obj2,obj3] byPrimaryKey:@"strAttr1"];
    
    // query
    NSArray * resultArray = [[OTDB sharedInstance]queryWithClass:[testClass class] key:@"strAttr1" value:@"obj1attr1" orderByKey:nil desc:YES];
    
    
    // query all
    NSArray * resultArrayAll = [[OTDB sharedInstance]queryWithClass:[testClass class] key:nil value:nil orderByKey:nil desc:YES];
    
    // update - note the primariy key value shall not be changed, otherwise it will trigger the insert
    testClass * obj = resultArray.firstObject;
    obj.strAttr2 = @"changedobj1attr2";
    [[OTDB sharedInstance]insertOrUpdateWithModelArr:@[obj] byPrimaryKey:@"strAttr1"];
    
    // delete
    [[OTDB sharedInstance]deleteModels:@[obj] withPrimaryKey:@"strAttr1"];
    
    // prune all data of the class
    [[OTDB sharedInstance]dropModels:[testClass class]];
    
```

