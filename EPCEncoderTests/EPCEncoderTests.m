//
//  EPCEncoderTests.m
//  EPCEncoderTests
//
//  Created by Tim.Milne on 4/27/15.
//  Copyright (c) 2015 Tim.Milne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "EPCENcoder.h"

@interface EPCEncoderTests : XCTestCase

@end

@implementation EPCEncoderTests {
    EPCEncoder *_encode;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // Have we done this before
    _encode = [EPCEncoder alloc];
    
    // Initialize the EPCEncoder object
    [_encode withDpt:@"281" cls:@"00" itm:@"8570" ser:@"12345"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAll {
    // Test all the encodings
    XCTAssertEqualObjects([_encode sgtin_uri], @"urn:epc:tag:sgtin-96:1.04928100.08570.12345", @"Failed: SGTIN_URI");
    XCTAssertEqualObjects([_encode sgtin_hex], @"3030259932085E8000003039", @"Failed: SGTIN_Hex");
    XCTAssertEqualObjects([_encode sgtin_bin], @"001100000011000000100101100110010011001000001000010111101000000000000000000000000011000000111001", @"Failed: SGTIN_Bin");
    
    XCTAssertEqualObjects([_encode giai_uri], @"urn:epc:tag:giai-96:0.49281008570.12345", @"Failed: GIAI_URI");
    XCTAssertEqualObjects([_encode giai_hex], @"34056F2C1077400000003039", @"Failed: GIAI_Hex");
    XCTAssertEqualObjects([_encode giai_bin], @"001101000000010101101111001011000001000001110111010000000000000000000000000000000011000000111001", @"Failed: GIAI_Bin");
    
    XCTAssertEqualObjects([_encode gid_uri], @"urn:epc:tag:gid-96:04928100.0085702.12345", @"Failed: GID_URI");
    XCTAssertEqualObjects([_encode gid_hex], @"3504B3264014EC6000003039", @"Failed: GID_Hex");
    XCTAssertEqualObjects([_encode gid_bin], @"001101010000010010110011001001100100000000010100111011000110000000000000000000000011000000111001", @"Failed: GID_Bin");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
