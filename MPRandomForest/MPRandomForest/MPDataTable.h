//
//  MPNumericalDataSet.h
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDataSet.h"

/**
 * A concrete implementation of MPTrainableDataSet: a dataset that can be used for training a datum classifier.
 * Before the object can be used with a datum classifier, you must add and assign all the categorical fields to the data set.
 */
@interface MPDataTable : NSObject <MPTrainableDataSet>

/**
 *  Creates an empty dataset with the specified column types (all datum entries must have matching column types), an optional, and optionally an expected capacity.
 *
 *  @param columnTypes An array of unsigned integers with values from the MPColumnType enum.
 *  @param columnNames An array of column names (optional, pass nil if you want to omit, otherwise must match the length of columnTypes).
 *  @param labelColumnIndex An index for a class label column amongst the column types. Must be a categorical field. Pass in NSNotFound if the data is not intended labelled.
 *  @param capacity A positive integer, or 0 if expected required capacity not known.
 */
- (instancetype)initWithColumnTypes:(NSArray *)columnTypes
                        columnNames:(NSArray *)columnNames
                   labelColumnIndex:(NSUInteger)labelColumnIndex
                      datumCapacity:(NSUInteger)capacity;

/**
 *  Initialises a data table from a dictionary formatted like the class's -dictionaryRepresentation. 
 */
- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictRep;

/**
 *  A shorthand for -initWithColumnTypes:columnTypes columnNames:nil labelColumnIndex:NSNotFound datumCapacity:0
 */
- (instancetype)initWithColumnTypes:(NSArray *)columnTypes;

/**
 *  An array of id<MPDatum> instances.
 */
@property (readonly, copy) NSArray *datumArray;

/**
  * Appends a datum into the dataset.
  *
  * The first datum has a special meaning: it is used to check that subsequent rows have similar array of column types.
  */
- (void)appendDatum:(id<MPDatum>)datum;

@property (readonly) NSUInteger labelColumnIndex;

/**
 *  Output a CSV / TSV like string with a configurable delimiter and quoting and an optional header.
 *
 *  @param delimiterString The delimiter string to use, for instance @"\t" for tab delimited files, @"," for comma separated.
 *  @param quote YES will cause single quotes to be included around all string typed values in the output (including headers if included), pass NO for values printed as-is.
 *  @param includeHeader YES will cause a header line to be output, NO will skip the header. Use YES only if column names have been specified.
 */
- (NSString *)CSVRepresentationWithDelimiter:(NSString *)delimiterString
                                quoteStrings:(BOOL)quote
                               includeHeader:(BOOL)includeHeader;

@end

@interface MPDataTableRow : NSObject <MPDatum>

/**
  * Initialises a row with the given values and column types.
  * Both the 'values' and 'columnTypes' arguments are required.
  * 
  * Value can be either a plist / JSON encodable type from Cocoa, or a custom object type
  * which implements the MPDatumEncodable protocol.
  */
- (instancetype)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes;

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictRep;

- (NSString *)CSVRepresentationWithDelimiter:(NSString *)delimiterString
                               quoteStrings:(BOOL)escape;

@end