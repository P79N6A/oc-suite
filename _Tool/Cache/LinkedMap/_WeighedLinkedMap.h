//
//  _WeighedLinkedMap.h
//  _Tool
//
//  Created by 7 on 2018/9/13.
//

#import "_LinkedMap.h"
#import "_LinkedMapProtocol.h"

@interface _WeighedLinkedMap : _LinkedMap <_LinkedMapProtocol> {
    _LinkedMapNode *_hook; // 指向链表中命中次数为1 且最新的元素
}

@end


@interface _WeighedLinkedMapNode : _LinkedMapNode {
    @package
    int32_t _hits; // 命中次数
}
@end

