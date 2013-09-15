//
//  BCArrayUtilities.c
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#include <stdio.h>
#import "BCArrayUtilities.h"

#define square(x) ((x)*(x))

double sumOfArray(double *theArray, NSInteger arrayCount) {
    
    double sum = 0.0;
    NSInteger i;
    
    for (i=0; i< arrayCount;i++) {
        sum+= theArray[i];
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
    
    double sumSquared = 0;
    
    double theMean = meanOfArray(theArray,arrayCount);
    
    NSInteger i;
    
    for (i=0; i< arrayCount;i++) {
        sumSquared += square(theArray[i] - theMean);
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
    NSUInteger i;
    NSUInteger arrayCount = [theArray count];
    
    for (i=0; i< arrayCount;i++) {
        sum+= [[theArray objectAtIndex:i] doubleValue];
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
    
    NSUInteger i;
    NSUInteger arrayCount = [theArray count];

    double sumSquared = 0;
    
    double theMean = meanOfNSArray(theArray);
    
    for (i=0; i< arrayCount;i++) {
        sumSquared += square([[theArray objectAtIndex:i] doubleValue] - theMean);
    }
    
    return sumSquared;
    
}

#undef square


void MoveObjectToEndOfNSArray(id theObject,NSMutableArray *theArray) {
     
    NSUInteger objectIndex = [theArray indexOfObject: theObject];
    if (objectIndex != NSNotFound) {
        [theArray removeObjectAtIndex: objectIndex];
        [theArray addObject: theObject];
    }

}


