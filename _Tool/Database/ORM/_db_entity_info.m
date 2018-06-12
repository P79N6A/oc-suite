
#import "_db_entity_info.h"
#import "_db_tool.h"
#import "_db_config.h"
#import "_foundation.h"

@implementation _EntityInfo

+ (NSArray<_EntityInfo *> *)modelInfoWithObject:(id)object {
    NSMutableArray *modelInfos = [NSMutableArray array];
    NSArray *keyAndTypes = [_DatabaseTool getClassIvarList:[object class] onlyKey:NO];
    for(NSString *keyAndType in keyAndTypes){
        NSArray *keyTypes = [keyAndType componentsSeparatedByString:@"*"];
        NSString *propertyName = keyTypes[0];
        NSString *propertyType = keyTypes[1];
        
        _EntityInfo *info = [_EntityInfo new];
        
        [info setValue:propertyName forKey:@"propertyName"]; // 设置属性名
        [info setValue:propertyType forKey:@"propertyType"]; // 设置属性类型
        
        // 设置列名(BG_ + 属性名),加BG_是为了防止和数据库关键字发生冲突.
        [info setValue:[NSString stringWithFormat:@"%@%@",BG,propertyName] forKey:@"sqlColumnName"];
        
        NSString *sqlType = [_DatabaseTool getSqlType:propertyType]; //设置列属性
        [info setValue:sqlType forKey:@"sqlColumnType"];
        
        
        if(![propertyName isEqualToString:stringify(id)]) { // 读取属性值
            id propertyValue;
            id sqlValue;
            
            //crateTime和updateTime两个额外字段单独处理.
            if([propertyName isEqualToString:stringify(createTime)] ||
               [propertyName isEqualToString:stringify(updateTime)]){
                propertyValue = [_DatabaseTool stringWithDate:[NSDate new]];
            } else {
                propertyValue = [object valueForKey:propertyName];
            }
            
            if (propertyValue) {
                // 设置属性值
                [info setValue:propertyValue forKey:@"propertyValue"];
                sqlValue = [_DatabaseTool getSqlValue:propertyValue type:propertyType encode:YES];
                
                // 设置将要存储到数据库的值
                [info setValue:sqlValue forKey:@"sqlColumnValue"];
                [modelInfos addObject:info];
            }
        }
        
    }
    
    NSAssert(modelInfos.count,@"对象变量数据为空,不能存储!");
    
    return modelInfos;
}

@end
