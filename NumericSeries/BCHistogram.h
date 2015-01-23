//
//  BCHistogram.h
//  
//
//  Created by Tom Houpt on 11/7/30.
//  Copyright 2011 Behavioral Cybernetics. All rights reserved.
//

//
// divide the given range (defined by upper and lower bounds)
// into the given number of bins
// run through the parent data series
//  counting the number of data points that fall within each bin
// and make that into the histogram data series
// where point 0 is number of data points in parent series that
// fall into bin 0, etc.
//

#import <Cocoa/Cocoa.h>
#import "BCDataSeries.h"

@class BCMeanValue;

@interface BCHistogram : BCDataSeries {

	
	NSMutableArray *parentList;
	double lowerBound;
	double upperBound;
	unsigned long numBins;
	
	BCMeanValue *mean;
    BCMeanValue *plusMean;
	BCMeanValue *minusMean;
	
	double plus2SD;
	double minus2SD;
		
}

-(id)init;

-(id)initFromDataSeries:(DataSeries *)p  lowerBound:(double)lB  upperBound:(double)uB numberOfBins:(unsigned long)nB;
// make a histogram from one data series

-(id)initFromArrayOfDataSeries:(NSArray *)a  lowerBound:(double)lB  upperBound:(double)uB numberOfBins:(unsigned long)nB;
// can add a list of data series, and will make a histgram using all the data

-(id)initFromBuffer:(unsigned long *)buffer lowerBound:(double)lB  upperBound:(double)uB numberOfBins:(unsigned long)nB;
// copy the histogram out of a predefined array

-(void)dealloc;



-(void)update;
// recalc the histogram from the parent data series

-(void)updateMean;
// recalc the mean and +/- 2 Standard deviations from current histogram...

-(void)getMean:(MeanType *)m plusMean:(MeanType *)pm minusMean:(MeanType *)mm;
-(void)getMean:(double *)m upper2SD:(double *)p2 lower2SD:(double *)m2;


-(void)setParentList:(NSArray *)p;
-(NSArray *)parentList(void);
-(void)setLowerBound:(double)lB upperBound:(double)uB numberOfBins:(unsigned long)nB;
-(void)getLowerBound:(double *)lB upperBound:(double *)uB numberOfBins:(unsigned long *)nB;

@end
