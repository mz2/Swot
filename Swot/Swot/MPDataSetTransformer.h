//
//  MPDataSetTransformer.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPDataSet.h"

/**
 *  A dataset transformer converts a set of floating point data into another set of dimensions, without changing the number of dimensions.
 */
@protocol MPDataSetTransformer <NSObject>

/**
 * Initialises a new dataset.
 * The data set the transformer is associated with should be immutable,
 * and this should be the designated initialiser.
 */
- (instancetype)initWithDataSet:(id<MPTrainableDataSet>)dataSet;

/**
 *  Transforms a datum into an array of real values.
 *  WARNING! The client is responsible for freeing the array.
 */
- (double *)realNumberTransform:(id<MPDatum>)datum includingLabel:(BOOL)includingLabel;

@end
