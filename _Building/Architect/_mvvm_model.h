//
//  _mvvm_model.h
//  kata
//
//  Created by fallen on 17/3/15.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "_building_precompile.h"

/**
 Responsible
 
 1. model对controller层的接口，进行拆分；有点类似于mvp，将controller的action和mvp的handler一一对应.
 */

@interface _MvvmModel : NSObject

/** TODO：这里还需要注意，不能简单的这么构建生命周期函数 */

/** Call on 'init' */
- (void)setup;

/** Call on 'dealloc' */
- (void)clear;

@end

@interface _MvvmModel ( Template )

/**
 * @brief load from 0
 */
- (void)loadListWithSuccess:(ObjectBlock)successHandler failure:(ErrorBlock)failureHandler;

/**
 *  @brief append
 */
- (void)appendListWithSuccess:(ObjectBlock)successHandler failure:(ErrorBlock)failureHandler;

@end
