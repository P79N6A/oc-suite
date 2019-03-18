
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 * Block 预定义
 */

/**
 @knowledge
 
 *  避免滥用block
 
 *  好处：定义简单，并可以捕获上下文变量，还有大部分时候，便于代码顺序阅读
 
 *  滥用：
 1. 忽视循环引用（相反，delegate会比较安全）
 2. 对block生命周期不熟悉，多见于多线程情况下。
 3. 复杂逻辑用多层block嵌套实现，导致调试困难
 */

typedef void(^ Block)( void );
typedef void(^ BlockBlock)( _Nullable Block block );
typedef void(^ BOOLBlock)( BOOL b );
typedef void(^ ObjectBlock)( _Nullable id obj );
typedef void(^ ArrayBlock)( NSArray * _Nullable array );
typedef void(^ MutableArrayBlock)( NSMutableArray * _Nullable array );
typedef void(^ DictionaryBlock)( NSDictionary *_Nullable dic );
typedef void(^ ErrorBlock)( NSError * _Nullable error );
typedef void(^ IndexBlock)( NSInteger index );
typedef void(^ ListItemBlock)( NSInteger index, id _Nullable param );
typedef void(^ FloatBlock)( CGFloat afloat );
typedef void(^ StringBlock)( NSString * _Nullable str );
typedef void(^ ImageBlock)( UIImage * _Nullable image );
typedef void(^ ProgressBlock)( NSProgress * _Nullable progress );
typedef void(^ PercentBlock)( double percent); // 0~100

typedef void(^ Event)( id _Nullable event, NSInteger type, id _Nullable object );

typedef void(^ CancelBlock)( id _Nullable viewController );
typedef void(^ FinishedBlock)( id _Nullable viewController, id _Nullable object );

typedef void(^ SendRequestAndResendRequestBlock)( id _Nullable sendBlock, id _Nullable resendBlock);

/*
 * 结构定义
 */

/**
 操作类型：OperationType
 操作类型可用key：如下
 */
#define OperationTypeKey @"key.OperationType"
typedef enum : NSUInteger {
    OperationAdd = 0,
    OperationDelete,
    OperationEdit,
    OperationQuery,
} _OperationType;

typedef enum {
    HttpMethodGet = 0,
    HttpMethodPost = 1,
    HttpMethodDelete = 2
} _HttpMethodType;
