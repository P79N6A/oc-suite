#import "_Foundation.h"

#pragma mark -

@interface _Watcher : NSObject

@prop_strong( NSMutableArray *,		sourceFiles );
@prop_strong( NSString *,			sourcePath );

@notification( SourceFileDidChanged )
@notification( SourceFileDidRemoved )

@singleton( _Watcher )

- (void)watch:(NSString *)path;

@end
