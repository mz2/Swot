//
//  MPAbstractDimensionMapper.h
//  MPRandomForest
//
//  Created by Matias Piipari on 26/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDimensionMapper.h"

@protocol MPTrainableDataSet, MPDatum;

/**
 * An abstract base class for dimension mappers which map input dataset columns using their column names and matching instance methods. For each of your input dataset column name 'c' whose capital case equivalent is 'C' you need to provide three instance methods:
 *
 * - -(NSArray *)mapped[C]ValuesForDatumValue:(id)datumValue
 * - -(NSArray *)mappedColumnTypesFor[C]
 * - -(NSArray *)mappedColumnNamesFor[C]
 * - -(id)mappedDimensionalityFor[C] : should return a NSNumber boxing an unsigned integral value.
 *
 * As with any MPDimensionMapper, the dimensionality of the mapped output dataset will be equal to or greater than that of the input dataset.
 */
@interface MPNamedColumnDimensionMapper : NSObject <MPDimensionMapper>

- (instancetype)initWithDataSet:(id<MPTrainableDataSet>)dataSet;

@property (readonly) id<MPTrainableDataSet> inputDataSet;
@property (readonly, copy) id<MPTrainableDataSet> mappedDataSet;

@property (readonly) NSUInteger mappedDimensionality;

@end