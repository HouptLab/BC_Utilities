//
//  BCArrayUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#ifndef Xynk_BCArrayUtilities_h
#define Xynk_BCArrayUtilities_h

// utility routines for folding arrays with + and *
// because we are not coding in J
// NOTE: write some parallel routines for folding/mapping across NSArray of NSNumber's?

typedef long NSInteger;


double sumOfArray(double *theArray, NSInteger arrayCount);
double productOfArray(double *theArray, NSInteger arrayCount);
double meanOfArray(double *theArray, NSInteger arrayCount);
double sumOfSquaredDeviationsOfArray(double *theArray, NSInteger arrayCount);

NSInteger sumOfIntArray(NSInteger *theArray, NSInteger arrayCount);
NSInteger productOfIntArray(NSInteger *theArray, NSInteger arrayCount);
double meanOfIntArray(NSInteger *theArray, NSInteger arrayCount);




#endif
