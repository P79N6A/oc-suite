#import "_Protocol.h"

@protocol _SerializationProtocol <_Protocol>

// 至少支持NSDictionary
- (id)modelWithJSON:(id)json class:(Class)cls;
- (NSArray *)modelsWithJSON:(id)json class:(Class)cls;

@end
