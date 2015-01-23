//
//  BCDataSeries.h
//  TongueTwister
//
//  Created by Tom Houpt on 10/4/29.
//  Copyright 2010 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BCMeanValue.h"
#import "BCDataPoint.h"

#define PAGESIZE 4096
// arrays are allocated one page at a time (i.e. 4096 bytes at a time)
// the size of a virtual memory page under Mac OS X

typedef struct {
	unsigned long startPt;
	unsigned long endPt;	
} IndexBlock;
// for indexing into an array of points; _INCLUSIVE_ of start and end point


@interface BCDataSeriesHeader : NSObject {
	
	unsigned long data_size; 
	// size in bits 
	unsigned long data_numeric_type;
	// e.g. byte, word, short, long int, fixed, float, double 
	unsigned long data_unit;
	// e.g. act, temp, pH, blood pressure, etc. 
	
	BCUnit *unit; 
	
	unsigned long sample_type ;
	// e.g. cumulative, average, instantenous, etc. 
	unsigned long data_alignment; 
	// e.g. time stamped at start of bin, end of bin, time of sample
	
	// what are the maximum and minium valid values (inclusive)
	double max_valid;
	double min_valid;
	
	// derived from the actual data series -- what are the actual max and min of the series
	double maximum;
	double minimum;
	
	// a number that represents missing data, e.g. -32000 in Circadia, etc.
	double missing_value;
	
	BOOL has_error; 
	// whether an error estimate is present for each x value in the data series
	
}

@property unsigned long data_size; 
@property unsigned long data_numeric_type;
@property unsigned long data_unit;
@property BCUnit *unit; 
@property unsigned long sample_type ;
@property unsigned long data_alignment; 
@property double max_valid;
@property double min_valid;
@property double maximum; 
@property double minimum;
@property double missing_value;
@property BOOL has_error; 

-(void)setDefault;
-(void)setDefaultForMean;

@end




@interface BCDataSeries : NSObject {
		
	
	BCDataSeriesHeader  *header;
	
	unsigned long num_pts;
	// number of data points that have been added to the series
	unsigned long arraySize; 
	// size of the buffer in BYTES...
	// so number of points is BYTES/datumSize
	// how many total points could be fit into the currently allocated array
	// should always be greater than or equal to the number of points
	
	char *data;
	// variable sized data buffer depending on size of data points
	// defined by specific subclass
	unsigned long *n;
	// number of samples making up each data point observation
	// if NULL, then exactly one observation for each point in the series 
	double *error;  
	// error associated with each time point 
	// NULL if no error associated
	


}

// -----------------------------------------------------------------------------
// initialization and deallocation --------------------------------------------

-(id)init;

-(id)initWithHeader:(BCDataSeriesHeader *) hdr;

-(id)initWithHeader:(BCDataSeriesHeader *) hdr andData:(char *)new_data andNumOfPts:(unsigned long)newNumPts andN:(unsigned long *)new_n andError:(double *)new_error;
// NOTE: BCSeries never copies the buffer it is given, so need to make sure it doesn't get deallocated by someone else...

-(void)dealloc;


// -----------------------------------------------------------------------------
// setters and getters -----------------------------------------------------------------------------

@property BCDataSeriesHeader *header;

@property (readonly) unsigned long num_pts; // number of data points
@property (readonly) unsigned long arraySize; // size of buffer in bytes allocated for data

@property (readonly) char *data; // address of the buffer holding the data
@property (readonly) double *error;
@property (readonly) unsigned long *n;

// replace "Handle GetData(unsigned long *nP,unsigned long *aS" with individual getters and setters


// number of pts, and the size of the array (handle) that holds them
// NB: this is the handle to the data itself, NOT a separate copy of the data

-(void)setData:(char *)d withNumPts:(unsigned long)nP withN:(unsigned long *)newN andError:(double *)newError withArraySize:(unsigned long)aS andFreeOldData:(BOOL)freeOldData;


// -----------------------------------------------------------------------------
// utility routines ------------------------------------------------------------



-(BOOL) isValidValue:(double) value; 
// for the given data series, is the given value valid 
// (i.e. between min and max valid in the header)

-(void) updateHeader; 
// run through the series to find the current min and max values...


-(BOOL) enlargeDataArray:(unsigned long) minDataPointsRequired;
// allocate more memory to the data array


-(BOOL) getBlockMean:(BCMeanValue *)mean fromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex;
// get the mean of a given block (inclusive of the startpt and end pt)

-(double) getBlockSumFromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex;
// get the sum of a given block (inclusive of the startpt and end pt)

-(unsigned long) getDatumSize;
// returns the size in bytes of an individual datum; i.e. if this data series consists of longs, then the datum size is 4 bytes

-(BCDataSeries *) getSubSeriesfromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex;
// gets a subseries with just the specificed range of data points
// if index block is longer than dataseries
// return a subseries that is truncated to end of parent series
// example: parent 0-99, indexblock 50-150, returns subseries with pts 50-99


-(void) findMaxMin;
// reset the maximum and minimum value in the DSHeader


-(void) setMissingFromIndex:(unsigned long) startIndex toIndex:(unsigned long) endIndex;
// set a run of data points equal to the missing data value		
// (inclusive of the startpt and end pt)


// -----------------------------------------------------------------------------
// Setting and Getting individual data points

-(BOOL) getIndexDataPointDescriptor:(BCDataPointDescriptor *)dp;
// get the description of the data point	


-(BOOL) setIndexDataPointDescriptor:(BCDataPointDescriptor *)dp;
// set the description of a data point


// in the classic C++ version, 
// all of the setting and getting of data is overloaded so that type conversions will appear automatic
// replace all that with NSNumber, but keep internal conversion to subtype for more efficient packing

- (BOOL) getIndexData:(NSNumber *)theNumber atDataPoint:(BCDataPointDescriptor *)dp;
// use the passed index value to retrieve time and data values

- (double) getDataAsDoubleAtIndex:(unsigned long) index;
// retrieve a data point as a double (to avoid NSNumber overhead)

- (unsigned long) getDataAsUnsignedLongAtIndex:(unsigned long) index;
// retrieve a data point as a double (to avoid NSNumber overhead)

- (BOOL) setIndexData:(NSNumber *)theNumber atDataPoint:(BCDataPointDescriptor *)dp;
// set the data point at the passed index value to the passed time and data values

- (BOOL) insertIndexData:(NSNumber *)theNumber beforeDataPoint:(BCDataPointDescriptor *)dp;
// insert the given data point immediately before its index number
// i.e. if dp->index == 13, 
// insert dp->data between (*data)[12] and (*data)[13]


- (BOOL) appendBlock:(char*)new_data ofDataType:(short) datatype ofNumPts:(unsigned long)numPts;
// a quick way to add stuff without having to set up and merge a series
// just given a handle of evenlyspaced data points, and stuff it in

- (BOOL) appendBlock:(char*)new_data ofDataType:(short) datatype ofNumPts:(unsigned long)numPts withN: (unsigned long *)new_n withError:(double *)new_error;
// same as above, but with added error values


@end
