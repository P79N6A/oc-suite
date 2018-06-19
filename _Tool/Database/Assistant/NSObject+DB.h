#import <Foundation/Foundation.h>
#import "_DBAssist.h"

@interface NSObject (DB)

@property (assign,nonatomic) NSUInteger row_id;
@property (strong,nonatomic) NSString *table_name;

+ (NSString *)dbPath;

+ (NSString *)tableName;
+ (NSArray *)primaryKeys;
+ (NSArray *)onlyPropertiesToMapColumns;
+ (NSArray *)exceptPropertiesToMapColumns;
+ (NSDictionary *)propertyToColumnMappings;
+ (NSDictionary *)defaultValues;
+ (NSDictionary *)checkValues;
+ (NSDictionary *)lengthValues;
+ (NSArray *)uniqueValues;
+ (NSArray *)notNullValues;

+ (NSString *)dateFormatterString;
+ (NSString *)imagePathForImage:(NSString *)imgName ;
+ (NSString *)dataPathForData:(NSString *)dataName;

+ (BOOL)shouldMapAllParentPropertiesToTable; //default is YES
+ (BOOL)shouldMapAllSelfPropertiesToTable; //default is YES

+ (BOOL)createTable;
+ (BOOL)dropTable;

+ (BOOL)insertModel:(NSObject *)model;
+ (BOOL)insertModelIfNotExists:(NSObject *)model;

+ (BOOL)deleteModel:(NSObject *)model;
+ (BOOL)deleteModelsWhere:(NSObject *)where;

+ (BOOL)updateModelsWithModel:(NSObject *)model where:(NSObject *)where;
+ (BOOL)updateModelsWithDictionary:(NSDictionary *)dic where:(NSObject *)where;

+ (BOOL)modelExists:(NSObject *)model;

+ (NSArray *)allModels;

+ (NSArray *)findModelsBySQL:(NSString *)sql;
+ (NSArray *)findModelsWhere:(NSObject *)where;
+ (NSArray *)findModelsWhere:(NSObject *)where
                     orderBy:(NSString *)orderBy;
+ (NSArray *)findModelsWhere:(NSObject *)where
                     groupBy:(NSString *)groupBy
                     orderBy:(NSString*)orderBy
                       limit:(int)limit
                      offset:(int)offset;

+ (id)firstModelWhere:(NSObject *)where;
+ (id)firstModelWhere:(NSObject *)where orderBy:(NSString*)orderBy ;

+ (id)lastModel;

+ (NSInteger)rowCountWhere:(NSObject *)where;

- (BOOL)saveModel;
- (BOOL)deleteModel;
- (BOOL)updateModel:(id)value;

+ (void)beginTransaction;
+ (void)commit;
+ (void)rollback;

+ (DBAssistant *)currentDBAssistant;

@end


