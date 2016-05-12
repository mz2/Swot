//
//  MPAbstractDimensionMapper.m
//  MPRandomForest
//
//  Created by Matias Piipari on 26/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import "MPNamedColumnDimensionMapper.h"
#import "MPDimensionMapper.h"

#import "MPDataSet.h"
#import "MPDataTable.h"

#import "NSString+CamelCase.h"

@interface MPNamedColumnDimensionMapper () {
    NSArray *_mappedColumnTypes;
    NSArray *_mappedColumnIndices;
    NSArray *_mappedColumnNames;
    
    NSUInteger _labelColumnIndex;
}
@end

@implementation MPNamedColumnDimensionMapper

- (instancetype)initWithDataSet:(id<MPTrainableDataSet>)dataSet
{
    self = [super init];
    if (self) {
        _inputDataSet = dataSet;
        _labelColumnIndex = NSNotFound;
    }
    return self;
}

#pragma mark -

- (id<MPDataSet>)mappedDataSet {
    NSUInteger mappedDim = 0;
    NSUInteger inputLabelColumn = [_inputDataSet labelColumnIndex];
    NSMutableArray *columnIndices = [NSMutableArray arrayWithCapacity:_inputDataSet.columnCount];
    
    // map the column index values.
    for (NSUInteger i = 0; i < _inputDataSet.columnCount; i++) {
        NSUInteger dimForI = [self mappedDimensionalityForColumnAtInputDataSetIndex:i];

        // NSNotFound checking not needed
        // (i on the range 0..columnCount does not contain NSNotFound)
        if (i == inputLabelColumn) {
            // label column should not have changed on subsequent calls.
            assert(_labelColumnIndex == NSNotFound || _labelColumnIndex == mappedDim);
            _labelColumnIndex = mappedDim;
            
            assert(dimForI == 1); // label column cannot be mapped to multiple output columns.
        }
        
        for (NSUInteger m = mappedDim; m < mappedDim + dimForI; m++) {
            NSValue *rangeVal = [NSValue valueWithRange:NSMakeRange(mappedDim, dimForI)];
            [columnIndices addObject:rangeVal];
        }
        
        mappedDim += dimForI;
        
    }
    
    // TODO: make these checks DEBUG only when _mappedDimensionality / _mappedColumnTypes already found.
    
    // if data set is being requested subsequent times, dimensionality should not have changed.
    if (_mappedDimensionality > 0)
        assert(_mappedDimensionality == mappedDim);
    _mappedDimensionality = mappedDim;
    
    NSMutableArray *columnTypes = [NSMutableArray arrayWithCapacity:_mappedDimensionality];
    NSMutableArray *columnNames = [NSMutableArray arrayWithCapacity:_mappedDimensionality];
    for (NSUInteger i = 0; i < _inputDataSet.columnCount; i++) {
        [columnTypes addObjectsFromArray:[self columnTypesForMappedDimensionsForColumn:i]];
        [columnNames addObjectsFromArray:[self columnNamesForMappedDimensionsForColumn:i]];
    }
    _mappedColumnTypes = columnTypes;
    _mappedColumnNames = columnNames;
    
    // map the actual data
    MPDataTable *tbl = [[MPDataTable alloc] initWithColumnTypes:_mappedColumnTypes
                                                    columnNames:_mappedColumnNames
                                               labelColumnIndex:_labelColumnIndex
                                                  datumCapacity:_inputDataSet.datumCount];
    
    for (NSUInteger i = 0, cnt = _inputDataSet.datumCount; i < cnt; i++) {
        [tbl appendDatum:[self mappedDatum:i mappedDataSet:tbl]];
    }
    
    // FIXME: add support for categorical => categorical mapping.
    // FIXME: add support for mapping input labels rather than just translating them.
    
    NSString *labelColumnName
        = [_inputDataSet categoryNameForColumnAtIndex:[_inputDataSet labelColumnIndex]];
    NSArray *labelValues
        = [_inputDataSet valuesForColumn:[_inputDataSet labelColumnIndex]];
    
    [tbl addCategoryWithName:labelColumnName values:labelValues];
    [tbl assignCategoryWithName:labelColumnName toColumnWithIndex:_labelColumnIndex];
     
    return tbl;
}

- (id<MPDatum>)mappedDatum:(NSUInteger)datumIndex mappedDataSet:(id<MPDataSet>)mappedDataSet {
    NSUInteger colCount = _inputDataSet.columnCount;
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:mappedDataSet.columnCount];
    for (NSUInteger i = 0; i < colCount; i++) {
        NSArray *vals = [self valuesForMappedDimensionsForDatum:datumIndex column:i];
        assert(vals);
        [data addObjectsFromArray:vals];
    }
    
    return [[MPDataTableRow alloc] initWithValues:data columnTypes:mappedDataSet.columnTypes];
}

