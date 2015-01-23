//
//  BCTimeSeries.h
//  TongueTwister
//
//  Created by Tom Houpt on 10/5/3.
//  Copyright 2010 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BCDataSeries.h"

// class TimeBasis;
#define SECSPERMINUTE 60
#define SECSPERHOUR 3600
#define SECSPERDAY 86400

@interface BCTimeSeriesHeader:NSObject {
	
	
	// time parameters 
//	TimeBasis *time_base;
	
	unsigned long start_time;
	unsigned long end_time;
	BOOL evenly_spaced; 
	// is data equally spaced or randomly time stamped? 
	unsigned long bin_size;
	// only valid if data is evenly spaced
	
	
} 

@property unsigned long start_time;
@property unsigned long end_time;
@property BOOL evenly_spaced; 
@property unsigned long bin_size;

-(void) setDefault;

@end

@interface BCTimeSeries : BCDataSeries {
	
	// added on in addition to a regular data series
	
	BCTimeSeriesHeader *timeHeader;		
	unsigned long *time; 
	// a time stamp for each data point
	// NULL if equally spaced data 
	// (then only start time and binsize needed, as indicated in the timeHeader)
	

}

// -----------------------------------------------------------------------------
// initialization and deallocation --------------------------------------------

-(id)init;
-(id)initWithDataSeriesHeader:(BCDataSeriesHeader *) hdr andTimeSeriesHeader:(BCTimeSeriesHeader *) thdr;
-(id)initWithDataSeriesHeader:(BCDataSeriesHeader *) hdr andTimeSeriesHeader:(BCTimeSeriesHeader *) thdr 
			  andData:(char *)new_data 
			andNumPts:(unsigned long)new_num_pts
		andTimeStamps:(unsigned long *)new_time 
				 andN:(unsigned long *)new_n 
			 andError:(double *)new_error;


-(void)dealloc;

// -----------------------------------------------------------------------------
// initialization from other time series  --------------------------------------------

// because these routines return time series, they are initialization calls...

-(id) initAverageTimeSeriesAlignedAtStart:(NSArray *)tsList;
// creates an average time series from a list of time series objects
// time series must all be equispaced at the same binsize
// the time series are aligned by their starts and averaged
// i.e. the first point of each series is averaged, the second are averaged, etc.
// returns NIL if there is some failure...

// success returns TRUE if the averaging was completed successfully
// if success is FALSE and the returned series is NULL, then  the series could not be averaged together
// e.g. one list was time stamped and others were equally spaced, or the bin size did not match)

-(id) initAverageTimeSeries:(NSArray *)tsList alignedAtTime:(unsigned long) alignTime;
// same as above but points with the same absolute timestamps are averaged
// returns NIL if there is some failure...


-(id) initAverageTimeSeriesAlignedAtNonZeroStart:(NSArray *)tsList;
// creates an average time series from a list of time series objects
// aligning from the first non-zero data points of each series
// returns NIL if there is some failure...


// -----------------------------------------------------------------------------
// setters and getters

// use explicit setters and getters because some values go into the timeHeader...
@property BCTimeSeriesHeader *timeHeader;		
@property unsigned long *time; 


-(void) setStartTime:(unsigned long) st;
-(void) setBinSize:(unsigned long) bs; 	// setes evenly spaced to TRUE as well


-(unsigned long) startTime;
-(unsigned long) endTime;
-(unsigned long) binSizeIfEquispaced:(BOOL *)flag;



// -----------------------------------------------------------------------------
// utility routines ------------------------------------------------------------

// have to override these definitions from BCDataSeries  so that time_stamps will get properly set


-(void) updateHeader;
-(BOOL) enlargeDataArray:(unsigned long) minDataPointsRequired;


// -----------------------------------------------------------------------------
// Setting and Getting individual data points ---------------------------------

-(BOOL) setIndexDataPointDescriptor:(BCDataPointDescriptor *)dp;
// use the passed index value to retrieve time and data values
// return FALSE if out of range

-(BOOL) setIndexDataPointDescriptor:(BCDataPointDescriptor *)dp;
// set the data point at the passed index value to the passed time and data values
// extend the time series if out of range

- (BOOL) getTimeData:(NSNumber *)theNumber atTimePoint:(BCDataPointDescriptor *)dp isOutOfRange:(BOOL *)outOfRange;
// use the passed time value to retrieve index and data values

