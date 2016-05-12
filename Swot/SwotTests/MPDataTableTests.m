//
//  MPDataTableTests.m
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPDataSet.h"
#import "MPDataTable.h"
#import "MPDataSetTransformer.h"
#import "MPAbstractTransformer.h"

@interface MPBooleanInverterTransformer : MPAbstractTransformer
@end

@implementation MPBooleanInverterTransformer
@end

@interface MPDataTableTests : XCTestCase

@end

@implementation MPDataTableTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDataTableCreation
{
    NSArray *columnTypes = @[@(MPColumnTypeCategorical), @(MPColumnTypeBinary)];
    MPDataTable *tbl = [[MPDataTable alloc] initWithColumnTypes:columnTypes];
    [tbl appendDatum:[[MPDataTableRow alloc] initWithValues:@[(@"foo"), @(YES)]
                                       columnTypes:columnTypes]];
    XCTAssertTrue(tbl.datumCount == 1, @"Datum count matches expectation.");
    
    id<MPDatum> firstDatum = [tbl datumAtIndex:0];
    
    XCTAssertTrue([[firstDatum valueForColumn:0] isKindOfClass:[NSString class]],
                  @"First datum of first row is of type NSString");
    
    XCTAssertTrue([[[firstDatum class] classForColumnType:[firstDatum.dataSet typeForColumn:0]]
                   isSubclassOfClass:[NSString class]],
                  @"First datum's -classForColumnType: is of the expected class for 1st column (NSString)");

    XCTAssertTrue([[[firstDatum class] classForColumnType:[firstDatum.dataSet typeForColumn:1]]
                   isSubclassOfClass:[NSNumber class]],
                  @"First datum's -classForColumnType: is of the expected class for 2nd column (NSNumber)");

    XCTAssertTrue(tbl.columnTypes == tbl.columnTypes, @"Column types array was retained by tbl.");
    
    [tbl appendDatum:[[MPDataTableRow alloc] initWithValues:@[@"bar", @(NO)] columnTypes:tbl.columnTypes]];
    
    XCTAssertTrue(tbl.datumCount == 2, @"Datum count matches expectation.");
    
    BOOL firstColValuesMatchExpectation = [[tbl valuesForColumn:0] isEqualToArray:@[@"foo", @"bar"]];
    XCTAssertTrue(firstColValuesMatchExpectation, @"The data entries are as expected.");

    BOOL secondColValuesMatchExpectation = [[tbl valuesForColumn:1] isEqualToArray:@[@(YES), @(NO)]];
    XCTAssertTrue(secondColValuesMatchExpectation,
                  @"The data entries on 2nd column are as expected.");
}

- (void)testDataTableDictionaryRepresentation {
    NSArray *columnTypes = @[@(MPColumnTypeCategorical), @(MPColumnTypeBinary)];
    MPDataTable *tbl = [[MPDataTable alloc] initWithColumnTypes:columnTypes];
    [tbl appendDatum:
        [[MPDataTableRow alloc] initWithValues:@[(@"foo"), @(YES)]
                          columnTypes:columnTypes]];
    [tbl appendDatum:
        [[MPDataTableRow alloc] initWithValues:@[@"bar", @(NO)]
                          columnTypes:tbl.columnTypes]];
    
    NSDictionary *dict = [tbl dictionaryRepresentation];
    XCTAssert([dict[@"columnTypes"] isEqualToArray:tbl.columnTypes], @"Contains expected value with key 'columnTypes'");
    
    MPDataTable *tbl2 = [[MPDataTable alloc] initWithDictionaryRepresentation:dict];
    
    XCTAssert([tbl isEqual:tbl2], @"Data table makes a successful roundtrip.");
    
    XCTAssertTrue(tbl2.datumCount == 2, @"Datum count matches expectation.");
    
    BOOL firstColValuesMatchExpectation = [[tbl2 valuesForColumn:0] isEqualToArray:@[@"foo", @"bar"]];
    XCTAssertTrue(firstColValuesMatchExpectation, @"The data entries are as expected.");
    
    BOOL secondColValuesMatchExpectation = [[tbl2 valuesForColumn:1] isEqualToArray:@[@(YES), @(NO)]];
    XCTAssertTrue(secondColValuesMatchExpectation,
                  @"The data entries on 2nd column are as expected.");
}

@end
