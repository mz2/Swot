//
//  MPTrainingInstructions.h
//  MPRandomForest
//
//  Created by Matias Piipari on 15/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

@protocol MPDatum;

/**
 *  A datum label identifier is a numerical index for a class label in its natural sorting order.
 */
typedef NSInteger MPDatumLabelIdentifier;

#import <Foundation/Foundation.h>

/**
 *  Training instructions are metadata provided about training data for a classifier.
 */
@protocol MPTrainingInstructions <NSObject>

/**
 *  The column index for a class label in the dataset used for training.
 *  NSNotFound for unlabelled datasets.
 */
@property (readonly) NSUInteger labelColumnIndex;

/**
 *  An ordered collection of all the possible class labels.
 */
@property (readonly) NSArray *labelValues;

/**
 *  The number of unique label values.
 */
@property (readonly) NSUInteger labelCount;

/**
 *  The number of feature columns in the training data, excluding the label column if present.
 */
@property (readonly) NSUInteger featureCount;


/**
 *  A string representation of the label.
 */
- (NSString *)labelAtIndex:(NSUInteger)classLabelValueIndex;

/**
 *  An identifier for the label. NSNotFound if no identifier found.
 */
- (MPDatumLabelIdentifier)labelIdentifierForDatum:(id<MPDatum>)datum;

/**
 *  The column types for all the datum entries that were present in the training data.
 */
@property (readonly, nonatomic) NSArray *columnTypes;



@end