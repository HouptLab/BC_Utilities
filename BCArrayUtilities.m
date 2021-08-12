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


// NOTE: make sure that zero length arrays are handled properly...

double sumOfArray(double *theArray, NSInteger arrayCount) {
    
    double sum = 0.0;
    double correction = 0.0, corrected_next_term = 0.0, new_sum = 0.0;
    NSInteger i;
    
    if (0 < arrayCount) {
        for (i=0; i< arrayCount;i++) {
            corrected_next_term = theArray[i] - correction;
            new_sum = sum + corrected_next_term;
            correction = (new_sum - sum) - corrected_next_term;
            sum = new_sum;
        }
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
    
    if (0 < arrayCount) {

        for (i=0; i< arrayCount;i++) {
            corrected_next_term = square(theArray[0] - theMean) - correction;
            new_sum = sumSquared + corrected_next_term;
            correction = (new_sum - sumSquared) - corrected_next_term;
            sumSquared = new_sum;
        }
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



double sumOfNSArray(NSArray<NSNumber *> *theArray) {    
    
    double sum = 0.0;
    double correction = 0.0, corrected_next_term = 0.0, new_sum = 0.0;
    

    NSUInteger i;
    NSUInteger arrayCount = [theArray count];
    
//    for (i=0; i< arrayCount;i++) {
//        sum+= [[theArray objectAtIndex:i] doubleValue];
//    }
    
    if (0 < arrayCount) {
        for (i=0; i< arrayCount;i++) {
            corrected_next_term =  [[theArray objectAtIndex:i] doubleValue] - correction;
            new_sum = sum + corrected_next_term;
            correction = (new_sum - sum) - corrected_next_term;
            sum = new_sum;
        }
    }
    
    return sum;
    
}
double productOfNSArray(NSArray<NSNumber *> *theArray) {
    
    double product = 1.0;
    NSUInteger i;
    NSUInteger arrayCount = [theArray count];
    
    for (i=0; i< arrayCount;i++) {
        product*= [[theArray objectAtIndex:i] doubleValue];
    }
    
    return product;
    
}

double meanOfNSArray(NSArray<NSNumber *> *theArray) {
    
    // TODO: change this from naive to incremental calculation of mean
    double mean = 0.0;
    
    NSUInteger arrayCount = [theArray count];

    mean = sumOfNSArray(theArray);
    mean /= (double)arrayCount;
    
    return mean;
    
}
double sumOfSquaredDeviationsOfNSArray(NSArray<NSNumber *> *theArray) {
    

    double theMean = meanOfNSArray(theArray);
    return sumOfSquaredDeviationsOfNSArrayFromMean(theArray,theMean);
    
 
}

double sumOfSquaredDeviationsOfNSArrayFromMean(NSArray<NSNumber *> *theArray,double theMean) {
    
    // sum across array (theArray[i] - theMean)^2
    double sum = 0.0;
    double squared_difference = 0;
    double compensation = 0.0,corrected_next_term = 0.0,total=0.0;
    NSUInteger arrayCount = [theArray count];

    
// naive:
//    for (i=0; i< arrayCount;i++) {
//        sumSquared += square([[theArray objectAtIndex:i] doubleValue] - theMean);
//    }
    
    if (0 < arrayCount) {
        
        for (NSInteger i=0; i< arrayCount;i++) {
            squared_difference = square([[theArray objectAtIndex:i] doubleValue] - theMean);
            corrected_next_term = squared_difference - compensation;
            total =  sum + corrected_next_term;
            compensation = (total - sum) - corrected_next_term;
            sum = total;
        }

    }
    
    return sum;
    
}


/** return the overall mean of an NSarray of NSArrays of NSNumbers

TODO: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
    or just incremental averaging
    
    @param theGroups an NSArray of NSArray's of NSNumbers
    @return the mean of the all the array elements as a double

 */

double populationMeanOfNSArrayOfGroups(NSArray<NSArray *>  *theGroups) {

    NSInteger count = 0;
    double sum = 0;
    
    for (NSArray *group in theGroups) {
        for (NSNumber *observation in group) {
            sum+= [observation doubleValue];
            count++;
        }
    }
    
    return (sum / count);
}

/** calculate the deviation (𝛕) of the given group from the given population mean
 
    @param populationMean the mean value of entire experiment (ie. all groups)
    @param theGroup one of the groups within the experiment
    @return the deviation (𝛕) of theGroup from the given populationMean
*/
double deviationFromPopulationMeanOfNSArray(double populationMean,NSArray<NSNumber *>  *theGroup) {

// TODO: make this incremental ? 
// TODO: check that this is correct deviation

    double deviation = 0;
    NSInteger count = 0;
    
    for (NSNumber *observation in theGroup) {
            deviation+= fabs((populationMean - [observation doubleValue]));
            count++;
    }
    
    deviation /= count;
    return deviation;
}



//  MIDMEAN
//  mean of values between 25th and 75th percentile
//  includes 25th and 75th percentile


#undef square


void MoveObjectToEndOfNSArray(id theObject,NSMutableArray *theArray) {
    
    NSUInteger objectIndex = [theArray indexOfObject: theObject];
    if (objectIndex != NSNotFound) {
        [theArray removeObjectAtIndex: objectIndex];
    }
    [theArray addObject: theObject];


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


