
#import "_Property.h"

#define main_bundle [NSBundle mainBundle]

#define image_named_bundled( _imageName_, _bundleName_ ) [NSBundle imageWithName:_imageName_ bundleName:_bundleName_]
#define image_named_bundled_subpath( _imageName_, _bundleName_, _subPath_) [NSBundle imageWithName:_imageName_ bundleName:_bundleName_ subPath:_subPath_]

@interface NSBundle (Extension)

@prop_readonly( NSString *,	bundleName );
@prop_readonly( NSString *,	extensionName );

+ (NSBundle *)bundleWithName:(NSString *)bundleName;

+ (UIImage *)imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName;
+ (UIImage *)imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName subPath:(NSString *)subPath;

- (id)dataForResource:(NSString *)resName;
- (id)textForResource:(NSString *)resName;
- (id)imageForResource:(NSString *)resName;

@end



