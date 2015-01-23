//
//  BCTimeSeries.m
//  TongueTwister
//
//  Created by Tom Houpt on 10/5/3.
//  Copyright 2010 Behavioral Cybernetics. All rights reserved.
//

#import "BCTimeSeries.h"



@implementation BCTimeSeriesHeader


@synthesize start_time;
@synthesize end_time;
@synthesize evenly_spaced; 
@synthesize bin_size;

-(id)init; {
	
	self = [super init];
	
	if (self) {
		
		[self setDefault];
	}
	
	return self;
	
}

-(void) setDefault; {
	
	
	// time parameters 
	start_time = 0;
	end_time = 0;
	evenly_spaced = TRUE; 
	// is data equally spaced or randomly time stamped? 
	bin_size = SECSPERMINUTE;
	// only valid if data is evenly spaced
}



@end


@implementation BCTimeSeries

// -----------------------------------------------------------------------------
// initialization and deallocation --------------------------------------------

-(id)init; {
	
	self = [super init];
	
	if (self) {
		
		timeHeader = [[BCTimeSeriesHeader alloc] init];
		time = NULL;
	}
	
	return self;
	
}


-(id)initWithDataSeriesHeader:(BCDataSeriesHeader *) hdr andTimeSeriesHeader:(BCTimeSeriesHeader *) thdr; {
	
	self = [super init];
	
	if (self) {
		
		header = hdr;
		timeHeader = thdr;
		time = NULL;
				
	}
	
	return self;
	
}


-(id)initWithDataSeriesHeader:(BCDataSeriesHeader *) hdr andTimeSeriesHeader:(BCTimeSeriesHeader *) thdr 
			  andData: (char *)new_data 
			andNumPts:(unsigned long)new_num_pts
		andTimeStamps:(unsigned long *)new_time 
				 andN:(unsigned long *)new_n 
			 andError:(double *)new_error; {
	
	self = [super init];
	
	if (self) {
		
		
		header = hdr;
		timeHeader = thdr;
		
		num_pts = new_num_pts;
		arraySize = num_pts * [self getDatumSize];
		data = new_data;
		error = new_error;
		n = new_n;
		time = new_time;
		
	}
	
	return self;
}




-(void)dealloc; {
	
	if (time != NULL) { free(time); time = NULL; }
	
	[super dealloc];

}



// -----------------------------------------------------------------------------
// initialization from other time series  --------------------------------------------

// because these routines return time series, they are initialization calls...

