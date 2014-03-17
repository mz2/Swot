//
//  MPRandomForest.m
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Matias Piipari. All rights reserved.
//

#import "MPDatumClassifier.h"

#import "MPDataSet.h"
#import "MPDataSetTransformer.h"

@interface MPDatumClassifier ()
@end

@implementation MPDatumClassifier

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MPInvalidInitException"
                                   reason:nil userInfo:nil];
}

- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                       trainingData:(id<MPTrainableDataSet>)data {
    self = [super init];
    if (self)
    {
        _transformer = transformer;
        _trainingInstructions = data;
    }
    
    return self;
}

- (NSString *)labelForClassifiedDatum:(id<MPDatum>)datum {
    @throw [NSException exceptionWithName:@"MPAbstractMethodException"
                                   reason:nil userInfo:nil];
}

@end

@implementation MPProbabilisticDatumClassifier

- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(id<MPDatum>)datum {
    
    @throw [NSException exceptionWithName:@"MPAbstractMethodException"
                                   reason:nil userInfo:nil];
}

- (NSString *)labelForClassifiedDatum:(id<MPDatum>)datum
               atProbabilityTolerance:(double)tolerance {
    
    @throw [NSException exceptionWithName:@"MPAbstractMethodException"
                                   reason:nil userInfo:nil];
}

@end
