//
//  BCArrayUtilities.c
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#include <stdio.h>
#include "BCArrayUtilities.h"

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
    
    double product = 0.0;
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
    
    double sumSquared = 0;
    
    double theMean = meanOfArray(theArray,arrayCount);
    
    NSInteger i;
    
    for (i=0; i< arrayCount;i++) {
        sumSquared += square(theArray[i] - theMean);
    }
    
    return sumSquared;
    
}

NSInteger sumOfIntArray(NSInteger *theArray, NSInteger arrayCount) {
    
    NSInteger sum = 0;
    NSInteger i;
    
    for (i=0; i< arrayCount;i++) {
        sum+= theArray[i];
    }
    
    return sum;
    
}
NSInteger productOfIntArray(NSInteger *theArray, NSInteger arrayCount) {
    
    NSInteger product = 0;
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


