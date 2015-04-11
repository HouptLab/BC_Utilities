//
//  BCFlipBinaryTransformer.m
//  Caravan
//
//  Created by Tom Houpt on 15/4/10.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCFlipBinaryTransformer.h"

@implementation BCFlipBinaryTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation
{
    return YES;
}
- (id)transformedValue:(id)value
{
    BOOL flag;
    if (value == nil) return nil;
    
    // Attempt to get a reasonable value from the
    // value object.
    if ([value respondsToSelector: @selector(boolValue)]) {
        // handles NSString and NSNumber
        flag = [value boolValue];
    } else {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -boolValue.",
         [value class]];
    }
    
    
    return [NSNumber numberWithBool: !flag];
}

- (id)reverseTransformedValue:(id)value
{
    
    return [self transformedValue:value];
}



@end
