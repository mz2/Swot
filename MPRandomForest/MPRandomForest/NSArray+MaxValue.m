//
//  NSArray+MaxValue.m
//  MPRandomForest
//
//  Created by Matias Piipari on 01/02/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import "NSArray+MaxValue.h"

@implementation NSArray (MaxValue)

- (NSUInteger)indexOfMaxFloatValue:(float *)maxValue {
    float max = -INFINITY;
    NSUInteger index = NSNotFound;
    
    for (NSUInteger i = 0, cnt = self.count; i < cnt; i++) {
        NSNumber *n = self[i];
        float f = n.floatValue;
        if (f > max) {
            max = f;
            index = i;
        }
    }
    
    if (maxValue)
        *maxValue = max;
    
    return index;
}

@end
