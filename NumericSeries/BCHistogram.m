//
//  BCHistogram.m
//  
//
//  Created by Tom Houpt on 11/7/30.
//  Copyright 2011 Behavioral Cybernetics. All rights reserved.
//

#import "BCHistogram.h"
#import "BCDataPoint.h"
#import "BCMeanValue.h"

void SetHistoHeader(BCDataSeriesHeader *hdr);
// set the data series header to match what is expected of a histogram data series


@implementation BCHistogram

-init; {
	
	self = [super init];
	if (self) {
		
		
	}
	return self;
}

-(id)initFromDataSeries:(BCDataSeries *)p  lowerBound:(double)lB  upperBound:(double)uB numberOfBins:(unsigned long)nB; {
	
	
	num_pts = 0;
	arraySize = 0;
	data = NULL;
	error = NULL;
	n = NULL;
	parentList =[[NSMutableArray alloc] init];
	
	[parentList addObject:p];
	
	if (lB < uB) {
		lowerBound = lB;
		upperBound = uB;
	}
	else {
		lowerBound = uB;
		upperBound = lB;
	}
	numBins = nB;
	
	// set the header to be the right kind
	SetHistoHeader(header);
	
	[self update];
		
}
// make a histogram from one data series

-(id)initFromArrayOfDataSeries:(NSArray *)a  lowerBound:(double)lB  upperBound:(double)uB numberOfBins:(unsigned long)nB; {
// can add a list of data series, and will make a histgram using all the data
	
	
	num_pts = 0;
	arraySize = 0;
	data = NULL;
	error = NULL;
	n = NULL;
	parentList = NULL;
	
	parentList = a;
	if (lB < uB) {
		lowerBound = lB;
		upperBound = uB;
	}
	else {
		lowerBound = uB;
		upperBound = lB;
	}
	numBins = nB;
	
	// set the header to be the right kind
	SetHistoHeader(header);
	
	[self update];
	
	
}

-(id)initFromBuffer:(unsigned long *)buffer lowerBound:(double)lB  upperBound:(double)uB numberOfBins:(unsigned long)nB; {
// copy the histogram out of a predefined array

	BCDataPointDescriptor *histo;
	double binSize;
	
	num_pts = 0;
	arraySize = 0;
	data = NULL;
	error = NULL;
	n = NULL;
	parentList = NULL;
		
	if (lB < uB) {
		lowerBound = lB;
		upperBound = uB;
	}
	else {
		lowerBound = uB;
		upperBound = lB;
	}
	numBins = nB;
	
	// set the header to be the right kind
	SetHistoHeader(header);
	
	binSize = (upperBound - lowerBound)/(double)numBins;
	
	// set our own array to be the right size
	[self enlargeDataArray:numBins];
	
	// copy the array
	
	
	for (histo.index=0;histo.index<numBins;histo.index++) {
		
		NSNumber *theNumber =[NSNumber numberWithUnsignedLong:buffer[histo.index]];
		[self setIndexData:(NSNumber *)theNumber atDataPoint:(BCDataPointDescriptor *)histo];
		 
	}
		
	[self update];
	
	
	
}
-(void)dealloc; {
	
	// NOTE: free any C-allocated memory
	[super dealloc];
	
}


-(void)update; {
// recalc the histogram from the parent data series
	 unsigned long numPts,count,totalNumPts,currPt = 0;
	 BCDataPointDescriptor *dp;
	 double datum;
	 double index;
	 double binSize;
	 BCDataPointDescriptor *histo;
	 BCDataSeries *parent;
	 NSObject *o;
	 unsigned long i;
	 unsigned long j = 1;
	 
	 binSize = (upperBound - lowerBound)/(double)numBins;
	 
	 // set our own array to be the right size
	 EnlargeDataArray(numBins);
	
	// zero the array
	
	for (histo.index=0;histo.index<numBins;histo.index++)
		SetIndexData(&histo,(unsigned long)0);

	// assume we have not data, at first
	totalNumPts = 0;
	
	if (nil == parentList) return;
	
	// how many overall points (observations) will be used to calc the histogram?
	// add up all the number of points in each data series
	for (i=0; i< [parentList count]; i++) {
		
		parent = (DataSeries *)[parentList objectAtIndex:i];
		if (nil != parent) {
			totalNumPts+= [parent num_pts];
		}
		
	}
	
	// increment through all the data series
	// check each data point in the series
	// find the index of the bin the data point lies in
	// increment the counts in that bin
	
	for (i=0;i<[parentList count]; i++) {
			 
		parent = (BCDataSeries *)[parentList objectAtIndex:i];
		if (nil != parent) {
							 
for (dp.index = 0;dp.index < [parent num_pts]; dp.index++) {

	// NOTE: why is 2333 and j here??
	if (dp.index  == 2333) {
		j++;
	}

	datum = [parent getDataAsDoubleAtIndex:dp.index];
		
	if ([parent isValidValue:datum]) {
	 
	 if (lowerBound <= datum && datum <= upperBound) {
		 
		 index = (datum - lowerBound)/binSize;
		 if ( 0 <= index && index < numBins) {
			 histo.index = (unsigned long)index;
			 [self getIndexData: atDataPoint:histo];
			
			DataAsDoubleAtIndex:
			 GetIndexData(&histo,&count);
			 count++;
			 SetIndexData(&histo,count);
		 } // with array range
	 } // with histo range
	} // valid datum


currPt++;
if (currPt % 1000 == 0) 
 UpdateProgress((double)currPt,(double)totalNumPts);


} // next point
} // non-NULL parent
} //  next parent in parentList
		 
		 
		 
	 } // valid parentList
	 
	 [self updateHeader];
	 [self updateMean];
	 
	 
 }

-(void)updateMean;
// recalc the mean and +/- 2 Standard deviations from current histogram...

-(void)getMean:(MeanType *)m plusMean:(MeanType *)pm minusMean:(MeanType *)mm;
-(void)getMean:(double *)m upper2SD:(double *)p2 lower2SD:(double *)m2;


-(void)setParentList:(NSArray *)p;
-(NSArray *)parentList(void);
-(void)setLowerBound:(double)lB upperBound:(double)uB numberOfBins:(unsigned long)nB;
-(void)getLowerBound:(double *)lB upperBound:(double *)uB numberOfBins:(unsigned long *)nB;


@end
