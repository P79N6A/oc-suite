
#import <objc/runtime.h>

#import "_Runtime.h"
#import "_pragma_push.h"

#pragma mark -

void dumpClass(Class cls) {
    const char *className = class_getName(cls);
    
    NSLog(@"=== Class dump for %s ===", className);
    
    Class isa = object_getClass(cls);
    Class superClass = class_getSuperclass(cls);
    
    NSLog(@"  isa = %@", isa);
    NSLog(@"  superclass = %@", superClass);
    
    NSLog(@"Protocols:");
    unsigned int protocolCount = 0;
    Protocol *__unsafe_unretained* protocolList = class_copyProtocolList(cls, &protocolCount);
    for (unsigned int i = 0; i < protocolCount; i++) {
        Protocol *protocol = protocolList[i];
        const char *name = protocol_getName(protocol);
        NSLog(@"<%s>", name);
    }
    free(protocolList);
    
    NSLog(@"Instance variables:");
    unsigned int ivarCount = 0;
    Ivar *ivarList = class_copyIvarList(cls, &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        Ivar ivar = ivarList[i];
        const char *name = ivar_getName(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        const char *encoding = ivar_getTypeEncoding(ivar);
        NSLog(@"  %s [%ti] %s", name, offset, encoding);
    }
    free(ivarList);
    
    NSLog(@"Instance methods:");
    unsigned int instanceMethodCount = 0;
    Method *instanceMethodList = class_copyMethodList(cls, &instanceMethodCount);
    for (unsigned int i = 0; i < instanceMethodCount; i++) {
        Method method = instanceMethodList[i];
        SEL name = method_getName(method);
        const char *encoding = method_getTypeEncoding(method);
        NSLog(@"  -[%s %@] %s", className, NSStringFromSelector(name), encoding);
    }
    free(instanceMethodList);
    
    NSLog(@"Class methods:");
    unsigned int classMethodCount = 0;
    Method *classMethodList = class_copyMethodList(isa, &classMethodCount);
    for (unsigned int i = 0; i < classMethodCount; i++) {
        Method method = classMethodList[i];
        SEL name = method_getName(method);
        const char *encoding = method_getTypeEncoding(method);
        NSLog(@"  +[%s %@] %s", className, NSStringFromSelector(name), encoding);
    }
    free(classMethodList);
}

#pragma mark -

@implementation NSObject ( Runtime )

+ (NSArray *)loadedClassNames {
    static dispatch_once_t		once;
    static NSMutableArray *		classNames;
    
    dispatch_once( &once, ^ {
                      classNames = [[NSMutableArray alloc] init];
                      
                      unsigned int 	classesCount = 0;
                      Class *		classes = objc_copyClassList( &classesCount );
                      
                      for ( unsigned int i = 0; i < classesCount; ++i ) {
                          Class classType = classes[i];
                          
                          if ( class_isMetaClass( classType ) )
                              continue;
                          
                          Class superClass = class_getSuperclass( classType );
                          
                          if ( nil == superClass )
                              continue;
                          
                          [classNames addObject:[NSString stringWithUTF8String:class_getName(classType)]];
                      }
                      
                      [classNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                          return [obj1 compare:obj2];
                      }];
                      
                      free( classes );
                  });
    
    return classNames;
}

+ (__unsafe_unretained Class *)loadedClasses {
    int numClasses;
    Class *classes = NULL;
    
    numClasses = objc_getClassList(NULL,0);
    
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        
        numClasses = objc_getClassList(classes, numClasses);
    }
    
    return classes;
}

+ (void)enumerateloadedClassesUsingBlock:(void (^)(__unsafe_unretained Class))block {
    for ( NSString * className in [self loadedClassNames] ) {
        Class classType = NSClassFromString( className );
        
        if (block) block(classType);
    }
}

+ (NSArray *)subClasses {
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    for ( NSString * className in [self loadedClassNames] ) {
        Class classType = NSClassFromString( className );
        if ( classType == self ) {
            continue;
        }
        
        // bugfix: but not know why
//        if ( NO == [classType isSubclassOfClass:self] )
//            continue;
        if (class_getSuperclass(classType) != self) {
            continue;
        }
        
        [results addObject:[classType description]];
    }
    
    return results;
}

+ (NSArray *)methods {
    return [self methodsUntilClass:[self superclass]];
}

