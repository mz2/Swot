//
//  NSArray+MaxValue.h
//  MPRandomForest
//
//  Created by Matias Piipari on 01/02/2014.
//  Copyright (c) 2014 Matias Piipari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MaxValue)

/** @return The index for maximum encountered value, or NSNotFound if no values larger than -INFINITY were found. */
- (NSUInteger)indexOfMaxFloatValue:(float *)maxValue;

@end
