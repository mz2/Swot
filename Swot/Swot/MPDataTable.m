//
//  MPNumericalDataSet.m
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import "MPDataTable.h"
#import "NSNumber+NumericalType.h"
#import "MPDataSet.h"

@interface MPDataTable ()
@property (readwrite, strong, nonatomic) NSMutableArray *data;
@property (readwrite, strong, nonatomic) NSArray *columnTypes;
@property (readwrite, strong, nonatomic) NSArray *columnNames;
@property (readwrite, strong, nonatomic) NSDictionary *columnNameMap;

/**
 *  A map of category names (keys) to category values (values).
 */
@property (readwrite, strong, nonatomic) NSMutableDictionary *categoryValues;

/**
 *  A map of column indices (keys) to category names (values).
 */
@property (readwrite, strong, nonatomic) NSMutableDictionary *categoryNames;

/**
 *  A map of column names (keys) with values being maps of category value string (key) to category value index (value).
 */
@property (readwrite, strong, nonatomic) NSMutableDictionary *categoryValueIndices;
@end

@interface MPDataTableRow ()
{
    NSArray *_columnTypes;
    __weak id<MPDataSet> _dataSet;
}

@property (readonly) NSMutableArray *values;
@property (weak, readwrite) id<MPDataSet> dataSet;

@end

#pragma mark - MPDataTable implementation

@implementation MPDataTable

- (NSArray *)datumArray
{
    return [_data copy];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"MPInvalidInitException"
                                   reason:@"Init with -initWithColumnTypes:datumCapacity:"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithColumnTypes:(NSArray *)columnTypes
{
    return [self initWithColumnTypes:columnTypes
                         columnNames:nil
                    labelColumnIndex:NSNotFound
                       datumCapacity:0];
}

- (instancetype)initWithColumnTypes:(NSArray *)columnTypes
                        columnNames:(NSArray *)columnNames
                   labelColumnIndex:(NSUInteger)labelColumnIndex
                      datumCapacity:(NSUInteger)capacity
{
    assert(capacity != NSNotFound);
    
    self = [super init];
    if (self) {
        _columnTypes = columnTypes;
        _columnNames = columnNames;
        
        if (columnNames) {
            // column names must be unique.
            assert([NSSet setWithArray:columnNames].count == columnNames.count);
            assert(columnNames.count == columnTypes.count);
            
            id keySet = [NSDictionary sharedKeySetForKeys:columnNames];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithSharedKeySet:keySet];
            for (NSUInteger i = 0; i < [columnNames count]; i++)
                dict[columnNames[i]] = @(i);
            
            _columnNameMap = [dict copy];
        }
        
        if (_columnNames)
            assert(_columnNames.count == _columnTypes.count);
        
        _data = [NSMutableArray arrayWithCapacity:capacity];
        
        _labelColumnIndex = labelColumnIndex;
        
        // check that the label column looks categorical.
        if (_labelColumnIndex != NSNotFound) {
            BOOL labelColumnIsCategorical =
                [_columnTypes[labelColumnIndex] unsignedIntegerValue] == MPColumnTypeCategorical;
            assert(labelColumnIsCategorical);
        }
    }
    return self;
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dict {
    NSArray *columnTypes = [dict objectForKey:@"columnTypes"];
    assert(columnTypes);
    
    NSArray *columnNames = [dict objectForKey:@"columnNames"];
    
    NSNumber *labelColumnIndexNum = [dict objectForKey:@"labelColumnIndex"];
    NSUInteger labelColumnIndex
        = labelColumnIndexNum ? [labelColumnIndexNum unsignedIntegerValue] : NSNotFound;
    
    NSArray *data = [dict objectForKey:@"data"];
    assert(data);
    
    self = [self initWithColumnTypes:columnTypes
                         columnNames:columnNames
                    labelColumnIndex:labelColumnIndex
                       datumCapacity:data.count];
    
    for (NSDictionary *rowDict in data) {
        id<MPDatum> row = [[MPDataTableRow alloc] initWithDictionaryRepresentation:rowDict];
        [self appendDatum:row];
    }
    
    return self;
}

- (NSUInteger)datumCount {
    return _data.count;
}

- (id<MPDatum>)datumAtIndex:(NSUInteger)i {
    return _data[i];
}

- (NSUInteger)columnCount {
    return [_columnTypes count];
}

- (NSArray *)arrayOfDictionariesRepresentation
{
    NSMutableArray *dicts = [NSMutableArray arrayWithCapacity:_data.count];
    for (id<MPDatum> datum in _data) {
        [dicts addObject:datum.dictionaryRepresentation];
    }
    return [dicts copy];
}

- (void)appendDatum:(id<MPDatum>)datum
{
    assert(_data);
    assert(_columnTypes);
    assert(!datum.dataSet);
    
    if (!_columnTypes)
        _columnTypes = datum.columnTypes;
    else
        assert([_columnTypes isEqualToArray:datum.columnTypes]);
    
    [_data addObject:datum];
    [(id)datum setDataSet:self];
}

- (NSArray *)columnTypes
{
    return _columnTypes;
}

- (MPColumnType)typeForColumn:(NSUInteger)index {
    return [_columnTypes[index] unsignedIntegerValue];
}

- (NSUInteger)indexForColumnWithName:(NSString *)columnName {
    assert(_columnNameMap);
    assert(_columnNameMap[columnName]);
    return [_columnNameMap[columnName] unsignedIntegerValue];
}

- (NSArray *)valuesForColumn:(NSUInteger)columnIndex {
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.datumCount];
    
    for (NSUInteger i = 0; i < self.datumCount; i++)
        [values addObject:[[self datumAtIndex:i] valueForColumn:columnIndex]];
    
    return [values copy];
}