- (double) getDataAsDoubleAtTime:(unsigned long) time_stamp;
// retrieve a data point as a double (to avoid NSNumber overhead)

-(BOOL) setTimeData:(NSNumber *)theNumber atTimePoint:(BCDataPointDescriptor *)dp;
// set the data point at the passed time value to the passed index and data values
// extend the data series if out of range


-(unsigned long) timeToIndex:(unsigned long )time_stamp isInBetween:(BOOL *)inBetween isOutOfRange:(BOOL *)outOfRange;
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

-(unsigned long) indexToTime:(unsigned long)index isOutOfRange:(BOOL *)outOfRange;
// returns an exact time stamp corresponding to the given index of
// a point.  If the timeseries is evenly_spaced, an extrapolated
// time value is returned for an index bigger than the array.
// if the time series is not evenely spaced, a -1 is returned
// for an index bigger than the array.
// outOfRange is TRUE if before start or after last point in array


// 4 ways to define a block of time in a time series
// 	StartEndBlock -- bounded by absolute start and end times
//	DurationBlock -- defined by an absolute start time and a subsequent duration
// 	OffsetBlock --  defined by an offset from the time series start and a duration
// 	EquiBlock -- divide the timeseries into equisized bins of the given duration, and ID each block by its index
//  also use IndexBlock defined in DataSeries.hpp -- startIndex to endIndex

// we'll overload all these calls as is done with NSString


-(BOOL) getBlockMean:(BCMeanValue *)mean fromStartTime:(unsigned long)startTime toEndTime:(unsigned long)endTime;
-(BOOL) getBlockMean:(BCMeanValue *)mean fromStartTime:(unsigned long)startTime forDuration:(unsigned long)duration;
-(BOOL) getBlockMean:(BCMeanValue *)mean fromOffset:(unsigned long)offsetTime forDuration:(unsigned long)duration;
-(BOOL) getBlockMean:(BCMeanValue *)mean fromIndex:(unsigned long)index forDuration:(unsigned long)duration;
// inherited from dataseries:
//-(BOOL) getBlockMean:(BCMeanValue *)mean fromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex;

-(double) getBlockSumFromStartTime:(unsigned long)startTime toEndTime:(unsigned long)endTime;
-(double) getBlockSumFromStartTime:(unsigned long)startTime forDuration:(unsigned long)duration;
-(double) getBlockSumFromOffset:(unsigned long)offsetTime forDuration:(unsigned long)duration;
-(double) getBlockSumFromIndex:(unsigned long)index forDuration:(unsigned long)duration;
// inherited from dataseries:
//-(BOOL) getBlockSumFromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex;


-(BCTimeSeries *) getSubSeriesFromStartTime:(unsigned long)startTime toEndTime:(unsigned long)endTime;
-(BCTimeSeries *) getSubSeriesFromStartTime:(unsigned long)startTime forDuration:(unsigned long)duration;
-(BCTimeSeries *) getSubSeriesFromOffset:(unsigned long)offsetTime forDuration:(unsigned long)duration;
-(BCTimeSeries *) getSubSeriesFromIndex:(unsigned long)index forDuration:(unsigned long)duration;
// re-defined from dataseries:
-(BCTimeSeries *) getSubTimeSeriesFromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex;

-(BOOL) addTime:(unsigned long) timeShift;
-(BOOL) subtractTime:(unsigned long) timeShift;
// if subtracted time interval is greater than time_header.start_time, 
// then subtract time fails (i.e. can't set start time < 0)


// other functions that would be nice to see sometime

-(BOOL) mergeWithSeries:(BCTimeSeries *)ts overWrite:(BOOL)overwrite;
// add the given timeseries to ourselves
// if overwrite is true, then replace our own data with that in the given timeseries
// if it overlaps with our own points


-(BOOL) appendBlock:(char *)new_data ofDataType:(int)datatype ofNumPts:(unsigned long)numPts atStartTime:(unsigned long)start;
// a quick way to add stuff without having to set up and merge a time series
// just given a handle of evenlyspaced data points, and stuff it in

-(BOOL) appendBlock:(char *)new_data ofDataType:(int)datatype ofNumPts:(unsigned long)numPts atStartTime:(unsigned long)start withError:(double *)new_error withN:(unsigned long)new_n;
// same as above, but with added error values


@end
