//
//  NSString+CamelCase.m
//  MPGestures
//
//  Created by Matias Piipari on 01/02/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "NSString+CamelCase.h"

@implementation NSString (CamelCase)

- (NSString *)camelCasedString {
    if (self.length > 0) {
        return [self stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                             withString:[[self substringToIndex:1] capitalizedString]];
    }
    return self;
}
@end
