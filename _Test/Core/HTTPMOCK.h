//
//  HTTPMOCK.h
//  NewStructure
//
//  Created by 7 on 21/09/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_HttpMock.h"

/** http mock 说明 */
/** 1. request对等条件：HTTP方法类型、HTTP URL、HTTP头、HTTP体都相同 */

/** http mock 单例 实例 */
#define HTTPMOCK    [_HttpMock sharedInstance]

/** http method */
#define HTTP_GET    @"GET"
#define HTTP_POST   @"POST"
#define HTTP_PUT    @"PUT"
