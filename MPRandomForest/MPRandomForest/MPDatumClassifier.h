//
//  MPRandomForest.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPDataSetTransformer.h"

static const NSUInteger MPRandomForestDefaultTreeCount = 500;

@protocol MPDatum;

@interface MPDatumClassifier : NSObject

- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                       trainingData:(id<MPTrainableDataSet>)data;

/**
 *  The predicted label for a datum. Returns nil if classification did not provide a label.
 */
- (NSString *)labelForClassifiedDatum:(id<MPDatum>)datum;

@property (readonly) id<MPDataSetTransformer> transformer;
@property (readonly) id<MPTrainingInstructions> trainingInstructions;

@end

@interface MPProbabilisticDatumClassifier : MPDatumClassifier

- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(id<MPDatum>)datum;

- (NSString *)labelForClassifiedDatum:(id<MPDatum>)datum
               atProbabilityTolerance:(double)tolerance;

@end