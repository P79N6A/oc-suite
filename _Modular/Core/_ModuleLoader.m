#import <objc/runtime.h>
#import "_ModuleLoader.h"
#import "_LaunchableProtocol.h"
#import "_LoadableProtocol.h"
#import "_pragma_push.h"

@implementation _ModuleLoader

@def_singleton( _ModuleLoader )

- (void)loadable {
    [self.class eachLoadedClass:^(__unsafe_unretained Class cls) {
        if ([cls conformsToProtocol:@protocol(_LoadableProtocol)]) {
            if ([cls respondsToSelector:@selector(onLoad)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [cls performSelector:@selector(onLoad) withObject:nil];
                
#pragma clang diagnostic pop
            }
        }
    }];
}

- (void)launchable:(UIApplication *)application options:(NSDictionary *)options {
    [self.class eachLoadedClass:^(__unsafe_unretained Class cls) {
        if ([cls conformsToProtocol:@protocol(_LaunchableProtocol)]) {
            if ([cls respondsToSelector:@selector(onLaunch)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [cls performSelector:@selector(onLaunch) withObject:nil];
                
#pragma clang diagnostic pop
            }
        }
    }];
}

// MARK: - Utility

+ (NSArray *)loadedClassNames {
    static dispatch_once_t once;
    static NSMutableArray *classNames;
    
    dispatch_once(&once, ^{
        classNames = [NSMutableArray new];
        
        unsigned int classesCount = 0;
        Class *     classes = objc_copyClassList( &classesCount );
        
        for ( unsigned int i = 0; i < classesCount; ++i ) {
            Class classType = classes[i];
            
            if (class_isMetaClass( classType )) {
                continue;
            }
            
            Class superClass = class_getSuperclass( classType );
            
            if ( nil == superClass ) {
                continue;
            }
            
            NSString *className = [NSString stringWithUTF8String:class_getName(classType)];
            
            [classNames addObject:className];
        }
        
        [classNames sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        free( classes );
    });
    
    return classNames;
}

+ (void)eachLoadedClass:(void(^)(__unsafe_unretained Class cls))block {
    NSArray *classNames = [self loadedClassNames];
    for (NSString *className in classNames) {
        Class classType = NSClassFromString(className);
        
        if (block) block(classType);
    }
}

@end

#import "_pragma_pop.h"

