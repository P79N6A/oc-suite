//
//  ExampleRequest.h
//  gege
//
//  Created by fallen.ink on 2019/3/14.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExampleRequest : NSObject

@end

@interface MemberCarddetailRequest : NSObject
@property (nonatomic, assign) int64_t card_id;
@end

@interface MemberBindParent : NSObject
@property (nonatomic, assign) int32_t parent_uuid;
@property (nonatomic, strong) NSString * parent_name;
@end

@interface MemberBindcard : NSObject
@property (nonatomic, assign) int32_t child_uuid;             //小孩id
@property (nonatomic, strong) NSString *child_name;         //小孩姓名
@property (nonatomic, strong) NSString *valid_date;         //截止有效期
@property (nonatomic, strong) NSString *product_name;       //套餐名字
@property (nonatomic, assign) int32_t status;               //状态 1 正常 2 过期
@property (nonatomic, strong) NSString *status_desc;        //状态描述
@property (nonatomic, assign) int32_t card_id;              //已购买套餐id
@property (nonatomic, assign) int32_t enable_bind;          //是否允许绑定 1允许(购买者本人 不过期 不超绑定限制) 0不允许
@property (nonatomic, strong) NSString *last_order_id;      //": "1525934635724872640",
@property (nonatomic, strong) NSArray< MemberBindParent *> *bind_parent;    //已绑定家长姓名列表

@end

@interface MemberBindcardsResponse : NSObject
@property (nonatomic, assign) int32_t alisp_code; // 200 为成功
@property (nonatomic, strong) NSString *alisp_msg;
@property (nonatomic, strong) NSArray<MemberBindcard *> *alisp_data;
@end

NS_ASSUME_NONNULL_END
