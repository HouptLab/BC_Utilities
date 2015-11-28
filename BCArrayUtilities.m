//
//  BCArrayUtilities.c
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//
// 14/10/11 -- converted summations to Compensated Kahan Summation

#include <stdio.h>
#import "BCArrayUtilities.h"

#define square(x) ((x)*(x))

double sumOfArray(double *theArray, NSInteger arrayCount) {
    
    double sum = 0.0;
    double correction = 0.0, corrected_next_term = 0.0, new_sum = 0.0;
    NSInteger i;
    
    sum =  theArray[0];
    for (i=1; i< arrayCount;i++) {
        corrected_next_term = theArray[i] - correction;
        new_sum = sum + corrected_next_term;
        correction = (new_sum - sum) - corrected_next_term;
        sum = new_sum;
    }
    
    return sum;
    
}
double productOfArray(double *theArray, NSInteger arrayCount) {
    
    double product = 1.0;
    NSInteger i;
    
    for (i=0; i< arrayCount;i++) {
        product*= theArray[i];
    }
    
    return product;
    
}

double meanOfArray(double *theArray, NSInteger arrayCount) {
    
    double mean = 0.0;
    
    mean = sumOfArray(theArray,arrayCount);
    mean /= (double)arrayCount;
    return mean;
    
}
double sumOfSquaredDeviationsOfArray(double *theArray, NSInteger arrayCount) {
    
    // sum across array (theArray[i] - theMean)^2
    
    double sumSquared = 0.0;
    double correction = 0.0, corrected_next_term = 0.0, new_sum = 0.0;
    
    double theMean = meanOfArray(theArray,arrayCount);
    
    NSInteger i;
    
//    for (i=0; i< arrayCount;i++) {
//        
//        sumSquared += square(theArray[i] - theMean);
//    }
    
    sumSquared =  square(theArray[0] - theMean);

    for (i=0; i< arrayCount;i++) {
        corrected_next_term = square(theArray[0] - theMean) - correction;
        new_sum = sumSquared + corrected_next_term;
        correction = (new_sum - sumSquared) - corrected_next_term;
        sumSquared = new_sum;
    }
    
    return sumSquared;
    
}

// -------------------------------------------------------------------------------------


NSInteger sumOfIntArray(NSInteger *theArray, NSInteger arrayCount) {
    
    NSInteger sum = 0;
    NSInteger i;
    
    for (i=0; i< arrayCount;i++) {
        sum+= theArray[i];
    }
    
    return sum;
    
}
NSInteger productOfIntArray(NSInteger *theArray, NSInteger arrayCount) {
    
    NSInteger product = 1;
    NSInteger i;
    
    for (i=0; i< arrayCount;i++) {
        product*= theArray[i];
    }
    
    return product;
    
}

double meanOfIntArray(NSInteger *theArray, NSInteger arrayCount) {
    
    double mean = 0.0;
    
    mean = sumOfIntArray(theArray,arrayCount);
    mean /= (double)arrayCount;
    return mean;
    
}

// -------------------------------------------------------------------------------------

double sumOfNSArray(NSArray *theArray) {    
    
    double sum = 0.0;
    double correction = 0.0, corrected_next_term = 0.0, new_sum = 0.0;
    
   

    NSUInteger i;
    NSUInteger arrayCount = [theArray count];
    
//    for (i=0; i< arrayCount;i++) {
//        sum+= [[theArray objectAtIndex:i] doubleValue];
//    }
    
    sum =  [[theArray objectAtIndex:0] doubleValue];
    for (i=1; i< arrayCount;i++) {
        corrected_next_term =  [[theArray objectAtIndex:i] doubleValue] - correction;
        new_sum = sum + corrected_next_term;
        correction = (new_sum - sum) - corrected_next_term;
        sum = new_sum;
    }
    
    return sum;
    
}
double productOfNSArray(NSArray *theArray) {
    
    double product = 1.0;
    NSUInteger i;
    NSUInteger arrayCount = [theArray count];
    
    for (i=0; i< arrayCount;i++) {
        product*= [[theArray objectAtIndex:i] doubleValue];
    }
    
    return product;
    
}

double meanOfNSArray(NSArray *theArray) {
    
    double mean = 0.0;
    
    NSUInteger arrayCount = [theArray count];

    mean = sumOfNSArray(theArray);
    mean /= (double)arrayCount;
    
    return mean;
    
}
double sumOfSquaredDeviationsOfNSArray(NSArray *theArray) {
    
    // sum across array (theArray[i] - theMean)^2
    double sumSquared = 0.0;
    double correction = 0.0, corrected_next_term = 0.0, new_sum = 0.0;
    NSUInteger i;
    NSUInteger arrayCount = [theArray count];

    
    double theMean = meanOfNSArray(theArray);
    
//    for (i=0; i< arrayCount;i++) {
//        sumSquared += square([[theArray objectAtIndex:i] doubleValue] - theMean);
//    }
    
    sumSquared =  square([[theArray objectAtIndex:0] doubleValue] - theMean);
    
    for (i=0; i< arrayCount;i++) {
        corrected_next_term = square([[theArray objectAtIndex:i] doubleValue] - theMean) - correction;
        new_sum = sumSquared + corrected_next_term;
        correction = (new_sum - sumSquared) - corrected_next_term;
        sumSquared = new_sum;
    }

    
    return sumSquared;
    
}


//  MIDMEAN
//  mean of values between 25th and 75th percentile
//  includes 25th and 75th percentile



#undef square


void MoveObjectToEndOfNSArray(id theObject,NSMutableArray *theArray) {
    
    NSUInteger objectIndex = [theArray indexOfObject: theObject];
    if (objectIndex != NSNotFound) {
        [theArray removeObjectAtIndex: objectIndex];
        [theArray addObject: theObject];
    }

}

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] <= 1)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];

        i++;
        j--;
    }
}

@end


