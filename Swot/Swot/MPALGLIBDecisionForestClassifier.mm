//
//  MPALGLIBDecisionForestClassifier.m
//  MPRandomForest
//
//  Created by Matias Piipari on 15/01/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import "MPALGLIBDecisionForestClassifier.h"
#import "MPDataSetTransformer.h"

#import <ALGLIB/ALGLIB.h>

#include <math.h>
#include <iostream>

NSString * const MPALGLIBDecisionForestClassifierErrorDomain = @"MPALGLIBDecisionForestClassifierErrorDomain";

@interface MPALGLIBDecisionForestClassifier ()
@property (readwrite) alglib::ae_int_t *classifierInfo;
@property (readwrite) alglib::decisionforest *classifierForest;
@property (readwrite) alglib::dfreport *classifierReport;
@end

@implementation MPALGLIBDecisionForestClassifier

- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                       trainingData:(id<MPTrainableDataSet>)data {
    return [self initWithTransformer:transformer trainingData:data treeCount:MPRandomForestDefaultTreeCount];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url
                          transformer:(id<MPDataSetTransformer>)transformer
                 trainingInstructions:(id<MPTrainingInstructions>)trainingInstructions {
    self = [super init];
    if (self) {
        NSError *err = nil;
        NSString *decisionForestRepStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        alglib::decisionforest *forest = NULL;
        std::string decisionForestRepCStr = std::string(decisionForestRepStr.UTF8String);
        alglib::dfunserialize(decisionForestRepCStr, *forest);
        
        self.classifierForest = forest;
    }
    return self;
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)err {
    std::string *decisionForestRep = NULL;
    alglib::dfserialize(*self.classifierForest, *decisionForestRep);
    BOOL success = decisionForestRep != NULL;

    if (err && !success) {
        *err = [NSError errorWithDomain:MPALGLIBDecisionForestClassifierErrorDomain
                                   code:MPALGLIBDecisionForestClassifierErrorCodeSerializationFailed
                               userInfo:@{NSLocalizedDescriptionKey : @"Serialization failed."}];
    }
    
    return success;
}


- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                       trainingData:(id<MPTrainableDataSet>)data
                          treeCount:(NSUInteger)treeCount
{
    self = [super initWithTransformer:transformer trainingData:data];
    
    if (self)
    {
        self.treeCount = treeCount;
        
        NSError *err = nil;
        if (![self trainWithData:data error:&err]) {
            NSLog(@"ERROR: %@", err);
            return nil;
        }
    }
    
    return self;
}


- (void)dealloc {
    if (self.classifierForest)
        delete self.classifierForest;
    
    if (self.classifierReport)
        delete self.classifierReport;
}

- (alglib::real_2d_array *)ALGLIBDataForTrainingDataSet:(id<MPTrainableDataSet>)data
{
    NSUInteger fCount = self.trainingInstructions.featureCount;
    
    alglib::real_2d_array *array = new alglib::real_2d_array;
    array->setlength(data.datumCount, fCount);
    
    // FIXME: something's fucked up here. classI should not be going from 0..data.datumCount
    NSUInteger rowI = 0;
    for (NSUInteger i = 0; i < data.datumCount; i++)
    {
        id<MPDatum> datum = [data datumAtIndex:i];
        
        double *data = [self.transformer realNumberTransform:datum includingLabel:YES];
        
        // fill feature values.
        for (NSUInteger f = 0; f < fCount; f++)
        {
            double val = data[f];
            (*array)(rowI, f) = val;
        }
        
        // fill class label
        (*array)(rowI, fCount)
            = [self.trainingInstructions labelIdentifierForDatum:datum];
        
        free(data);
        rowI++;
    }
    
    return array;
}

- (BOOL)trainWithData:(id<MPTrainableDataSet>)data error:(NSError **)error
{
    alglib::real_2d_array *xy = [self ALGLIBDataForTrainingDataSet:data];
    
    alglib::ae_int_t ntrees = self.treeCount;
    double r = 0.5;
    alglib::ae_int_t info;
    alglib::decisionforest *df = new alglib::decisionforest();
    alglib::dfreport *rep = new alglib::dfreport();
    
    //std::cerr << xy->tostring(1) << "\n";
    
    alglib::dfbuildrandomdecisionforest(*xy,
                                        data.datumCount,
                                        self.trainingInstructions.featureCount - 1,
                                        self.trainingInstructions.labelCount,
                                        ntrees,
                                        r,
                                        info, *df, *rep);
    
    self.classifierForest = df;
    self.classifierReport = rep;
    
    _rootMeanSquareErrorRate = rep->rmserror;
    _averageErrorRate = rep->avgerror;
    _averageRelativeErrorRate = rep->avgrelerror;
    _outOfBagRelativeClassErrorRate = rep->oobrelclserror;
    _outOfBagClassificationErrorRate = rep->oobavgce;
    _outOfBagRootMeanSquareErrorRate = rep->oobrmserror;
    _outOfBagAverageErrorRate = rep->oobavgerror;
    _outOfBagAverageRelativeErrorRate = rep->oobavgrelerror;
    
    std::cerr << "model learned    :" << info << "\n";
    std::cerr << "rms error        :" << rep->rmserror << "\n";
    std::cerr << "avg error        :" << rep->avgerror << "\n";
    std::cerr << "avg rel error    :" << rep->avgrelerror << "\n";
    std::cerr << "oob rel csl error:" << rep->oobrelclserror << "\n";
    std::cerr << "oob avg ce error :" << rep->oobavgce << "\n";
    std::cerr << "oob rms error    :" << rep->oobrmserror << "\n";
    std::cerr << "oob avg error    :" << rep->oobavgerror << "\n";
    std::cerr << "oob avg rel error:" << rep->oobavgrelerror << "\n";
    
    delete xy;
    
    if (info == -2) {
        if (error) {
            NSError *err = [NSError errorWithDomain:MPALGLIBDecisionForestClassifierErrorDomain
                                               code:MPALGLIBDecisionForestClassifierErrorCodeInvalidClassIndex
                                           userInfo:@{ NSLocalizedDescriptionKey :
                                           @"Class index out of bounds from expected class count."}];
            *error = err;
        }
    }
    else if (info == -1) {
        if (error) {
            NSError *err = [NSError errorWithDomain:MPALGLIBDecisionForestClassifierErrorDomain
                                               code:MPALGLIBDecisionForestClassifierErrorCodeInvalidClassIndex userInfo:@{NSLocalizedDescriptionKey : @"Invalid parameter count"}];;
            *error = err;
        }
    }
    
    return info == 1;
}


- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(id<MPDatum>)datum
{
    assert(datum);
    
    double *trainingData = [self.transformer realNumberTransform:datum includingLabel:NO];
    assert(trainingData);
    
    alglib::real_1d_array *tData = new alglib::real_1d_array();
    tData->setcontent(self.trainingInstructions.featureCount - 1, trainingData);
    free(trainingData);
    
    //std::cerr << tData->tostring(1) << "\n";
    
    alglib::real_1d_array *posteriorProbs = new alglib::real_1d_array();
    posteriorProbs->setlength(self.trainingInstructions.labelCount);
    
    alglib::dfprocess(*(self.classifierForest), *tData, *posteriorProbs);
    
    //std::cerr << posteriorProbs->tostring(1) << "\n";
    
    delete tData;
    
    double *content = posteriorProbs->getcontent();
    NSMutableArray *probs = [NSMutableArray arrayWithCapacity:self.trainingInstructions.labelCount];
    for (NSUInteger i = 0; i < self.trainingInstructions.labelCount; i++)
        [probs addObject:@(content[i])];
    
    return probs;
}

- (NSString *)labelForClassifiedDatum:(id<MPDatum>)datum {
    return [self labelForClassifiedDatum:datum
                  atProbabilityTolerance:MPALGLIBDecisionForestClassifierDefaultClassificationTolerance];
}

- (NSString *)labelForClassifiedDatum:(id<MPDatum>)datum
               atProbabilityTolerance:(double)tolerance
{
    NSArray *probs = [self posteriorProbabilitiesForClassifyingDatum:datum];
    
    if (!probs)
        return nil;
    
    double maxProb = 0.0f;
    NSUInteger maxIndex = NSNotFound, i = 0; //0 == unknown shape
    
    for (NSNumber *p in probs) {
        double pv = [p doubleValue];
        if ((maxProb < pv) && (pv > tolerance)) {
            maxProb = pv;
            maxIndex = i;
        }
        i++;
    }
    
    if (maxIndex != NSNotFound)
        return [self.trainingInstructions labelAtIndex:maxIndex];
    
    return nil;
}
@end