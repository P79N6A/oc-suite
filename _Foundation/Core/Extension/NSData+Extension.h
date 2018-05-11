
#import <Foundation/Foundation.h>

@interface NSData ( Extension )

@property (nonatomic, readonly) NSString *	string;
@property (nonatomic, readonly) NSString *	hexadecimalString;
@property (nonatomic, readonly) NSString *	utf8String;

- (void)writeToBinaryFile:(NSString *)path atomically:(BOOL)atomically;

@end

#pragma mark - FileFormat

@interface NSData ( FileFormat )

- (BOOL)isJPEG;
- (BOOL)isPNG;
- (BOOL)isImage;
- (BOOL)isMPEG4;
- (BOOL)isMedia;
- (BOOL)isCompressed;
- (NSString *)appropriateFileExtension;

@end