- (BOOL)isLabelled {
    if (_labelColumnIndex != NSNotFound) {
        for (id<MPDatum> datum in _data) {
            if ([datum valueForColumn:_labelColumnIndex] != nil)
                return YES;
        }
    }
    
    return NO;
}

- (NSArray *)labelValues {
    assert(_labelColumnIndex != NSNotFound);
    NSString *labelName = [self categoryNameForColumnAtIndex:_labelColumnIndex];
    assert(labelName); // class label category has not been added, or category not assigned to the label column?
    
    return [self valuesForCategoryWithName:labelName];
}

- (NSString *)labelAtIndex:(NSUInteger)classLabelValueIndex {
    return [self labelValues][classLabelValueIndex];
}

- (MPDatumLabelIdentifier)labelIdentifierForDatum:(id<MPDatum>)datum {
    assert(_labelColumnIndex != NSNotFound);
    id v = [datum valueForColumn:_labelColumnIndex];
    assert(v); // remove assertion to allow missing labels in data.
    if (!v)
        return NSNotFound;
    
    NSString *labelName = [self categoryNameForColumnAtIndex:_labelColumnIndex];
    assert(labelName); // class label category has not been added, or category not assigned to the label column?
    
    return [self indexForCategoryValue:v forCategoryWithName:labelName];
}

- (NSUInteger)labelCount {
    return [self labelValues].count;
}

- (NSUInteger)featureCount {
    if (_labelColumnIndex != NSNotFound)
        return self.columnTypes.count;
    else
        return self.columnTypes.count - 1;
}

#pragma mark - Equality 

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (![object conformsToProtocol:@protocol(MPDataSet)]) return NO;
    
    return [self isEqualToDataSet:object];
}

- (BOOL)isEqualToDataSet:(id<MPDataSet>)dataSet {
    return [self.dictionaryRepresentation isEqualToDictionary:dataSet.dictionaryRepresentation];
}

#pragma mark - Categorical field handling

- (void)initializeCategoricalFieldSupport
{
    _categoryNames = [NSMutableDictionary dictionary];
    _categoryValues = [NSMutableDictionary dictionary];
    _categoryValueIndices = [NSMutableDictionary dictionary];
}

- (void)addCategoryWithName:(NSString *)category values:(NSArray *)values {
    assert(category);
    assert(values);
    
    if (!_categoryValues) {
        [self initializeCategoricalFieldSupport];
    }
    
    assert(!_categoryValues[category]);
    _categoryValues[category] = [[NSOrderedSet alloc] initWithArray:[values mutableCopy]];
    
    assert(!_categoryValueIndices[category]);
    
    NSMutableDictionary *valueIndexDict = [NSMutableDictionary dictionaryWithSharedKeySet:[NSDictionary sharedKeySetForKeys:values]];
    _categoryValueIndices[category] = valueIndexDict;
    for (NSUInteger i = 0; i < values.count; i++)
        valueIndexDict[@(i)] = values[i];
}

