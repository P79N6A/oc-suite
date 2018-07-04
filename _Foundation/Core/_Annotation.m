#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "_Annotation.h"
#import "_Thread.h"
#import "_Logger.h"
#import "_Macros.h"

// ----------------------------------
// MARK: C code
// ----------------------------------

static NSArray<NSString *>* __variablesAt(char *section) {
    NSMutableArray *configs = [NSMutableArray array];
    
    Dl_info info;
    dladdr(__variablesAt, &info);
    
#ifndef __LP64__
    //        const struct mach_header *mhp = _dyld_get_image_header(0); // both works as below line
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", section, & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, "__DATA", section, & size);
#endif /* defined(__LP64__) */
    
    for(int idx = 0; idx < size/sizeof(void *); ++idx) {
        char *string = (char *)memory[idx];
        
        NSString *str = [NSString stringWithUTF8String:string];
        
        if(!str) {
            continue;
        }
        
        LOG(@"config = %@", str);
        
        [configs addObject:str];
    }
    
    return configs;
    
}

// ----------------------------------
// MARK: Source code
// ----------------------------------

@implementation _Annotation

+ (NSArray<NSString *> *)annotationObjects {
    static NSArray<NSString *> *objects = nil;
    
    execute_once( ^{
        objects = __variablesAt(annotation_sectioname);
    })
    
    return objects;
}

+ (NSArray<NSString *> *)annotationBindings {
    static NSArray<NSString *> *bindings = nil;
    
    execute_once( ^{
        bindings = __variablesAt(annotation_sectioname);
    })
    
    return bindings;
}

+ (NSArray<NSString *> *)annotationObjectsForSectioname:(NSString *)sectioname {
    return __variablesAt((char *)sectioname.UTF8String);
}

+ (NSArray<NSString *> *)annotationBindingsForSectioname:(NSString *)sectioname {
    return __variablesAt((char *)sectioname.UTF8String);
}

@end
