//
//  MPNumberNumericalTypeCategoryTests.m
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSNumber+NumericalType.h"

@interface MPNumberNumericalTypeCategoryTests : XCTestCase

@end

@implementation MPNumberNumericalTypeCategoryTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}


- (void)testNumberExtension
{
    XCTAssertTrue([@(YES) isBOOL],
                  @"A boxed YES literal is detected as a BOOL.");
    XCTAssertTrue([@(NO) isBOOL],
                  @"A boxed NO literal is detected as a BOOL.");
    
    XCTAssertTrue(![@(YES) isIntegral],
                  @"A boxed YES literal is NOT detected as integral.");
    XCTAssertTrue(![@(NO) isIntegral],
                  @"A boxed NO literal is detected as integral.");
    
    XCTAssertTrue([@(1) isIntegral],
                  @"A boxed 1 literal is detected as integral.");
    XCTAssertTrue(![@(1) isFloatingPoint],
                  @"A boxed 1 literal is not detected as floating point.");
    XCTAssertTrue(![@(1) isBOOL],
                  @"A boxed 1 literal is not detected as floating point.");
    
    XCTAssertTrue(![@(1.04) isBOOL],
                  @"A boxed 1.04 literal is NOT detected as BOOL.");
    XCTAssertTrue(![@(1.04) isIntegral],
                  @"A boxed 1.04 literal is NOT detected as integral.");
    XCTAssertTrue([@(1.04) isFloatingPoint],
                  @"A boxed 1.04 literal is detected as floating point.");
}
@end