-(BCTimeSeries *) averageTimeSeriesAlignedAtStart:(NSArray *)tsList; {
	// creates an average time series from a list of time series objects
	// time series must all be equispaced at the same binsize
	// the time series are aligned by their starts and averaged
	// i.e. the first point of each series is averaged, the second are averaged, etc.
	// returns NIL if there is some failure...
	
	BCTimeSeries *ts;
	int numTimeSeries,index;
	unsigned long tsLength;
	unsigned long binSize, tsBinSize;
	BOOL equispaced;
	double datum;

	unsigned long num;
	double err;
	self = [super init];
	
	if (self) {
		
		// only average if we have more than 0 time series
		if (tsList == nil) return nil;
		if (0 == [tsList count]) return nil;
		
		ts = (BCTimeSeries *)[tsList objectAtIndex:0];
		
		binSize = [ts binSizeIfEquispaced:&equispaced];
		
		// check to make sure the time series all match in terms of evenly-spaced bins
		for (BCTimeSeries *ts in tsList) {
			
//		for (index = 0; index < numTimeSeries; index++) {
//			ts = (BCTimeSeries *)[tsList objectAtIndex:index];
			
			tsBinSize = [ts binSizeIfEquispaced:&equispaced];
			if (!equispaced || tsBinSize != binSize) {
				return nil;
			}
		}
		
		
		// for speeds sake, lets do it all by hand
		
		// find the longest time series
		num_pts = 0;
		for (index = 0; index < numTimeSeries; index++) {
			
			ts = (BCTimeSeries *)[tsList objectAtIndex:index];
			tsLength = [ts num_pts];			
			if (tsLength > num_pts) num_pts = tsLength;
		}
		
		
		// allocate the pointers
		data = malloc(num_pts * sizeof(double));
		error = (double *)malloc(num_pts * sizeof(double));
		n = (unsigned long *)malloc(num_pts * sizeof(unsigned long));
		time = NULL;
		arraySize = num_pts * sizeof(double);

		
		
		// zero the arrays
		
		for (index = 0;index < num_pts;index++) {
			((double *)data)[index] = 0.0;
			n[index] = 0;
			error[index] = 0.0;
		}
		
		// average the suckers
		
		// accumulate the sums
		for (index = 0; index < numTimeSeries; index++) {
			
			ts = (BCTimeSeries *)[tsList objectAtIndex:index];
			
			tsLength = [ts num_pts];
			
			for (index = 0;index < tsLength;index++) {
				
				datum = [ts getDataAsDoubleAtIndex:index];
				
				if ([ts isValidValue:datum] ){
					
					((double *)data)[index]+= datum;
					
					n[index]+= 1;
				}
			}		
		}
		
		// got the sums and the n, so lets get the mean
		
		for (index = 0;index <num_pts;index++) {
			if (n[index] > 0) {
				((double *)data)[index] /= n[index];
			}
		}
		
		// lets calculate the SEMs
		
		// get the squared deviations
		
		for (index = 0; index < numTimeSeries; index++) {
			
			ts = (BCTimeSeries *)[tsList objectAtIndex:index];
			
			tsLength = [ts num_pts];
			
			for (index = 0;index < tsLength;index++) {
				
				datum = [ts getDataAsDoubleAtIndex:index];
				
				if ([ts isValidValue:datum] ) {
					
					error[index] += (datum - ((double *)data)[index]) * (datum - ((double *)data)[index]);
					
				}
			}
		}
		
		// gotten the squared deviations, lets get the SEMS
		
		// NOTE: divide squred deviations by n-1 to get sample stdev
		// NOTE: divide stdev by sqrt n to get SEM
		
		for (index = 0;index < num_pts;index++) {
			num = n[index];
			err = error[index];
			if (num > 1) {
				err /= (num - 1);
				err = sqrt((double)err) / sqrt((double)(num));
				error[index] = err;
			}
			else error[index] = 0;
		}
		
		
		
		[header setDefaultForMean];
		[self setBinSize:binSize];
		[self updateHeader];		
		
	}
	
	return self;
	
	
}


// creates an average time series from a list of time series objects
// time series must all be equispaced at the same binsize
// the time series are aligned by their starts and averaged
// i.e. the first point of each series is averaged, the second are averaged, etc.
// returns NIL if there is some failure...

// success returns TRUE if the averaging was completed successfully
// if success is FALSE and the returned series is NULL, then  the series could not be averaged together
// e.g. one list was time stamped and others were equally spaced, or the bin size did not match)

-(BCTimeSeries *) averageTimeSeries:(NSArray *)tsList alignedAtTime:(unsigned long) alignTime {

// same as above but points with the same absolute timestamps are averaged
// returns NIL if there is some failure...
	
	self = [super init];
	
	if (self) {
		
		
	}
	
	return self;
	
	
}



-(BCTimeSeries *) averageTimeSeriesAlignedAtNonZeroStart:(NSArray *)tsList {
	
// creates an average time series from a list of time series objects
// aligning from the first non-zero data points of each series
// returns NIL if there is some failure...
	
	self = [super init];
	
	if (self) {
		
		
	}
	
	return self;
	

}

// -----------------------------------------------------------------------------
// setters and getters

@synthesize time;
@synthesize timeHeader;
	

-(void) setStartTime:(unsigned long) st {
	
	timeHeader.start_time = st;
	
}


-(void) setBinSize:(unsigned long) bs {
	// setes evenly spaced to TRUE as well
	
	timeHeader.evenly_spaced = TRUE;
	timeHeader.bin_size = bs;
	
}




-(unsigned long) startTime {
	
	return(timeHeader.start_time);
}


-(unsigned long) endTime {
	
	return(timeHeader.end_time);

	
}


-(unsigned long) binSizeIfEquispaced:(BOOL *)flag {
	
	if (timeHeader.evenly_spaced) {
		(*flag) = YES;
		return timeHeader.bin_size;
	}
	else {
		(*flag) = NO;
		return 0;
	}
	
}


