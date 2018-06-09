#import "_Precompile.h"
#import "_Preconfigs.h"
#import "_Unitest.h"
#import "_Assert.h"
#import "_Macros.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation _Asserter

@def_singleton_autoload( _Asserter );

@def_prop_assign( BOOL,	enabled );

- (id)init {
    self = [super init];
    if ( self ) {
        _enabled = YES;
    }
    return self;
}

- (void)toggle {
    _enabled = _enabled ? NO : YES;
}

- (void)enable {
    _enabled = YES;
}

- (void)disable {
    _enabled = NO;
}

- (void)file:(const char *)file line:(NSUInteger)line func:(const char *)func flag:(BOOL)flag expr:(const char *)expr {
    if ( NO == _enabled )
        return;
    
    if ( NO == flag ) {
#if __DEBUG__
        
        fprintf( stderr,
                "                        \n"
                "    %s @ %s (#%lu)       \n"
                "    {                   \n"
                "        ASSERT( %s );   \n"
                "        ^^^^^^          \n"
                "        Assertion failed\n"
                "    }                   \n"
                "                        \n", func, [[@(file) lastPathComponent] UTF8String], (unsigned long)line, expr );
        
#endif
        
        abort();
    }
}

@end

#pragma mark -

#if __cplusplus
extern "C"
#endif

void __Assert( const char * file, NSUInteger line, const char * func, BOOL flag, const char * expr ) {
    [[_Asserter sharedInstance] file:file line:line func:func flag:flag expr:expr];
}

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if __TESTING__

TEST_CASE( Core, Asserter )
{
}

DESCRIBE( enable/disable )
{
    [[_Asserter sharedInstance] enable];
    EXPECTED( [[_Asserter sharedInstance] enabled] );
    
    [[_Asserter sharedInstance] disable];
    EXPECTED( NO == [[_Asserter sharedInstance] enabled] );
    
    [[_Asserter sharedInstance] toggle];
    EXPECTED( [[_Asserter sharedInstance] enabled] );
    
    [[_Asserter sharedInstance] toggle];
    EXPECTED( NO == [[_Asserter sharedInstance] enabled] );
    
    [[_Asserter sharedInstance] enable];
    EXPECTED( [[_Asserter sharedInstance] enabled] );
    
    ASSERT( YES );
    
    [[_Asserter sharedInstance] disable];
    
    ASSERT( NO );
    
    [[_Asserter sharedInstance] enable];
}

TEST_CASE_END

#endif	// #if __TESTING__

#import "_pragma_pop.h"
