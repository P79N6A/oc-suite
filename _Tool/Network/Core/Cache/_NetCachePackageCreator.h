//
//  _net_cache_package_creator.h
//  consumer
//
//  Created by fallen.ink on 9/25/16.
//
//

#import "_net_cache.h"
#import "_net_cache_request.h"

#define kPackagerOptionResourcesFolder @"folder"
#define kPackagerOptionBaseURL @"baseurl"
#define kPackagerOptionMaxAge @"maxage"
#define kPackagerOptionMaxItemFileSize @"maxItemFileSize"
#define kPackagerOptionLastModifiedMinus @"lastmodifiedminus"
#define kPackagerOptionLastModifiedPlus @"lastmodifiedplus"
#define kPackagerOptionOutputFormatJSON @"json"
#define kPackagerOptionOutputFilename @"outfile"
#define kPackagerOptionIncludeAllFiles @"a"
#define kPackagerOptionUserDataFolder @"userdata"
#define kPackagerOptionUserDataKey @"userdatakey"
#define kPackagerOptionFileToURLMap @"FileToURLMap"

@interface _NetCachePackageCreator : NSObject

- (_NetCacheRequest *)newCacheableItemForFileAtPath:(NSString *)filepath
                                       lastModified:(NSDate *)lastModified
                                            baseURL:(NSString *)baseURL
                                             maxAge:(NSNumber *)maxAge
                                         baseFolder:(NSString *)folder;
- (BOOL)createPackageWithOptions:(NSDictionary *)options error:(NSError **)inError;

@end