- (void)assignCategoryWithName:(NSString *)categoryName toColumnWithIndex:(NSUInteger)index {
    // will fail if -addCategoryWithName:values: has not been called at least once.
    assert(_categoryNames);
    
    assert(categoryName);
    assert(index >= 0 && index != NSNotFound);
    
    _categoryNames[@(index)] = [categoryName copy];
}

- (NSArray *)valuesForCategoryWithName:(NSString *)categoryName {
    return [[_categoryValues[categoryName] array] copy];
}

- (NSString *)categoryNameForColumnAtIndex:(NSUInteger)i {
    NSString *name = _categoryNames[@(i)];
    assert(name);
    return [name copy];
}

- (NSUInteger)indexForCategoryValue:(NSString *)value
                forCategoryWithName:(NSString *)categoryName {
    NSUInteger index = [_categoryValues[categoryName] indexOfObject:value];
    assert(index != NSNotFound);
    return index;
}

- (NSString *)nameForColumn:(NSUInteger)columnIndex {
    return _columnNames[columnIndex];
}

#pragma mark - Representations

- (NSDictionary *)dictionaryRepresentation {
    return @{ @"columnTypes": [_columnTypes copy],
                     @"data":[[_data valueForKey:@"dictionaryRepresentation"] copy] };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\n%@",
            [_columnNames componentsJoinedByString:@"\t"],
            [_data componentsJoinedByString:@"\n"]];
}

- (NSString *)CSVRepresentationWithDelimiter:(NSString *)delimiterString
                                quoteStrings:(BOOL)quote
                               includeHeader:(BOOL)includeHeader {
    NSMutableString *str = [NSMutableString string];
    
    // header
    if (includeHeader) {
        assert(_columnNames);
        if (quote) {
            for (id obj in _columnNames) {
                [str appendFormat:@"'%@'", obj];
            }
        } else {
            [str appendString:[_columnNames componentsJoinedByString:delimiterString]];
        }
        
        [str appendString:@"\n"];
    }
    
    // body
    for (id<MPDatum> row in _data) {
        [str appendString:[row CSVRepresentationWithDelimiter:delimiterString quoteStrings:quote]];
        [str appendString:@"\n"];
    }
    
    return str.copy;
}

@end

#pragma mark - MPRow implementation

@implementation MPDataTableRow

- (instancetype)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes
{
    assert(values);
    assert(columnTypes);
    
    assert(values.count == columnTypes.count);
    
    self = [super init];
    if (self) {
        _values = [values mutableCopy];
        _columnTypes = columnTypes;
        
        #ifdef DEBUG
        for (NSUInteger i = 0; i < _values.count; i++) {
            [values[i] isKindOfClass:
                [[self class] classForColumnType:
                    (MPColumnType)[_columnTypes[i] unsignedIntegerValue]]];
        }
        #endif
    }
    return self;
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictRep {
    assert(dictRep);
    
    NSArray *vals = [dictRep objectForKey:@"values"];
    NSArray *columnTypes = [dictRep objectForKey:@"columnTypes"];
    
    self = [self initWithValues:vals columnTypes:columnTypes];
    return self;
}

- (id)valueForColumn:(NSUInteger)index {
    id o = _values[index];
    
    // check that the value is consistent with its type.
    assert([o isKindOfClass:[[self class] classForColumnType:[self typeForColumn:index]]]);
    return o;
}

- (void)setValue:(id)value forColumn:(NSUInteger)index {
    assert(value != nil);
    _values[index] = value;
}

- (MPColumnType)typeForColumn:(NSUInteger)index {
    return (MPColumnType)[_columnTypes[index] unsignedIntegerValue];
}

- (NSArray *)columnTypes {
    return _columnTypes;
}

- (NSUInteger)columnCount {
    return _values.count;
}

- (void)setDataSet:(id<MPDataSet>)dataSet {
    assert(!_dataSet); // only call once.
    assert(dataSet); // only call to set the dataset.
    
    _dataSet = dataSet;
    
    if (_columnTypes)
        assert([_columnTypes isEqualToArray:dataSet.columnTypes]);
    else
        _columnTypes = dataSet.columnTypes;
}

- (id<MPDataSet>)dataSet {
    return _dataSet;
}

+ (Class)classForColumnType:(MPColumnType)columnType
{
    assert(columnType != MPColumnTypeUnknown);
    
    switch (columnType) {
        case MPColumnTypeIntegral:
            return [NSNumber class];
            break;
        case MPColumnTypeFloatingPoint:
            return [NSNumber class];
        case MPColumnTypeBinary:
            return [NSNumber class];
        case MPColumnTypeCategorical:
            return [NSString class];
        case MPColumnTypeCustomObject:
            return [NSObject class];
        default:
            @throw [NSException exceptionWithName:@"MPUnhandledColumnTypeException"
                                           reason:[NSString stringWithFormat:
                                                   @"Unhandled column type: %lu", columnType] userInfo:nil];
            break;
    }
    
    assert(false);
    return Nil;
}

#pragma mark - Representations

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableArray *reps = [NSMutableArray arrayWithCapacity:self.columnCount];
    for (NSUInteger i = 0; i < self.columnCount; i++) {
        if ([self typeForColumn:i] != MPColumnTypeCustomObject) {
            [reps addObject:[self valueForColumn:i]];
        }
        else {
            [reps addObject:[[self valueForColumn:i] dictionaryRepresentation]];
        }
    }
    return @{
                @"values":self.values,
                @"columnTypes":_columnTypes
            };
}