+ (NSArray *)methodsUntilClass:(Class)baseClass {
    NSMutableArray * methodNames = [[NSMutableArray alloc] init];
    
    Class thisClass = self;
    
    baseClass = baseClass ?: [NSObject class];
    
    while ( NULL != thisClass )
    {
        unsigned int	methodCount = 0;
        Method *		methodList = class_copyMethodList( thisClass, &methodCount );
        
        for ( unsigned int i = 0; i < methodCount; ++i )
        {
            SEL selector = method_getName( methodList[i] );
            if ( selector )
            {
                const char * cstrName = sel_getName(selector);
                if ( NULL == cstrName )
                    continue;
                
                NSString * selectorName = [NSString stringWithUTF8String:cstrName];
                if ( NULL == selectorName )
                    continue;
                
                [methodNames addObject:selectorName];
            }
        }
        
        free( methodList );
        
        thisClass = class_getSuperclass( thisClass );
        
        if ( nil == thisClass || baseClass == thisClass )
        {
            break;
        }
    }
    
    return methodNames;
}

+ (NSArray *)methodsWithPrefix:(NSString *)prefix {
    return [self methodsWithPrefix:prefix untilClass:[self superclass]];
}

+ (NSArray *)methodsWithPrefix:(NSString *)prefix untilClass:(Class)baseClass {
    NSArray * methods = [self methodsUntilClass:baseClass];
    
    if ( nil == methods || 0 == methods.count ) {
        return nil;
    }
    
    if ( nil == prefix ) {
        return methods;
    }
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    for ( NSString * selectorName in methods ) {
        if ( NO == [selectorName hasPrefix:prefix] ) {
            continue;
        }
        
        [result addObject:selectorName];
    }
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    return result;
}

+ (NSArray *)properties {
    return [self propertiesUntilClass:[self superclass]];
}

+ (NSArray *)propertiesUntilClass:(Class)baseClass {
    NSMutableArray * propertyNames = [[NSMutableArray alloc] init];
    
    Class thisClass = self;
    
    baseClass = baseClass ?: [NSObject class];
    
    while ( NULL != thisClass ) {
        unsigned int		propertyCount = 0;
        objc_property_t *	propertyList = class_copyPropertyList( thisClass, &propertyCount );
        
        for ( unsigned int i = 0; i < propertyCount; ++i ) {
            const char * cstrName = property_getName( propertyList[i] );
            if ( NULL == cstrName )
                continue;
            
            NSString * propName = [NSString stringWithUTF8String:cstrName];
            if ( NULL == propName )
                continue;
            
            [propertyNames addObject:propName];
        }
        
        free( propertyList );
        
        thisClass = class_getSuperclass( thisClass );
        
        if ( nil == thisClass || baseClass == thisClass ) {
            break;
        }
    }
    
    return propertyNames;
}

+ (NSArray *)propertiesWithPrefix:(NSString *)prefix {
    return [self propertiesWithPrefix:prefix untilClass:[self superclass]];
}

+ (NSArray *)propertiesWithPrefix:(NSString *)prefix untilClass:(Class)baseClass {
    NSArray * properties = [self propertiesUntilClass:baseClass];
    
    if ( nil == properties || 0 == properties.count ) {
        return nil;
    }
    
    if ( nil == prefix ) {
        return properties;
    }
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    for ( NSString * propName in properties ) {
        if ( NO == [propName hasPrefix:prefix] ) {
            continue;
        }
        
        [result addObject:propName];
    }
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    return result;
}

- (NSDictionary *)propertyDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for(int i=0;i<outCount;i++){
        objc_property_t prop = props[i];
        NSString *propName = [[NSString alloc]initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        id propValue = [self valueForKey:propName];
        [dict setObject:propValue?:[NSNull null] forKey:propName];
    }
    free(props);
    
    return dict;
}

+ (NSArray *)classesWithProtocolName:(NSString *)protocolName {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    Protocol * protocol = NSProtocolFromString(protocolName);
    for ( NSString *className in [self loadedClassNames] ) {
        Class classType = NSClassFromString( className );
        if ( classType == self )
            continue;
        
        if ( NO == [classType conformsToProtocol:protocol] )
            continue;
        
        [results addObject:[classType description]];
    }
    
    return results;
}