// -----------------------------------------------------------------------------
// utility routines ------------------------------------------------------------

// have to override these definitions from BCDataSeries  so that time_stamps will get properly set


-(void) updateHeader {
	
	[super updateHeader];
	
	BOOL outOfRange;
	
	[self findMaxMin];
	
	timeHeader.start_time = [self indexToTime:0 isOutOfRange:&outOfRange];
	timeHeader.end_time = [self indexToTime:(num_pts - 1) isOutOfRange:&outOfRange];
	
}


-(BOOL) enlargeDataArray:(unsigned long) minDataPointsRequired {
	
	unsigned long *new_time;
	unsigned long newSizeInPoints;
	BOOL mem_error = NO;
	
	
	if (![super enlargeDataArray:minDataPointsRequired]) return NO;
		
	// assume that the super object as adjusted arraySize appropriately
	newSizeInPoints = arraySize / [self getDatumSize];

	if (time  == NULL ) new_time = (unsigned long *)malloc(newSizeInPoints * sizeof(unsigned long));
	else new_time = realloc(n, newSizeInPoints * sizeof(unsigned long));
	if (new_time == NULL) mem_error = YES;	
	
	if (mem_error) return(NO); /* we're in trouble */ 
		
	time = new_time;
	
	return YES;
	
}




// -----------------------------------------------------------------------------
// Setting and Getting individual data points ---------------------------------

-(BOOL) getIndexDataPointDescriptor:(BCDataPointDescriptor *)dp {

// use the passed index value to retrieve time and data values
// return FALSE if out of range
	
	// data series call
	if (![super getIndexDataPointDescriptor:dp]) return NO;
	
	
	if (!timeHeader.evenly_spaced) 
		dp.time_stamp = time[dp.index];
	else 
		dp.time_stamp = timeHeader.start_time
		+ (dp.index * timeHeader.bin_size);
	
	
	return YES;
}


-(BOOL) setIndexDataPointDescriptor:(BCDataPointDescriptor *)dp {
	
// set the data point at the passed index value to the passed time and data values
// extend the time series if out of range
	
	// data series call
	[super setIndexDataPointDescriptor:dp];
	
	
	if (!timeHeader.evenly_spaced) {
		
		time[dp.index] = dp.time_stamp;
	}
	
	if (dp.index == 0) [self setStartTime:dp.time_stamp];
	
	return YES;	
	
	

}


- (BOOL) getTimeData:(NSNumber *)theNumber atTimePoint:(BCDataPointDescriptor *)dp isOutOfRange:(BOOL *)outOfRange; {
	
	BOOL inBetween;
	
	dp.index = [self timeToIndex:dp.time_stamp isInBetween:&inBetween isOutOfRange:outOfRange];
	
	return [self getIndexData:theNumber atDataPoint:dp ];
	


// use the passed time value to retrieve index and data values

}


- (double) getDataAsDoubleAtTime:(unsigned long) time_stamp; {
	
// retrieve a data point as a double (to avoid NSNumber overhead)
	
	BOOL inBetween, outOfRange;
	unsigned long index;
	
	index = [self timeToIndex:time_stamp isInBetween:&inBetween isOutOfRange:&outOfRange];
	
	return [self getDataAsDoubleAtIndex:index];
	

}


-(BOOL) setTimeData:(NSNumber *)theNumber atTimePoint:(BCDataPointDescriptor *)dp; {
	
// set the data point at the passed time value to the passed index and data values
// extend the data series if out of range

	
	BOOL inBetween,outOfRange;
	
	dp.index = [self timeToIndex:dp.time_stamp isInBetween:&inBetween isOutOfRange:&outOfRange];
	
	if (inBetween) {
		return [self insertIndexData:theNumber beforeDataPoint:dp];
		
	}
				 
	else {
		if (outOfRange) {
			if (dp.index == 0 && num_pts > 0) {
			 	
			 	// point falls before time series begins, so don't insert it..
			 	return NO;
			}
			else if (dp.index == num_pts) {
			 	// time falls past the end of the time series, so append to end...
				return [self setIndexData:theNumber atDataPoint:dp];
				
			}
		}
		
		else {
			// not out of range
			return [self setIndexData:theNumber atDataPoint:dp];
			
		}
		
	}
	return NO;
	
	
}