- (double *)realNumberRepresentationIncludingLabel:(BOOL)includingLabel
{
    NSUInteger labelColumnIndex = ((id<MPTrainableDataSet>)_dataSet).labelColumnIndex;
    
    // if we're excluding the label, there should be a label column defined to exclude.
    if (!includingLabel)
        assert(labelColumnIndex != NSNotFound);
    
    NSUInteger count = (includingLabel ? self.columnCount : self.columnCount - 1);
    double *reals = malloc(sizeof(double) * count);
    
    BOOL skippedLabelColumnEncountered = NO;
    
    for (NSUInteger i = 0; i < self.columnCount; i++) {
        
        MPColumnType type = [self.columnTypes[i] unsignedIntegerValue];
        assert(type != MPColumnTypeUnknown);
        
        // skip the label column.
        if (!includingLabel && i == labelColumnIndex) {
            assert(type == MPColumnTypeCategorical);
            skippedLabelColumnEncountered = YES;
            continue;
        }
        
        // columns after a skipped label column needs offsetting one to the left.
        NSInteger insertPos = skippedLabelColumnEncountered ? i - 1 : i;
        
        id val = self.values[i];
        
        switch (type) {
            case MPColumnTypeCategorical:{
                NSString *categoryName = [self.dataSet categoryNameForColumnAtIndex:i];
                NSUInteger catValIndex = [self.dataSet indexForCategoryValue:val forCategoryWithName:categoryName];
                reals[insertPos] = catValIndex;
                break;
            }
            case MPColumnTypeBinary:
            case MPColumnTypeIntegral:
            case MPColumnTypeFloatingPoint:
            {
                reals[insertPos] = [val floatValue];
                break;
            }
            case MPColumnTypeCustomObject:
            {
                assert([val conformsToProtocol:@protocol(MPDatumEncodable)]);
                reals[insertPos] = [val realValueRepresentation];
                break;
            }
            default:
            {
                @throw [NSException exceptionWithName:@"MPInvalidColumnTypeException"
                                               reason:[NSString stringWithFormat:@"Invalid column type %lu", type]
                                             userInfo:@{}];
            }
        }
    }
    
    return reals;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (![object conformsToProtocol:@protocol(MPDatum)]) return NO;
    
    return [self isEqualToDatum:object];
}

- (BOOL)isEqualToDatum:(id<MPDatum>)object {
    // this is costly but has the upside that it's accurate irrespective of implementation.
    return [self.dictionaryRepresentation isEqualToDictionary:object.dictionaryRepresentation];
}

- (NSString *)description {
    return [_values componentsJoinedByString:@"\t\t"];
}

- (NSString *)CSVRepresentationWithDelimiter:(NSString *)delimiterString
                               quoteStrings:(BOOL)quote {
    NSArray *vs = nil;
    if (quote) {
        NSMutableArray *vals = [NSMutableArray arrayWithCapacity:_values.count];
        for (id obj in _values) {
            if ([obj isKindOfClass:[NSString class]])
                [vals addObject:[NSString stringWithFormat:@"'%@'",obj]];
            else
                [vals addObject:obj];
        }
        vs = vals;
    } else {
        vs = _values;
    }
    
    return [vs componentsJoinedByString:delimiterString];
}

@end