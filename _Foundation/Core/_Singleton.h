
#import <Foundation/Foundation.h>

#pragma mark -

#undef  singleton
#define singleton( __class ) \
        property (nonatomic, readonly) __class * sharedInstance; \
        - (__class *)sharedInstance; \
        + (__class *)sharedInstance;

#undef  def_singleton
#define def_singleton( __class ) \
        dynamic sharedInstance; \
        - (__class *)sharedInstance \
        { \
            return [__class sharedInstance]; \
        } \
        + (__class *)sharedInstance \
        { \
            static dispatch_once_t once; \
            static __strong id __singleton__ = nil; \
            dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
            return __singleton__; \
        }

#undef  def_singleton_autoload
#define def_singleton_autoload( __class ) \
        def_singleton( __class ) \
        + (void)load \
        { \
            [self sharedInstance]; \
        }

#undef  def_singleton_with
#define def_singleton_with( _class_, _initHandler_ ) \
        dynamic sharedInstance; \
        - (_class_ *)sharedInstance \
        { \
            return [_class_ sharedInstance]; \
        } \
        + (_class_ *)sharedInstance \
        { \
            static dispatch_once_t once; \
            static __strong id __singleton__ = nil; \
            dispatch_once( &once, ^{ __singleton__ = _initHandler_(); } ); \
            return __singleton__; \
        }

#pragma mark - 

#undef  prop_singleton
#define prop_singleton( __type, __name ) \
        property (nonatomic, strong) __type * __name;

#undef  def_prop_singleton
#define def_prop_singleton( __type, __name ) \
        synthesize __name; \
        - (__type *)__name { \
            /* _##__name */if (!__name) { \
            __name = [__type sharedInstance]; \
            } \
            return __name; \
        }

#pragma mark -

@interface _Singleton : NSObject

+ (instancetype)sharedInstance;

@end
