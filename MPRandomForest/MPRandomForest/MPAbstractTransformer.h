//
//  MPAbstractTransformer.h
//  MPRandomForest
//
//  Created by Matias Piipari on 13/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDataSetTransformer.h"

@interface MPAbstractTransformer : NSObject <MPDataSetTransformer>

@property (readonly) id<MPTrainableDataSet> dataSet;

@end