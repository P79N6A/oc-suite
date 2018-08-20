#import "_Watcher.h"
#import "_pragma_push.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation _Watcher

@def_prop_strong( NSMutableArray *,		sourceFiles );
@def_prop_strong( NSString *,			sourcePath );

@def_notification( SourceFileDidChanged )
@def_notification( SourceFileDidRemoved )

@def_singleton( _Watcher )

- (id)init {
	self = [super init];
	if ( self ) {
	}
	return self;
}

- (void)dealloc {
	[self.sourceFiles removeAllObjects];
	self.sourceFiles = nil;
}

#pragma mark -

- (void)watch:(NSString *)path {
	self.sourcePath = [[NSString stringWithFormat:@"%@/../", path] stringByStandardizingPath];
	
#if (TARGET_IPHONE_SIMULATOR)
	[self scanSourceFiles];
#endif	// #if (TARGET_IPHONE_SIMULATOR)
}

#if (TARGET_IPHONE_SIMULATOR)

- (void)scanSourceFiles {
	if ( nil == self.sourceFiles ) {
		self.sourceFiles = [[NSMutableArray alloc] init];
	}

	[self.sourceFiles removeAllObjects];
	
	NSString * basePath = [[self.sourcePath stringByStandardizingPath] copy];
	if ( nil == basePath )
		return;
	
	NSDirectoryEnumerator *	enumerator = [[NSFileManager defaultManager] enumeratorAtPath:basePath];
	if ( enumerator ) {
		for ( ;; ) {
			NSString * filePath = [enumerator nextObject];
			if ( nil == filePath )
				break;

			NSString * fileName = [filePath lastPathComponent];
			NSString * fileExt = [fileName pathExtension];
			NSString * fullPath = [basePath stringByAppendingPathComponent:filePath];
			
			BOOL isDirectory = NO;
			BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
			if ( exists && NO == isDirectory ) {
				BOOL isValid = NO;
				
				for ( NSString * extension in @[ @"xml", @"html", @"htm", @"css" ] ) {
					if ( NSOrderedSame == [fileExt compare:extension] ) {
						isValid = YES;
						break;
					}
				}
				
				if ( isValid ) {
					[self.sourceFiles addObject:fullPath];
				}
			}
		}
	}
	
	for ( NSString * file in self.sourceFiles ) {
		[self watchSourceFile:file];
	}
}

- (void)watchSourceFile:(NSString *)filePath {
	int fileHandle = open( [filePath UTF8String], O_EVTONLY );
	if ( fileHandle ) {
		unsigned long				mask = DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND;
		__block dispatch_queue_t	queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
		__block dispatch_source_t	source = dispatch_source_create( DISPATCH_SOURCE_TYPE_VNODE, fileHandle, mask, queue );
		
		@weakify(self)
		
		__block id eventHandler = ^ {
			@strongify(self)
			
			unsigned long flags = dispatch_source_get_data( source );
			if ( flags ) {
				dispatch_source_cancel( source );
				dispatch_async( dispatch_get_main_queue(), ^ {
					BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL];
					if ( exists ) {
						[_Watcher postNotification:_Watcher.SourceFileDidChanged withObject:filePath];
					} else {
						[_Watcher postNotification:_Watcher.SourceFileDidRemoved withObject:filePath];
					}
				});
				
				[self watchSourceFile:filePath];
			}
		};
		
		__block id cancelHandler = ^ {
			close( fileHandle );
		};
		
		dispatch_source_set_event_handler( source, eventHandler );
		dispatch_source_set_cancel_handler( source, cancelHandler );
		dispatch_resume(source);
	}
}

#endif	// #if (TARGET_IPHONE_SIMULATOR)

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#import "_pragma_pop.h"
