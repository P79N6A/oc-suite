//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#import "_classloader.h"
#import "_pragma_push.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject ( ClassLoader )

+ (void)classAutoLoad {
    
}

@end

#pragma mark -

@implementation _ClassLoader

+ (instancetype)classLoader {
	return [[_ClassLoader alloc] init];
}

- (void)loadClasses:(NSArray *)classNames {
	for ( NSString * className in classNames ) {
		Class classType = NSClassFromString( className );
		if ( classType ) {
			fprintf( stderr, "  Loading class '%s'\n", [[classType description] UTF8String] );

			NSMethodSignature * signature = [classType methodSignatureForSelector:@selector(classAutoLoad)];
			NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
			
			[invocation setTarget:classType];
			[invocation setSelector:@selector(classAutoLoad)];
			[invocation invoke];
		}
	}
	
	fprintf( stderr, "\n" );
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#import "_pragma_pop.h"
