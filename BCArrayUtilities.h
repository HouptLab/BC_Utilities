//
//  BCArrayUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//


#include <Foundation/Foundation.h>

/**
CPP utility to extract double form an array of NSNumbers

 */
#define DVAL(_x,_i) ([[(_x) objectAtIndex:(_i)] doubleValue])



// utility routines for folding arrays with + and *
// because we are not coding in J
// parallel routines for folding/mapping across NSArray of NSNumber's?
// double-precision routines use Compensated Kahan Summation 

//typedef long NSInteger;

/** return the sum of an array of doubles

    @param theArray a C-style array of doubles
    @param arrayCount the length of theArray
    @return the sum of the array elements

 */
double sumOfArray(double *theArray, NSInteger arrayCount);

/** return the sum of an array of doubles

    @param theArray a C-style array of doubles
    @param arrayCount the length of theArray
    @return the sum of the array elements

 */
double productOfArray(double *theArray, NSInteger arrayCount);

/** return the mean of an array of doubles
 
    TODO: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
    or just incremental averaging

    @param theArray a C-style array of doubles
    @param arrayCount the length of theArray
    @return the mean of the array elements

 */
double meanOfArray(double *theArray, NSInteger arrayCount);

/** return the sum of squared deviations of an array of doubles

    TODO: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
    or just incremental averaging
    
    @param theArray a C-style array of doubles
    @param arrayCount the length of theArray
    @return the sum of thr squared deviations of the array elements

 */
double sumOfSquaredDeviationsOfArray(double *theArray, NSInteger arrayCount);

// -------------------------------------------------------------------------------------
/** return the sum of an array of NSIntegers

    @param theArray a C-style array of NSIntegers
    @param arrayCount the length of theArray
    @return the sum of the array elements

 */
NSInteger sumOfIntArray(NSInteger *theArray, NSInteger arrayCount);

/** return the product of an array of NSIntegers

    @param theArray a C-style array of NSIntegers
    @param arrayCount the length of theArray
    @return the product of the array elements

 */
NSInteger productOfIntArray(NSInteger *theArray, NSInteger arrayCount);

/** return the mean of an array of NSIntegers

    TODO: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
    or just incremental averaging
    
    @param theArray a C-style array of NSIntegers
    @param arrayCount the length of theArray
    @return the mean of the array elements

 */
double meanOfIntArray(NSInteger *theArray, NSInteger arrayCount);

// -------------------------------------------------------------------------------------
/** return the sum of an NSarray of NSNumbers

    @param theArray an NSArray of NSNumbers
    @return the sum of the array elements as a double

 */
double sumOfNSArray(NSArray<NSNumber *> *theArray);

/** return the product of an NSarray of NSNumbers

    @param theArray an NSArray of NSNumbers
    @return the product of the array elements as a double

*/
 double productOfNSArray(NSArray<NSNumber *>  *theArray);
 
/** return the mean of an NSarray of NSNumbers

TODO: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
    or just incremental averaging
    @param theArray an NSArray of NSNumbers
    @return the mean of the array elements as a double

 */
double meanOfNSArray(NSArray<NSNumber *>  *theArray);

/** return the sum of squared deviations of an NSarray of NSNumbers from its own mean

    gets its own mean using meanOfNSArray, then gets sumsquared using sumOfSquaredDeviationsOfNSArrayFromMean
    
    @param theArray an NSArray of NSNumbers
    @return the sum of squared deviations of the array elements from the array mean as a double

 */
double sumOfSquaredDeviationsOfNSArray(NSArray<NSNumber *>  *theArray);

/** return the sum of squared deviations of an NSarray of NSNumbers from the given mean

TODO: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
    or just incremental averaging
    @param theArray an NSArray of NSNumbers
    @ param theMean a double mean to be used for deviation
    @return the sum of squared deviations of the array elements from the given mean as a double

 */
double sumOfSquaredDeviationsOfNSArrayFromMean(NSArray<NSNumber *> *theArray,double theMean);

/** return the overall mean of an NSarray of NSArrays of NSNumbers

TODO: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
    or just incremental averaging
    
    @param theGroups an NSArray of NSArray's of NSNumbers
    @return the mean of the all the array elements as a double

 */

double populationMeanOfNSArrayOfGroups(NSArray<NSArray *>  *theGroups);

/** calculate the deviation (𝛕) of the given group from the given population mean
 
    @param populationMean the mean value of entire experiment (ie. all groups)
    @param theGroup one of the groups within the experiment
    @return the deviation (𝛕) of theGroup from the given populationMean
*/
double deviationFromPopulationMeanOfNSArray(double populationMean,NSArray<NSNumber *>  *theGroup);

/** if the given object is in the NSMutable Array, move it to the end of the array.
 
    if it is not in the array, then add to the end of the array
    
        @param theObject to be moved or added to end of the array
        @param theArray the NSMutableArray with the object
 
 */
void MoveObjectToEndOfNSArray(id theObject,NSMutableArray *theArray);


@interface NSArray (Reverse)

/** 
 @return reverse of self in a new NSArray
 */
- (NSArray *)reversedArray;
@end

@interface NSMutableArray (Reverse)
 /** reverse self in place
 */
- (void)reverse;
@end