-(unsigned long) timeToIndex:(unsigned long )time_stamp isInBetween:(BOOL *)inBetween isOutOfRange:(BOOL *)outOfRange; {
	

// returns the index of a point with a timestamp >= than
//the given time .
// inBetween is TRUE if the index returned is for a point at a
// time later than given timestamp
// If the timeseries is evenly_spaced, an extrapolated
// index is returned for a time stamp bigger than the array.
// if the time series is not evenely spaced,  a -1 is returned
// for an index bigger than the array.
// if time is before start of series, a 0 is returned
// outOfRange is TRUE if before start or after last point in array
		
	unsigned long new_index = 0;
	(*inBetween) = NO;
	(*outOfRange) = NO;
	
	// if time_stamp has an index, returns index, inBetween = FALSE, outofRange = FALSE
	// if time_stamp between index1 & index2, returns index2, inBetween = TRUE, outofRange = FALSE
	
	// if time_stamp < start_time, returns index=0,inBetween = FALSE, outofRange = TRUE
	// if time_stamp > end_time, returns index = numofpts,  inBetween = FALSE, outofRange = TRUE (NB: _not_ numofpts-1)
	
	// if no datapoints, returns  returns 0,inBetween = FALSE, outofRange = TRUE
	
	if (time_stamp < timeHeader.start_time) {
		
		(*outOfRange) = YES;
		return(0);
		
	}
	
	
	if (!timeHeader.evenly_spaced) {
		
		if (time_stamp > timeHeader.end_time) {
			
			if (num_pts > 0) {
		 		(*outOfRange) = YES;
		 		return(num_pts);
			}
			
		}
		
		if ( num_pts == 0) {
			
		 	(*outOfRange) = YES;
			return(0);
			
		}
		else {
			// run through all the points and find the closest ones
			unsigned long i;
			
			i= 0;
			
			while (time_stamp > time[i] && i < num_pts) 
				i++;
			
			if (time[i] == time_stamp || i >= num_pts) return(i);
			
			else if (time[i-1] < time_stamp && time_stamp < time[i]) {
				(*inBetween) =  YES;
				return(i);
			}
			
		}
		
	}
	
	else { // evenly spaced
		
		new_index = (time_stamp - timeHeader.start_time)/timeHeader.bin_size;
		return( new_index );
		
	}
	
	// if we fall all the way through, return initial value of 0
	return(new_index);
	
	
}


-(unsigned long) indexToTime:(unsigned long)index isOutOfRange:(BOOL *)outOfRange; {

// returns an exact time stamp corresponding to the given index of
// a point.  If the timeseries is evenly_spaced, an extrapolated
// time value is returned for an index bigger than the array.
// if the time series is not evenely spaced, a -1 is returned
// for an index bigger than the array.
// outOfRange is TRUE if before start or after last point in array
	
	
	// if the given index is outside the data array, and the data is not evenlyspaced,
	// -1 is returned as an error value
	
	//if the data is evenly spaced, an extrapolated time value is returned
	
	(*outOfRange)  = NO;
	
	if (index >= num_pts) {
		
		(*outOfRange)  = YES;
		
	}
	
	if (timeHeader.evenly_spaced) {
		
		return(timeHeader.start_time + (index * timeHeader.bin_size));
	}
	
	else if (index < num_pts) return(time[index]);
	
	else return(0);	 
	
	// outside the range of time_stamps
	
	
}



// 4 ways to define a block of time in a time series
// 	StartEndBlock -- bounded by absolute start and end times
//	DurationBlock -- defined by an absolute start time and a subsequent duration
// 	OffsetBlock --  defined by an offset from the time series start and a duration
// 	EquiBlock -- divide the timeseries into equisized bins of the given duration, and ID each block by its index
//  also use IndexBlock defined in DataSeries.hpp -- startIndex to endIndex

// we'll overload all these calls as is done with NSString


-(BOOL) getBlockMean:(BCMeanValue *)mean fromStartTime:(unsigned long)startTime toEndTime:(unsigned long)endTime; {
					 
	 unsigned long startIndex, endIndex;
	 BOOL inBetween,outOfRange;
	 

	 startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:endTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;

	 return [self getBlockMean:mean fromStartIndex:startIndex toEndIndex:endIndex];
	 
 }				 
				 


