//
//  UIFont+Extension.m
//  consumer
//
//  Created by fallen.ink on 10/7/16.
//
//

#import "UIFont+Extension.h"

@implementation UIFont (Extension)

+ (NSDictionary *)allFonts {
    NSMutableDictionary *desc = [NSMutableDictionary new];
    NSArray *familyNames = [UIFont familyNames];
    for(NSString *familyName in familyNames) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        
        [desc setObject:fontNames forKey:familyName];
    }
    
    return desc;
}

@end
