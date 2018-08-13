//
//  NSDictionarySubscriptProtocol.h
//  NewStructure
//
//  Created by 7 on 20/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

// [[iOS] [OC] 为自己的类增加下标支持 obj[key] = value](http://www.jianshu.com/p/0bb1b6bee194)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSDictionarySubscriptProtocol <NSObject>

// 字典样式
- (nullable id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
