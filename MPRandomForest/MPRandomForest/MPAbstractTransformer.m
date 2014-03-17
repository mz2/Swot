//
//  MPAbstractTransformer.m
//  MPRandomForest
//
//  Created by Matias Piipari on 13/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import "MPAbstractTransformer.h"
#import "MPDataSet.h"

@interface MPAbstractTransformer ()
@end

@implementation MPAbstractTransformer

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MPInvalidInitException" reason:nil userInfo:nil];
}

- (instancetype)initWithDataSet:(id<MPTrainableDataSet>)dataSet
{
    self = [super init];
    if (self) {
        _dataSet = dataSet;
    }
    return self;
}

- (double *)realNumberTransform:(id<MPDatum>)datum includingLabel:(BOOL)includingLabel {
    return [datum realNumberRepresentationIncludingLabel:includingLabel];
}

@end