-(BOOL) getBlockMean:(BCMeanValue *)mean fromStartTime:(unsigned long)startTime forDuration:(unsigned long)duration; {
	
	unsigned long startIndex, endIndex;
	BOOL inBetween,outOfRange;
	
	
	startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	if (outOfRange) return NO;
	
	endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	if (outOfRange) return NO;
	
	return [self getBlockMean:mean fromStartIndex:startIndex toEndIndex:endIndex];
	
}


-(BOOL) getBlockMean:(BCMeanValue *)mean fromOffset:(unsigned long)offsetTime forDuration:(unsigned long)duration {
	
	unsigned long startTime,startIndex, endIndex;
	BOOL inBetween,outOfRange;
	
	
	
	startTime = timeHeader.start_time + offsetTime;
	
	startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	if (outOfRange) return NO;
	
	endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	if (outOfRange) return NO;
	
	return [self getBlockMean:mean fromStartIndex:startIndex toEndIndex:endIndex];
	
	
	
}


-(BOOL) getBlockMean:(BCMeanValue *)mean fromIndex:(unsigned long)index forDuration:(unsigned long)duration {
	
	unsigned long startTime, endIndex;
	BOOL inBetween,outOfRange;
	
	
	
	startTime = [self indexToTime:index isOutOfRange:&outOfRange];
	if (outOfRange) return NO;
	
	endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	if (outOfRange) return NO;
	
	return [self getBlockMean:mean fromStartIndex:index toEndIndex:endIndex];
	
	
	
}
 -(double) getBlockSumFromStartTime:(unsigned long)startTime toEndTime:(unsigned long)endTime {
	 
	 unsigned long startIndex, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:endTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getBlockSumFromStartIndex:startIndex toEndIndex:endIndex];
	 
 }				 
 
 
 
 -(double) getBlockSumFromStartTime:(unsigned long)startTime forDuration:(unsigned long)duration {
	 
	 unsigned long startIndex, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getBlockSumFromStartIndex:startIndex toEndIndex:endIndex];
	 
 }
 
 
