//
//  MPALGLIBDecisionForestClassifier.h
//  MPRandomForest
//
//  Created by Matias Piipari on 15/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <MPRandomForest/MPDatumClassifier.h>

extern NSString * const MPALGLIBDecisionForestClassifierErrorDomain;

typedef NS_ENUM(NSInteger, MPALGLIBDecisionForestClassifierErrorCode) {
    MPALGLIBDecisionForestClassifierErrorCodeUnknown = 0,
    MPALGLIBDecisionForestClassifierErrorCodeInvalidClassIndex = -2,
    MPALGLIBDecisionForestClassifierErrorCodeInvalidParamCount = -1,
    MPALGLIBDecisionForestClassifierErrorCodeSerializationFailed = -100,
    MPALGLIBDecisionForestClassifierErrorCodeDeserializationFailed = -101
};

static const double MPALGLIBDecisionForestClassifierDefaultClassificationTolerance = 0.5;

@interface MPALGLIBDecisionForestClassifier : MPProbabilisticDatumClassifier

- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                       trainingData:(id<MPTrainableDataSet>)data
                          treeCount:(NSUInteger)treeCount;

@property (readonly) id<MPDataSetTransformer> transformer;

@property (readonly) id<MPTrainingInstructions> trainingInstructions;

@property (readwrite) NSUInteger treeCount;

- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(id<MPDatum>)datum;

@property (readonly) double rootMeanSquareErrorRate;
@property (readonly) double averageErrorRate;
@property (readonly) double averageRelativeErrorRate;
@property (readonly) double outOfBagRelativeClassErrorRate;
@property (readonly) double outOfBagClassificationErrorRate;
@property (readonly) double outOfBagRootMeanSquareErrorRate;
@property (readonly) double outOfBagAverageErrorRate;
@property (readonly) double outOfBagAverageRelativeErrorRate;

@end
