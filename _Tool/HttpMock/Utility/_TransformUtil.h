//
//  _TransformUtil.h
//  NewStructureTests
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * __QueryStringFromParameters(NSDictionary *parameters);
FOUNDATION_EXPORT NSArray * __QueryStringPairsFromDictionary(NSDictionary *dictionary);
FOUNDATION_EXPORT NSArray * __QueryStringPairsFromKeyAndValue(NSString *key, id value);
FOUNDATION_EXPORT NSString * __PercentEscapedStringFromString(NSString *string);

FOUNDATION_EXPORT NSArray * __QueryStringPairsFromQueryString(NSString *string);
FOUNDATION_EXPORT NSDictionary * __DictionaryFromQueryStringPairs(NSArray *pairs);
FOUNDATION_EXPORT NSDictionary * __DictionaryFromQueryString(NSString *string);
FOUNDATION_EXPORT NSString * __JsonStringFromDictionary(NSDictionary *dict, NSError **ptrError);