#pragma mark - Generic index / name mapping

- (NSArray *)mappedValueForDatum:(id<MPDatum>)datum columnName:(NSString *)name
singleArgumentSelectorWithFormat:(NSString *)selectorPattern {
    assert(name);
    NSString *selStr = [NSString stringWithFormat:selectorPattern, name.camelCasedString];
    SEL sel = NSSelectorFromString(selStr);
    if (!sel) {
        @throw [NSException exceptionWithName:@"MPMissingValueAccessorMethodException"
                                       reason:[NSString stringWithFormat:@"Missing instance method %@", selStr] userInfo:nil];
    }
    assert(sel); // must be a string that gives a valid selector.
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:sel]];
    invocation.target = self;
    invocation.selector = sel;
    
    NSUInteger columnIndex = [datum.dataSet indexForColumnWithName:name];
    assert(columnIndex != NSNotFound);
    
    id value = [datum valueForColumn:columnIndex];
    assert(value);
    
    [invocation setArgument:&value atIndex:2]; // datum is first & only non-hidden arg.
    [invocation retainArguments];
    
    __unsafe_unretained id retVal;
    [invocation invoke];
    [invocation getReturnValue:&retVal];
    
    // do we need a __bridge_retain?
    return retVal;
}


- (NSArray *)mappedArrayValueForColumnName:(NSString *)name
          argumentlessSelectorPattern:(NSString *)selectorPattern {
    assert(name);
    NSString *selStr = [NSString stringWithFormat:selectorPattern, name.camelCasedString];
    SEL sel = NSSelectorFromString(selStr);
    if (!sel) {
        @throw [NSException exceptionWithName:@"MPMissingValueAccessorMethodException"
                                       reason:[NSString stringWithFormat:@"Missing instance method %@", selStr] userInfo:nil];
    }
    assert(sel); // must be a string that gives a valid selector.
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:sel]];
    invocation.target = self;
    invocation.selector = sel;
    
    __unsafe_unretained id retVal;
    [invocation invoke];
    [invocation getReturnValue:&retVal];
    
    // do we need a __bridge_retain?
    return retVal;
}

- (NSUInteger)mappedUnsignedIntegerValueForColumnName:(NSString *)name
                          argumentlessSelectorPattern:(NSString *)selectorPattern {
    assert(name);
    NSString *selStr = [NSString stringWithFormat:selectorPattern, name.camelCasedString];
    SEL sel = NSSelectorFromString(selStr);
    if (!sel) {
        @throw [NSException exceptionWithName:@"MPMissingValueAccessorMethodException"
                                       reason:[NSString stringWithFormat:@"Missing instance method %@", selStr] userInfo:nil];
    }
    assert(sel); // must be a string that gives a valid selector.
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:sel]];
    invocation.target = self;
    invocation.selector = sel;
    
    NSUInteger retVal;
    [invocation invoke];
    [invocation getReturnValue:&retVal];
    
    return retVal;
}

#pragma mark - Column value mapping

- (NSArray *)valuesForMappedDimensionsForDatum:(NSUInteger)datumI column:(NSUInteger)column {
    id<MPDatum> datum = [_inputDataSet datumAtIndex:datumI];
    NSString *name = [_inputDataSet nameForColumn:column]; assert(name);
        
    return [self mappedValueForDatum:datum
                          columnName:name
    singleArgumentSelectorWithFormat:@"mapped%@ValuesForDatumValue:"];
}

#pragma mark - Column type mapping

- (NSArray *)columnTypesForMappedDimensionsForColumn:(NSUInteger)column {
    NSString *name = [_inputDataSet nameForColumn:column]; assert(name);
    return [self mappedArrayValueForColumnName:name
                   argumentlessSelectorPattern:@"mappedColumnTypesFor%@"];
}

#pragma mark - Column name mapping

- (NSArray *)columnNamesForMappedDimensionsForColumn:(NSUInteger)index {
    NSString *name = [_inputDataSet nameForColumn:index]; assert(name);
    return [self mappedArrayValueForColumnName:name
                   argumentlessSelectorPattern:@"mappedColumnNamesFor%@"];
}

#pragma mark - Dimensionality mapping

- (NSUInteger)mappedDimensionalityForColumnAtInputDataSetIndex:(NSUInteger)index {
    NSString *name = [_inputDataSet nameForColumn:index]; assert(name);
    return [self mappedUnsignedIntegerValueForColumnName:name argumentlessSelectorPattern:@"mappedDimensionalityFor%@"];
}

@end