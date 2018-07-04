//
//  ALIAS.h
//  NewStructure
//
//  Created by 7 on 13/09/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#pragma mark - OCMock

//  * 用Mock建立对象、对象依赖关系
//  * 用Assertion验证数据有效性
//  * 用Verify验证对象行为
//  * 用Stub踪方法的调用，在方法调用的时候返回指定的值

#import <OCMock/OCMock.h>

//  OCMock-usage: http://www.jianshu.com/p/09bd2ace8610
//  OCMock-understand: http://www.cnblogs.com/lovewx/archive/2015/07/27/4680029.html

//  Mock
#define mockClass( _class_ )           OCMClassMock( _class_ )
#define mockProtocol( _proto_ )        OCMProtocolMock( _proto_ )
#define mockPartial( _object_ )        OCMPartialMock( _object_ )


//

#define forceFail( ... )                    XCTFail( __VA_ARGS__ )
#define expectNil( __exp__, ... )           XCTAssertNil( __exp__, __VA_ARGS__ )
#define expectNotNil( __exp__, ... )        XCTAssertNotNil( __exp__, __VA_ARGS__ )
#define expectTrue( __exp__, ... )          XCTAssertTrue( __exp__, __VA_ARGS__ )
#define expectFalse( __exp__, ... )         XCTAssertFalse( __exp__, __VA_ARGS__ )

// about equal
#define expectEqualObjects( __exp1__, __exp2__, ... )            XCTAssertEqualObjects(__exp1__, __exp2__, __VA_ARGS__ )
#define expectNotEqualObjects( __exp1__, __exp2__, ... )            XCTAssertNotEqualObjects(__exp1__, __exp2__, __VA_ARGS__ )

// about ==, !=
#define expectEqual( __exp1__, __exp2__, ... )            XCTAssertEqual(__exp1__, __exp2__, __VA_ARGS__ )
#define expectNotEqual( __exp1__, __exp2__, ... )            XCTAssertNotEqual(__exp1__, __exp2__, __VA_ARGS__ )

// about == ~ min < accuracy < max
#define expectEqualAccuracy( __min__, __max__, __val__, ... )            XCTAssertEqualWithAccuracy(__min__, __max__, __val__, __VA_ARGS__)
#define expectNotEqualAccuracy( __min__, __max__, __val__, ... )            XCTAssertNotEqualWithAccuracy(__min__, __max__, __val__, __VA_ARGS__)

// comparison
#define expectGreaterThan( __exp1__, __exp2__, ... )            XCTAssertGreaterThan(__exp1__, __exp2__, __VA_ARGS__ )
#define expectGreaterThanOrEqual( __exp1__, __exp2__, ... )            XCTAssertGreaterThanOrEqual(__exp1__, __exp2__, __VA_ARGS__ )
#define expectLessThan( __exp1__, __exp2__, ... )            XCTAssertLessThan(__exp1__, __exp2__, __VA_ARGS__ )
#define expectLessThanOrEqual( __exp1__, __exp2__, ... )            XCTAssertLessThanOrEqual(__exp1__, __exp2__, __VA_ARGS__ )

// exception
#define expectThrows( __exp__, ... )              XCTAssertThrows( __exp__, __VA_ARGS__ )
#define expectThrowsSpecific( __exp__, __cls__, ... )  XCTAssertThrowsSpecific(__exp__, __cls__, __VA_ARGS__ )
#define expectNotThrows( __exp__, ... )              XCTAssertNotThrows( __exp__, __VA_ARGS__ )
#define expectNotThrowsSpecific( __exp__, __cls__, ... )  XCTAssertNotThrowsSpecific(__exp__, __cls__, __VA_ARGS__ )










