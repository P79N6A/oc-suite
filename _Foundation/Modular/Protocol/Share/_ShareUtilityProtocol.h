#import "_ShareParamProtocol.h"

@protocol _ShareUtilityProtocol <NSObject>

- (BOOL)availableForPlatform:(_SharePlatformType)platformType;

- (NSUInteger)typeOfPlatform:(_SharePlatformType)platformType;
- (NSUInteger)sceneTypeOfPlatform:(_SharePlatformType)platformType;

@end
