//
//  MPTrainableDataSet.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPTrainingInstructions.h"

/**
 *  Represents the type of a column of data.
 */
typedef NS_ENUM(NSUInteger, MPColumnType) {
    MPColumnTypeUnknown = 0,
    MPColumnTypeCategorical = 1,
    MPColumnTypeIntegral = 2,
    MPColumnTypeFloatingPoint = 3,
    MPColumnTypeBinary = 4,
    MPColumnTypeCustomObject = 5
};

@protocol MPDatum;

/**
 * Represents objects that can be thought of as a set of rows & column.
 */
@protocol MPDataSet <NSObject>

@property (readonly, copy) NSArray *arrayOfDictionariesRepresentation;

@property (readonly) NSUInteger datumCount;

@property (readonly) NSUInteger columnCount;

/**
 *  The column types of all datum entries in a data set must match that of the data set.
 */
@property (readonly, nonatomic) NSArray *columnTypes;

- (id<MPDatum>)datumAtIndex:(NSUInteger)i;

- (void)appendDatum:(id<MPDatum>)datum;

/**
 * All the possible values of a category with the given name,
 * in its natural sorting order. Must not be called on a non-existent category.
 */
- (NSArray *)valuesForCategoryWithName:(NSString *)categoryName;

/**
 * The index of the category value for the category with the given name.
 */
- (NSUInteger)indexForCategoryValue:(NSString *)value
                forCategoryWithName:(NSString *)categoryName;

/**
 *  The name of the category for a column at specified index. 
 *  Must not be called on non-categorical columns.
 */
- (NSString *)categoryNameForColumnAtIndex:(NSUInteger)i;

/**
 * Adds a category with the specified name to the data set. 
 * Categories are unique by their name, so one should not attempt to add a category with an already added category name multiple times.
 */
- (void)addCategoryWithName:(NSString *)categoryName values:(NSArray *)values;

/**
 * Assigns a column to a category with the specified name.
 * Should only be called after the category with the specified name has been added with -addCategoryWithName:values: .
 */
- (void)assignCategoryWithName:(NSString *)categoryName toColumnWithIndex:(NSUInteger)index;

/**
 *  Values for column.
 */
- (NSArray *)valuesForColumn:(NSUInteger)columnIndex;

/**
 *  Value for column name. Optional, only required by the dimension mapper. Column name, as opposed to the category name, must be unique.
 */
- (NSString *)nameForColumn:(NSUInteger)columnIndex;

/**
 *  Type for the column. Required to return a value other than MPColumnTypeUnknown for all valid inputs.
 */
- (MPColumnType)typeForColumn:(NSUInteger)index;

/** The index of column with the given name. There is to be only one column with a given name in a dataset. */
- (NSUInteger)indexForColumnWithName:(NSString *)columnName;

/**
 * A dictionary representation of the data set.
 * Includes two required keys 'columnTypes' and 'data', both with array typed values.
 */
@property (readonly, copy) NSDictionary *dictionaryRepresentation;

@end

#pragma mark - Trainable dataset

/**
 *  A data set which conforms to MPTrainingInstructions can be used for training a classifier.
 */
@protocol MPTrainableDataSet <MPDataSet, MPTrainingInstructions>

/**
 *  Whether or not the dataset has a defined label column, 
 * and at least one datum with a non-missing label value.
 */
@property (readonly) BOOL isLabelled;

/**
 * A dictionary representation of the data set.
 * Includes optional key 'labelColumnIndex' with an unsigned integral value, as well as those required by MPDataSet -dictionaryRepresentation.
 */
@property (readonly, copy) NSDictionary *dictionaryRepresentation;

- (NSString *)CSVRepresentationWithDelimiter:(NSString *)delimiterString
                                quoteStrings:(BOOL)quote
                               includeHeader:(BOOL)includeHeader;
@end

#pragma mark - Datum

/**
 *  Represents objects that can be thought of as a single row in a data set.
 */
@protocol MPDatum <NSObject>

/**
 *  Back-pointer to the datum's data set. This should be set only once and only by the data set.
 */
@property (weak, readonly) id<MPDataSet> dataSet;
@property (readonly) NSUInteger columnCount;

@property (readonly, copy) NSDictionary *dictionaryRepresentation;

/**
 *  The column types for the datum. All the datum entries in a data set must have equal columnTypes.
 */
@property (readonly) NSArray *columnTypes;

/**
 *  Returns the value for the column, or [NSNull null] for missing entries.
 */
- (id)valueForColumn:(NSUInteger)index;

/**
 *  Sets the value for the column at specified index. Use [NSNull null] for missing entries.
 */
- (void)setValue:(id)value forColumn:(NSUInteger)index;

- (instancetype)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes;

/**
 * The storage class for the column type.
 * Must return a non-Nil value for all values but MPColumnTypeUnknown.
 */
+ (Class)classForColumnType:(MPColumnType)columnType;


@optional

/**
 * A double array representation of the datum's values.
 * WARNING! The client is responsible for freeing the array.
 *
 * Categorical and binary values are to be encoded using the ALGLIB nominal value encoding.
 * http://www.alglib.net/dataanalysis/generalprinciples.php#nominal
 */
- (double *)realNumberRepresentationIncludingLabel:(BOOL)includingLabel;

- (NSString *)CSVRepresentationWithDelimiter:(NSString *)delimiterString
                                quoteStrings:(BOOL)escape;
/**
 * A contextual value that the datum is related to 
 * (e.g. the source datum from which a transformer created a target datum.)
 */
@property (weak) id objectValue;

@end


#pragma mark - Datum encodable

/** Custom objects included as column values in datum entries must conform to this. */
@protocol MPDatumEncodable <NSObject>

/** Initialises using a dictionary representation. */
- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dict;

/** Returns a JSON encodable dictionary representation of the object. */
- (NSDictionary *)dictionaryRepresentation;

/** Returns a real value representation for the object. */
- (float)realValueRepresentation;

@end

