//
//  MPDimensionMapper.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPTrainableDataSet;

/** A dimension mapper maps the dimensions (column types, names, values) in an input dataset into an output dataset. The number of dimensions in the mapped dataset is equal or greater than that in the input dataset. */
@protocol MPDimensionMapper <NSObject>

/** The input dataset whose dimensions are mapped to an output dataset with -mappedDataSet. */
@property (readonly) id<MPTrainableDataSet> inputDataSet;

/** The number of dimensions in the output. */
@property (readonly) NSUInteger mappedDimensionality;

/** @return index Array of column types (NSNumber instances boxing values from MPColumnType enum) for each of the dimensions that the input column at the given index maps to. */
- (NSArray *)columnTypesForMappedDimensionsForColumn:(NSUInteger)index;

/** @return Array of column names for each of the dimensions that the input column at the given index maps to.
  */
- (NSArray *)columnNamesForMappedDimensionsForColumn:(NSUInteger)index;

/** The values of the value at datum row x column mapped to output dimensions.
 * @return array of values . */
- (NSArray *)valuesForMappedDimensionsForDatum:(NSUInteger)datumIndex column:(NSUInteger)column;

/**
 *  The dimensionality of the output dataset.
 */
- (NSUInteger)mappedDimensionalityForColumnAtInputDataSetIndex:(NSUInteger)index;

/**
 * The result of mapping the dimensions of an input dataset into an output dataset.
 */
@property (readonly, copy) id<MPTrainableDataSet> mappedDataSet;

@end