-(double) getBlockSumFromOffset:(unsigned long)offsetTime forDuration:(unsigned long)duration {
	 
	 unsigned long startTime,startIndex, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 startTime = timeHeader.start_time + offsetTime;
	 
	 startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getBlockSumFromStartIndex:startIndex toEndIndex:endIndex];
	 
	 
	 
 }
 
 
 -(double) getBlockSumFromIndex:(unsigned long)index forDuration:(unsigned long)duration {
	 
	 unsigned long startTime, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 
	 startTime = [self indexToTime:index isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getBlockSumFromStartIndex:index toEndIndex:endIndex];
	 
	 
	 
 }
				 


 -(BCTimeSeries *) getSubSeriesFromStartTime:(unsigned long)startTime toEndTime:(unsigned long)endTime {
	 
	 unsigned long startIndex, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:endTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getSubTimeSeriesFromStartIndex:startIndex toEndIndex:endIndex];
	 
 }				 
 
 
 
 -(BCTimeSeries *) getSubSeriesFromStartTime:(unsigned long)startTime forDuration:(unsigned long)duration {
	 
	 unsigned long startIndex, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getSubTimeSeriesFromStartIndex:startIndex toEndIndex:endIndex];
	 
 }
 
 
 -(BCTimeSeries *) getSubSeriesFromOffset:(unsigned long)offsetTime forDuration:(unsigned long)duration {
	 
	 unsigned long startTime,startIndex, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 startTime = timeHeader.start_time + offsetTime;
	 
	 startIndex = [self timeToIndex:startTime isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getSubTimeSeriesFromStartIndex:startIndex toEndIndex:endIndex];
	 
	 
	 
 }
 
 
 -(BCTimeSeries *) getSubSeriesFromIndex:(unsigned long)index forDuration:(unsigned long)duration {
	 
	 unsigned long startTime, endIndex;
	 BOOL inBetween,outOfRange;
	 
	 
	 
	 startTime = [self indexToTime:index isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 endIndex = [self timeToIndex:(startTime + duration) isInBetween:&inBetween isOutOfRange:&outOfRange];
	 if (outOfRange) return NO;
	 
	 return [self getSubTimeSeriesFromStartIndex:index toEndIndex:endIndex];
	 
	 
	 
 }
 
 
 -(BCTimeSeries *) getSubTimeSeriesFromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex {
	 
	 // if index block is longer than dataseries
	 // return a subseries that is truncated to end of parent series
	 // example: parent 0-99, indexblock 50-150, returns subseries with pts 50-99
	 
	 BCDataSeriesHeader *new_header;
	 BCTimeSeriesHeader *new_time_header;
	 unsigned long startPt,endPt, numNewPts;
	 double *new_error = NULL;
	 unsigned long *new_n = NULL;
	 char * new_data = NULL;
	 unsigned long *new_time = NULL;
	 unsigned long datum_size;
	 
	 if (startIndex > num_pts) return nil;
	 else startPt = startIndex;
	 if (endIndex >= num_pts) endPt = num_pts - 1;
	 else endPt = endIndex;
	 
	 new_header = header;
	 new_time_header = timeHeader;
	 
	 datum_size = [self getDatumSize];
	 
	 numNewPts = endPt - startPt + 1;
	 
	 new_data = malloc(datum_size * numNewPts);
	 
	 memcpy (  new_data,data + (datum_size* startPt), (datum_size* numNewPts) );
	 
	 if (header.has_error) {
		 
		 new_error = (double *)malloc(sizeof(double) * numNewPts);
		 memcpy( new_error,error + (sizeof(double) * startPt), (sizeof(double) * numNewPts) );
		 
		 new_n = (unsigned long *)malloc(sizeof(unsigned long) * numNewPts);
		 memcpy( new_n, n + (sizeof(unsigned long) * startPt), (sizeof(unsigned long) * numNewPts) );
		 
		 
	 }
	 
	 new_time  = (unsigned long *)malloc(sizeof(unsigned long) * numNewPts);
	 memcpy( new_time, time + (sizeof(unsigned long) * startPt), (sizeof(unsigned long) * numNewPts) );
	 
	 
	 BCTimeSeries *newTS = [[BCTimeSeries alloc] initWithDataSeriesHeader:new_header 
													  andTimeSeriesHeader:new_time_header
														  andData:new_data
														andNumPts:numNewPts
													andTimeStamps:new_time
															 andN:new_n
														 andError:new_error];
	 
	 return(newTS);
	 
 }
 
				 

-(BOOL) addTime:(unsigned long) timeShift {
	
	unsigned long i;
	
	if (!timeHeader.evenly_spaced) {
		for (i=0;i<num_pts;i++) {
			
			time[i]+= timeShift;
		}
		
	}
	else { timeHeader.start_time+= timeShift; } 
	
	
	[self updateHeader];
	return YES;
	
	
}


-(BOOL) subtractTime:(unsigned long) timeShift {
	unsigned long i;
	
	if (timeShift > timeHeader.start_time) return NO;
	
	if (!timeHeader.evenly_spaced) {
		for (i=0;i<num_pts;i++) {
			
			time[i]-= timeShift;
		}
		
	}
	
	else { timeHeader.start_time-= timeShift; } 
	
	[self updateHeader];
	
	return YES;
	
}




// NOTE: other functions that would be nice to see sometime

-(BOOL) mergeWithSeries:(BCTimeSeries *)ts overWrite:(BOOL)overwrite {
// add the given timeseries to ourselves
// if overwrite is true, then replace our own data with that in the given timeseries
// if it overlaps with our own points
	
// NOTE: need to implement
	
	return NO;
	
}




-(BOOL) appendBlock:(char *)new_data ofDataType:(int)datatype ofNumPts:(unsigned long)numPts atStartTime:(unsigned long)start {
// a quick way to add stuff without having to set up and merge a time series
// just given a handle of evenlyspaced data points, and stuff it in
	
	// NOTE: need to implement

	return NO;
	
}



-(BOOL) appendBlock:(char *)new_data ofDataType:(int)datatype ofNumPts:(unsigned long)numPts atStartTime:(unsigned long)start withError:(double *)new_error withN:(unsigned long)new_n {
// same as above, but with added error values
	
	// NOTE: need to implement

	
	return NO;

	
}


@end