#pragma mark -

- (BOOL)respondsToSelector:(SEL)selector untilClass:(Class)stopClass {
    return [self.class instancesRespondToSelector:selector untilClass:stopClass];
}

- (BOOL)superRespondsToSelector:(SEL)selector {
    return [self.superclass instancesRespondToSelector:selector];
}

- (BOOL)superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass {
    return [self.superclass instancesRespondToSelector:selector untilClass:stopClass];
}

+ (BOOL)instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass {
    BOOL __block (^ __weak block_self)(Class klass, SEL selector, Class stopClass);
    BOOL (^block)(Class klass, SEL selector, Class stopClass) = [^
                                                                 (Class klass, SEL selector, Class stopClass)
                                                                 {
                                                                     if (!klass || klass == stopClass)
                                                                         return NO;
                                                                     
                                                                     unsigned methodCount = 0;
                                                                     Method *methodList = class_copyMethodList(klass, &methodCount);
                                                                     
                                                                     if (methodList)
                                                                         for (unsigned i = 0; i < methodCount; ++i)
                                                                             if (method_getName(methodList[i]) == selector)
                                                                                 return YES;
                                                                     
                                                                     return block_self(klass.superclass, selector, stopClass);
                                                                 } copy];
    
    block_self = block;
    
    return block(self.class, selector, stopClass);
}

