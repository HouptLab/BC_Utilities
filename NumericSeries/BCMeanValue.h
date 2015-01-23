//
//  BCMeanValue.h
//  TongueTwister
//
//  Created by Tom Houpt on 10/4/29.
//  Copyright 2010 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kNoDataCellText @"--"

@interface BCMeanValue : NSObject {

		unsigned long num;
		double mean;
		double stdev;
		double SEM;

}

-(double)mean;
-(unsigned long)num;
-(double)stdev; // NOTE: we divide sum of squares by (num - 1) to get sample standard deviation
-(double)SEM;  // NOTE: we divide stdev by sqrt (num) to get SEM


-(void) zeroMean;
-(void) sumMean:(double) x;
		// add x to the current sum (stored in mean)
		// if x is "missing value" then it is not added
		// increments num by 1

-(void) sumNonZeroMean:(double) x;
		// sometimes we require the mean to be composed of only non-zero values
		// so x is added to mean if x != 0

-(void) divideMean;
		// divide the mean (the summed up x's) by the num to get the mean

// stdev and standard error of the mean is found the same way, by adding up squared deviations
-(void) sumErr:(double) x;
-(void) sumNonZeroErr:(double) x;
-(void) divideErr; 
// assuming all the error terms have been added, now divide by (n-1) for stdev and sqrt(n) for SEM

-(NSString *) justMean2Text;
-(NSString *) justSEM2Text;
-(NSString *) mean2Text;
-(NSString *) mean2FileText;

@end
