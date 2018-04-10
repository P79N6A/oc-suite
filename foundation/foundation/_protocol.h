
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// For a magic reserved keyword color, use @defs(your_protocol_name)
#undef  defs
#define defs _pk_extension

// Interface
#undef  _pk_extension
#define _pk_extension($protocol) _pk_extension_imp($protocol, _pk_get_container_class($protocol))

// Implementation
#undef  _pk_extension_imp
#define _pk_extension_imp($protocol, $container_class) \
        protocol $protocol; \
        @interface $container_class : NSObject <$protocol> @end \
        @implementation $container_class \
            + (void)load { \
                _pk_extension_load(@protocol($protocol), $container_class.class); \
            } \

// Get container class name by counter
#undef  _pk_get_container_class
#define _pk_get_container_class($protocol) \
        _pk_get_container_class_imp($protocol, __COUNTER__)

#undef  _pk_get_container_class_imp
#define _pk_get_container_class_imp($protocol, $counter) \
        _pk_get_container_class_imp_concat(__PKContainer_, $protocol, $counter)

#undef  _pk_get_container_class_imp_concat
#define _pk_get_container_class_imp_concat($a, $b, $c) \
        $a ## $b ## _ ## $c

void _pk_extension_load(Protocol *protocol, Class containerClass);

/**
 * Protocol Extension Usage
 *
 * @code
 
 // Protocol
 
 @protocol Forkable <NSObject>
 
 @optional
 - (void)fork;
 
 @required
 - (NSString *)github;
 
 @end
 
 // Protocol Extension
 
 @defs(Forkable)
 
 - (void)fork {
 NSLog(@"Forkable protocol extension: I'm forking (%@).", self.github);
 }
 
 - (NSString *)github {
 return @"This is a required method, concrete class must override me.";
 }
 
 @end
 
 // Concrete Class
 
 @interface Forkingdog : NSObject <Forkable>
 @end
 
 @implementation Forkingdog
 
 - (NSString *)github {
 return @"https://github.com/forkingdog";
 }
 
 @end
 
 * @endcode
 *
 * @note You can either implement within a single @defs or multiple ones.
 *
 */