+ (id)touchSelector:(SEL)selector {
    id obj = nil;
    if([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return obj;
}

- (id)touchSelector:(SEL)selector {
    id obj = nil;
    if([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return obj;
}

#pragma mark - 

- (NSArray *)propertyKeys {
    return [[self class] propertyKeys];
}

+ (NSArray *)propertyKeys {
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList(self, &propertyCount);
    NSMutableArray * propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNames;
}

- (NSArray *)propertiesInfo {
    return [[self class] propertiesInfo];
}

+ (NSArray *)propertiesInfo {
    NSMutableArray *propertieArray = [NSMutableArray array];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        [propertieArray addObject:({
            
            NSDictionary *dictionary = [self dictionaryWithProperty:properties[i]];
            
            dictionary;
        })];
    }
    
    free(properties);
    
    return propertieArray;
}

+ (NSArray *)propertiesWithCodeFormat {
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *properties = [[self class] propertiesInfo];
    
    for (NSDictionary *item in properties) {
        NSMutableString *format = ({
            
            NSMutableString *formatString = [NSMutableString stringWithFormat:@"@property "];
            //attribute
            NSArray *attribute = [item objectForKey:@"attribute"];
            attribute = [attribute sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            
            if (attribute && attribute.count > 0) {
                NSString *attributeStr = [NSString stringWithFormat:@"(%@)",[attribute componentsJoinedByString:@", "]];
                
                [formatString appendString:attributeStr];
            }
            
            //type
            NSString *type = [item objectForKey:@"type"];
            if (type) {
                [formatString appendString:@" "];
                [formatString appendString:type];
            }
            
            //name
            NSString *name = [item objectForKey:@"name"];
            if (name) {
                [formatString appendString:@" "];
                [formatString appendString:name];
                [formatString appendString:@";"];
            }
            
            formatString;
        });
        
        [array addObject:format];
    }
    
    return array;
}

+ (NSArray *)methodsInfo {
    u_int               count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods= class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        Method method = methods[i];
        //        IMP imp = method_getImplementation(method);
        SEL name = method_getName(method);
        // 返回方法的参数的个数
        int argumentsCount = method_getNumberOfArguments(method);
        //获取描述方法参数和返回值类型的字符串
        const char *encoding =method_getTypeEncoding(method);
        //取方法的返回值类型的字符串
        const char *returnType =method_copyReturnType(method);
        
        NSMutableArray *arguments = [NSMutableArray array];
        for (int index=0; index<argumentsCount; index++) {
            // 获取方法的指定位置参数的类型字符串
            char *arg =   method_copyArgumentType(method,index);
            //            NSString *argString = [NSString stringWithCString:arg encoding:NSUTF8StringEncoding];
            [arguments addObject:[[self class] decodeType:arg]];
        }
        
        NSString *returnTypeString =[[self class] decodeType:returnType];
        NSString *encodeString = [[self class] decodeType:encoding];
        NSString *nameString = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        
        [info setObject:arguments forKey:@"arguments"];
        [info setObject:[NSString stringWithFormat:@"%d",argumentsCount] forKey:@"argumentsCount"];
        [info setObject:returnTypeString forKey:@"returnType"];
        [info setObject:encodeString forKey:@"encode"];
        [info setObject:nameString forKey:@"name"];
        //        [info setObject:imp_f forKey:@"imp"];
        [methodList addObject:info];
    }
    free(methods);
    
    return methodList;
}

- (NSDictionary *)protocols {
    return [[self class] protocols];
}

+ (NSDictionary *)protocols {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned int count;
    Protocol * __unsafe_unretained * protocols = class_copyProtocolList([self class], &count);
    for (int i = 0; i < count; i++) {
        Protocol *protocol = protocols[i];
        
        NSString *protocolName = [NSString stringWithCString:protocol_getName(protocol) encoding:NSUTF8StringEncoding];
        
        NSMutableArray *superProtocolArray = ({
            
            NSMutableArray *array = [NSMutableArray array];
            
            unsigned int superProtocolCount;
            Protocol * __unsafe_unretained * superProtocols = protocol_copyProtocolList(protocol, &superProtocolCount);
            for (int ii = 0; ii < superProtocolCount; ii++)
            {
                Protocol *superProtocol = superProtocols[ii];
                
                NSString *superProtocolName = [NSString stringWithCString:protocol_getName(superProtocol) encoding:NSUTF8StringEncoding];
                
                [array addObject:superProtocolName];
            }
            free(superProtocols);
            
            array;
        });
        
        [dictionary setObject:superProtocolArray forKey:protocolName];
    }
    free(protocols);
    
    return dictionary;
}

+ (NSArray *)instanceVariable {
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        NSString *type = [[self class] decodeType:ivar_getTypeEncoding(ivars[i])];
        NSString *name = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
        NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
        [result addObject:ivarDescription];
    }
    free(ivars);
    return result.count ? [result copy] : nil;
}

- (BOOL)hasPropertyForKey:(NSString *)key {
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    return (BOOL)property;
}

- (BOOL)hasIvarForKey:(NSString *)key {
    Ivar ivar = class_getInstanceVariable([self class], [key UTF8String]);
    return (BOOL)ivar;
}

#pragma mark -- help

+ (NSDictionary *)dictionaryWithProperty:(objc_property_t)property {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    //name
    NSString *propertyName = __propertyName(property);
    [result setObject:propertyName forKey:@"name"];
    
    //attribute
    NSMutableDictionary *attributeDictionary = ({
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        unsigned int attributeCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attributeCount);
        
        for (int i = 0; i < attributeCount; i++) {
            NSString *name = [NSString stringWithCString:attrs[i].name encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:attrs[i].value encoding:NSUTF8StringEncoding];
            [dictionary setObject:value forKey:name];
        }
        
        free(attrs);
        
        dictionary;
    });
    
    NSMutableArray *attributeArray = [NSMutableArray array];
    
    /***
     https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
     
     R           | The property is read-only (readonly).
     C           | The property is a copy of the value last assigned (copy).
     &           | The property is a reference to the value last assigned (retain).
     N           | The property is non-atomic (nonatomic).
     G<name>     | The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
     S<name>     | The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
     D           | The property is dynamic (@dynamic).
     W           | The property is a weak reference (__weak).
     P           | The property is eligible for garbage collection.
     t<encoding> | Specifies the type using old-style encoding.
     */
    
    //R
    if ([attributeDictionary objectForKey:@"R"]) {
        [attributeArray addObject:@"readonly"];
    }
    
    //C
    if ([attributeDictionary objectForKey:@"C"]) {
        [attributeArray addObject:@"copy"];
    }
    
    //&
    if ([attributeDictionary objectForKey:@"&"]) {
        [attributeArray addObject:@"strong"];
    }
    
    //N
    if ([attributeDictionary objectForKey:@"N"]) {
        [attributeArray addObject:@"nonatomic"];
    } else {
        [attributeArray addObject:@"atomic"];
    }
    
    //G<name>
    if ([attributeDictionary objectForKey:@"G"]) {
        [attributeArray addObject:[NSString stringWithFormat:@"getter=%@", [attributeDictionary objectForKey:@"G"]]];
    }
    
    //S<name>
    if ([attributeDictionary objectForKey:@"S"]) {
        [attributeArray addObject:[NSString stringWithFormat:@"setter=%@", [attributeDictionary objectForKey:@"G"]]];
    }
    
    //D
    if ([attributeDictionary objectForKey:@"D"]) {
        [result setObject:[NSNumber numberWithBool:YES] forKey:@"isDynamic"];
    } else {
        [result setObject:[NSNumber numberWithBool:NO] forKey:@"isDynamic"];
    }
    
    //W
    if ([attributeDictionary objectForKey:@"W"]) {
        [attributeArray addObject:@"weak"];
    }
    
    //P
    if ([attributeDictionary objectForKey:@"P"]) {
        //TODO:P | The property is eligible for garbage collection.
    }
    
    //T
    if ([attributeDictionary objectForKey:@"T"]) {
        /*
         https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
         c               A char
         i               An int
         s               A short
         l               A long l is treated as a 32-bit quantity on 64-bit programs.
         q               A long long
         C               An unsigned char
         I               An unsigned int
         S               An unsigned short
         L               An unsigned long
         Q               An unsigned long long
         f               A float
         d               A double
         B               A C++ bool or a C99 _Bool
         v               A void
         *               A character string (char *)
         @               An object (whether statically typed or typed id)
         #               A class object (Class)
         :               A method selector (SEL)
         [array type]    An array
         {name=type...}  A structure
         (name=type...)  A union
         bnum            A bit field of num bits
         ^type           A pointer to type
         ?               An unknown type (among other things, this code is used for function pointers)
         
         */
        
        NSDictionary *typeDic = @{@"c":@"char",
                                  @"i":@"int",
                                  @"s":@"short",
                                  @"l":@"long",
                                  @"q":@"long long",
                                  @"C":@"unsigned char",
                                  @"I":@"unsigned int",
                                  @"S":@"unsigned short",
                                  @"L":@"unsigned long",
                                  @"Q":@"unsigned long long",
                                  @"f":@"float",
                                  @"d":@"double",
                                  @"B":@"BOOL",
                                  @"v":@"void",
                                  @"*":@"char *",
                                  @"@":@"id",
                                  @"#":@"Class",
                                  @":":@"SEL",
                                  };
        //TODO:An array
        NSString *key = [attributeDictionary objectForKey:@"T"];
        
        id type_str = [typeDic objectForKey:key];
        
        if (type_str == nil) {
            if ([[key substringToIndex:1] isEqualToString:@"@"] && [key rangeOfString:@"?"].location == NSNotFound) {
                type_str = [[key substringWithRange:NSMakeRange(2, key.length - 3)] stringByAppendingString:@"*"];
            } else if ([[key substringToIndex:1] isEqualToString:@"^"]) {
                id str = [typeDic objectForKey:[key substringFromIndex:1]];
                
                if (str) {
                    type_str = [NSString stringWithFormat:@"%@ *",str];
                }
            } else {
                type_str = @"unknow";
            }
        }
        
        [result setObject:type_str forKey:@"type"];
    }
    
    [result setObject:attributeArray forKey:@"attribute"];
    
    return result;
}

+ (NSString *)decodeType:(const char *)cString {
    if (!strcmp(cString, @encode(char)))
        return @"char";
    if (!strcmp(cString, @encode(int)))
        return @"int";
    if (!strcmp(cString, @encode(short)))
        return @"short";
    if (!strcmp(cString, @encode(long)))
        return @"long";
    if (!strcmp(cString, @encode(long long)))
        return @"long long";
    if (!strcmp(cString, @encode(unsigned char)))
        return @"unsigned char";
    if (!strcmp(cString, @encode(unsigned int)))
        return @"unsigned int";
    if (!strcmp(cString, @encode(unsigned short)))
        return @"unsigned short";
    if (!strcmp(cString, @encode(unsigned long)))
        return @"unsigned long";
    if (!strcmp(cString, @encode(unsigned long long)))
        return @"unsigned long long";
    if (!strcmp(cString, @encode(float)))
        return @"float";
    if (!strcmp(cString, @encode(double)))
        return @"double";
    if (!strcmp(cString, @encode(bool)))
        return @"bool";
    if (!strcmp(cString, @encode(_Bool)))
        return @"_Bool";
    if (!strcmp(cString, @encode(void)))
        return @"void";
    if (!strcmp(cString, @encode(char *)))
        return @"char *";
    if (!strcmp(cString, @encode(id)))
        return @"id";
    if (!strcmp(cString, @encode(Class)))
        return @"class";
    if (!strcmp(cString, @encode(SEL)))
        return @"SEL";
    if (!strcmp(cString, @encode(BOOL)))
        return @"BOOL";
    
    //    NSDictionary *typeDic = @{@"c":@"char",
    //                              @"i":@"int",
    //                              @"s":@"short",
    //                              @"l":@"long",
    //                              @"q":@"long long",
    //                              @"C":@"unsigned char",
    //                              @"I":@"unsigned int",
    //                              @"S":@"unsigned short",
    //                              @"L":@"unsigned long",
    //                              @"Q":@"unsigned long long",
    //                              @"f":@"float",
    //                              @"d":@"double",
    //                              @"B":@"BOOL",
    //                              @"v":@"void",
    //                              @"*":@"char *",
    //                              @"@":@"id",
    //                              @"#":@"Class",
    //                              @":":@"SEL",
    //                              };
    
    //@TODO: do handle bitmasks
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    //    if ([typeDic objectForKey:result]) {
    //        return [typeDic objectForKey:result];
    //    }
    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    } else {
        if ([[result substringToIndex:1] isEqualToString:@"^"]) {
            result = [NSString stringWithFormat:@"%@ *",
                      [NSString decodeType:[[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    return result;
}


#pragma mark -

- (NSArray *)conformedProtocols {
    unsigned int outCount = 0;
    Class obj_class = [self class];
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(obj_class, &outCount);
    
    NSMutableArray *protocol_array = nil;
    if (outCount > 0) {
        protocol_array = [[NSMutableArray alloc] initWithCapacity:outCount];
        
        for (NSInteger i = 0; i < outCount; i++) {
            NSString *protocol_name_string;
            const char *protocol_name = protocol_getName(protocols[i]);
            protocol_name_string = [[NSString alloc] initWithCString:protocol_name
                                                            encoding:NSUTF8StringEncoding];
            [protocol_array addObject:protocol_name_string];
        }
    }
    
    return protocol_array;
}

- (NSArray *)allIvars {
    unsigned int count = 0;
    Ivar *ivar_ptr = NULL;
    ivar_ptr = class_copyIvarList([self class], &count);
    
    if ( !ivar_ptr ) {
        return [NSArray array];
    }
    
    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        @autoreleasepool {
            NSString *ivar = __ivarName(ivar_ptr[i]);
            [all addObject:ivar];
        }
    }
    free(ivar_ptr);
    return all;
}

- (NSArray *)parents {
    Class selfClass = object_getClass(self);
    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:0];
    
    Class aClass = class_getSuperclass(selfClass);
    while (aClass != nil) {
        @autoreleasepool {
            [all addObject: NSStringFromClass(aClass) ];
            aClass = class_getSuperclass(aClass);
        }
    }
    return all;
}

- (NSString *)className {
    return NSStringFromClass(object_getClass(self));
}

+ (NSString *)className {
    return NSStringFromClass([self class]);
}

- (NSString *)superClassName {
    return NSStringFromClass([self superclass]);
}

+ (NSString *)superClassName {
    return NSStringFromClass([self superclass]);
}

+ (BOOL)isNSObjectClass:(Class)clazz {
    BOOL flag = class_conformsToProtocol(clazz, @protocol(NSObject));
    if (flag) {
        return flag;
    } else {
        Class superClass = class_getSuperclass(clazz);
        if (!superClass) {
            return NO;
        } else {
            return  [NSObject isNSObjectClass:superClass];
        }
    }
}

#pragma mark - Inline method

/*! 以 NSString 类型返回 property名称 */
static inline NSString *__propertyName(objc_property_t property) {
    const char *name = property_getName(property);
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

/*! 以 NSString 类型返回 ivar 名称 */
static inline NSString *__ivarName(Ivar ivar) {
    const char *name = ivar_getName(ivar);
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

/*! 以 NSString 类型返回 method 名称 */
static inline NSString *__methodName(Method m) {
    return NSStringFromSelector(method_getName(m));
}

@end

#import "_pragma_pop.h"
