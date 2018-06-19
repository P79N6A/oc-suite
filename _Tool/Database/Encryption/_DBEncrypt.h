
#import "FMDB.h"

@interface FMDatabase (Encryption)

/**
 Encrypt db and delete the old file
 @param path old db path
 @return YES if succeed.
 */
+ (BOOL)encryptDatabase:(NSString *)path;
/**
 Encrypt db and rename the old db with extension *.old
 @param path old db path
 @param remove remove old db or not
 @return YES if succeed.
 */
+ (BOOL)encryptDatabase:(NSString *)path
              removeOld:(BOOL)remove;

/**
 Encrypt db.
 @param path old db path
 @param destinationPath new db path
 @param remove remove the old path or not
 @return YES if succeed.
 */
+ (BOOL)encryptDatabase:(NSString *)path
                 toPath:(NSString *)destinationPath
     removeWhenComplete:(BOOL)remove;

@end
