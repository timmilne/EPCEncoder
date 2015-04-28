//
//  ConverterTests.m
//  EPCEncoder
//
//  Created by Tim.Milne on 4/27/15.
//  Copyright (c) 2015 Tim.Milne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Converter.h"

@interface ConverterTests : XCTestCase

@end

@implementation ConverterTests {
    Converter *_convert;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _convert = [Converter alloc];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDec2Bin {
    // Test the Decimal to Binary converter
    XCTAssertEqualObjects([_convert Dec2Bin:@"04928100"], @"010010110011001001100100", @"Failed: Dec2Bin");
}

- (void)testBin2Dec {
    // Test the Binary to Decimal converter
    XCTAssertEqualObjects([_convert Bin2Dec:@"010010110011001001100100"], @"4928100", @"Failed: Bin2Dec");
}

- (void)testDec2Hex {
    // Test the Decimal to Hexadecimal converter
    XCTAssertEqualObjects([_convert Dec2Hex:@"04928100"], @"4B3264", @"Failed: Dec2Hex");
}

- (void)testHec2Dex {
    // Test the Hexadecimal to Decimal converter
    XCTAssertEqualObjects([_convert Hex2Dec:@"4B3264"], @"4928100", @"Failed: Hex2Dec");
}

- (void)testHex2Bin{
    // Test the Hexadecimal to Binary converter
    XCTAssertEqualObjects([_convert Hex2Bin:@"4B3264"], @"010010110011001001100100", @"Failed: Hex2Bin");
}

- (void)testBin2Hex {
    // Test the Binary to Hexadecimal converter
    XCTAssertEqualObjects([_convert Bin2Hex:@"010010110011001001100100"], @"4B3264", @"Failed: Bin2Hex");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
