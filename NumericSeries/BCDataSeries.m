//
//  BCDataSeries.m
//  TongueTwister
//
//  Created by Tom Houpt on 10/4/29.
//  Copyright 2010 Behavioral Cybernetics. All rights reserved.
//

#import "BCDataSeries.h"

@implementation BCDataSeriesHeader

	@synthesize data_size; 
	@synthesize data_numeric_type;
	@synthesize data_unit;
	@synthesize unit; 
	@synthesize sample_type ;
	@synthesize data_alignment; 
	@synthesize max_valid;
	@synthesize min_valid;
	@synthesize maximum; 
	@synthesize minimum;
	@synthesize missing_value;
	@synthesize has_error; 


-(id)init; {
	
	self = [super init];
	if (self) {
		
		[self setDefault];
	}
	return self;
	
}

-(void)setDefault; {
	
	// define defaults as if for short series
	
	data_size = sizeof(short) * 8; 
	// size in bits 
	data_numeric_type = tSHORT;
	// e.g. byte, word, short, long int, fixed, float, double 
	data_unit = ACTIVITY;
	// e.g. act, temp, pH, blood pressure, etc. 
	sample_type = CUMULATIVE ;
	// e.g. cumulative, average, instantenous, etc.
	
	unit = [[BCUnit alloc] init];
	
	data_alignment = BINEND; 
	// e.g. time stamped at start of bin, end of bin, time of sample
	max_valid = 32000;
	min_valid = -32000;
	missing_value = -32001;
	
	maximum = missing_value;
	minimum = missing_value;
	has_error = FALSE; 
	// whether an error estimate is present for each x value 
	
}

-(void) setDefaultForMean; {
	
	// define defaults as if for short series
	
	data_size = sizeof(double) * 8; 
	// size in bits 
	data_numeric_type = tDOUBLE;
	// e.g. byte, word, short, long int, fixed, float, double 
	data_unit = ACTIVITY;
	// e.g. act, temp, pH, blood pressure, etc. 
	sample_type = AVERAGE ;
	// e.g. cumulative, average, instantenous, etc. 
	data_alignment = BINEND; 
	// e.g. time stamped at start of bin, end of bin, time of sample
	max_valid = 32000;
	min_valid = -32000;
	missing_value = -32001;
	
	maximum = missing_value;
	minimum = missing_value;
	has_error = TRUE; 
	// whether an error estimate is present for each x value 
	
}

@end



@implementation BCDataSeries

// ----------------------------------------------------------------------------------------------
// initialization and deallocation ---------------------------------------------------------
// ----------------------------------------------------------------------------------------------

-(id)init {
	
	self = [super init];
	
	if (self) {
		
		// some defaults
		header = [[BCDataSeriesHeader alloc] init];
		num_pts = 0;
		arraySize = 0;
		data = NULL;
		error = NULL;
		n = NULL;
		
	}
	
	return self;
	
	
}

-(id)initWithHeader:(BCDataSeriesHeader *) hdr {
	
	self = [super init];
	
	if (self) {
		header = hdr;
		num_pts = 0;
		arraySize = 0;
		data = NULL;
		error = NULL;
		n = NULL;
		
	}
	
	return self;
	
}

-(id)initWithHeader:(BCDataSeriesHeader *) hdr andData:(char *)new_data andNumOfPts:(unsigned long)newNumPts andN:(unsigned long *)new_n andError:(double *)new_error {
	
	
	self = [super init];

	if (self) {
		
		header = hdr;
		num_pts = newNumPts;
		// under OS9, could ask how big the handle was but I don't think we can do that using just malloc buffers
		// num_pts = GetHandleSize(new_data) / (header.data_size / 8);
		arraySize = num_pts * [self getDatumSize];
		data = new_data;
		error = new_error;
		n = new_n;
	}

	return self;
	
}


-(void) dealloc {
	
	if (data != NULL) free(data);
	if (error != NULL) free(error);
	if (n != NULL) free(n);
	
	[super dealloc];
}

// ----------------------------------------------------------------------------------------------
// setters and getters --------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------

-(BCDataSeriesHeader *)header {
	
	return(header);
	
}

-(void)setHeader:(BCDataSeriesHeader *) h {
	
	header = h;
	
}

-(unsigned long) num_pts { return (num_pts); }

-(unsigned long) arraySize { return (arraySize); }

-(char *)data { return(data);}

-(double *)error {
	
	if (header.has_error) return(error);
	else return(NULL);
}

-(unsigned long *)n {
	
	if (header.has_error) return(n);
	else return(NULL);
}

-(void)setData:(char *)d withNumPts:(unsigned long)nP withN:(unsigned long *)newN andError:(double *)newError withArraySize:(unsigned long)aS andFreeOldData:(BOOL)freeOldData {
	
	if (freeOldData) {
		if( data != NULL) free(data);
		if(error != NULL) free(error);
		if(n != NULL) free (n);		
	}
	data = d;
	num_pts = nP;
	arraySize = aS;
	n= newN;
	error = newError;
	
}

// ----------------------------------------------------------------------------------------------
// utility routines -----------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------

-(BOOL) isValidValue:(double)value {
	
	// for the given data series, is the given value valid 
	// (i.e. between min and max valid in the header)
	
	if (value == header.missing_value) return NO;		
		
	if	( header.min_valid <= value && value <=  header.max_valid )
		return YES;
	else
		return NO;
	
	return YES;
	
}

-(void) updateHeader  { [self findMaxMin]; }
// run through the series to find the current min and max values...


-(BOOL) enlargeDataArray:(unsigned long) minBCDataPointsRequired {
	// allocate more memory to the data array
	// to accomodate the given number of data points
	// (need to allocate "datumSize" bytes for each data point

	
	unsigned long newSizeInBytes,newSizeInPoints;
	unsigned long datumBytes;
	unsigned long minBytesRequired;
	char *new_data;
	unsigned long *new_n;
	double *new_error;
	
	BOOL mem_error = NO;
	
	datumBytes = [self getDatumSize];
	minBytesRequired = minBCDataPointsRequired * datumBytes;
	
	newSizeInBytes = arraySize;
	do {
		
		newSizeInBytes+=PAGESIZE;
		
	} while (newSizeInBytes < minBytesRequired);
	
	newSizeInPoints = newSizeInBytes/ datumBytes;
		
	if (data == NULL) new_data = malloc(newSizeInBytes);
	else new_data = realloc(data, newSizeInBytes);
	
	if (new_data == NULL) mem_error = YES;
			
	if (header.has_error) {
		if (error == NULL) new_error = (double *)malloc(newSizeInPoints * sizeof(double));
		else new_error = (double *)realloc(error, newSizeInPoints * sizeof(double));	
		if (new_error == NULL) mem_error = YES;
		
		if (n == NULL ) new_n = (unsigned long *)malloc(newSizeInPoints * sizeof(unsigned long));
		else new_n = realloc(n, newSizeInPoints * sizeof(unsigned long));
		if (new_n == NULL) mem_error = YES;	
	} 
	
	if (mem_error) return(NO); /* we're in trouble */ 
		
	data = new_data;
	arraySize = newSizeInBytes;

	if (header.has_error) {
		error = new_error;
		n = new_n;
	}
		
	
	/* fill the new points with missing values */
	[self setMissingFromIndex:num_pts toIndex:(newSizeInPoints - 1)];
	
	return (YES);
	
}


-(BOOL) getBlockMean:(BCMeanValue *)mean fromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex {
// get the mean of a given block (inclusive of the startpt and end pt)

	
	unsigned long i;
	double datum;
	
	[mean zeroMean];
	
	for (i=startIndex;i<=endIndex;i++) {
		
		datum = [self getDataAsDoubleAtIndex:i];
		
		if (  datum !=  header.missing_value ) {
			
			[mean sumMean:datum];
		}
		
	}
	
	if (mean.num == 0) return NO;
	
	[mean divideMean];
	
	// calculate the SEM as well, some time;
	
	for (i=startIndex;i<endIndex;i++) {
		
		datum = [self getDataAsDoubleAtIndex:i];
		
		if (  datum !=  header.missing_value ) {
			
			[mean sumErr:datum];
		}
		
	}
	
	[mean divideErr];
	
	return YES;
	
}

-(double) getBlockSumFromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex {
// get the sum of a given block (inclusive of the startpt and end pt)
	
	unsigned long i;
	double datum;
	double sum;
	
	sum = 0.0;
	
	for (i=startIndex;i<=endIndex;i++) {
		
		datum = [self getDataAsDoubleAtIndex:i];
		
		if (  datum !=  header.missing_value ) {
			
			sum+= datum;
		}
		
	}
	
	return sum;

}

-(unsigned long) getDatumSize {
	
	unsigned long datum_size;
	
	switch (header.data_numeric_type) {
			
		case tBOOLEAN: datum_size = sizeof(Boolean); break;
			
		case tBYTE: datum_size = sizeof(unsigned char); break;
			
		case tSHORT: datum_size = sizeof(short); break;
			
		case tUSSHORT: datum_size = sizeof(unsigned short); break;
			
		case tFIXED: datum_size = sizeof(Fixed); break;
			
		case tLONG: datum_size = sizeof(long); break;
			
		case tUSLONG: datum_size = sizeof(unsigned long); break;
			
		case tDOUBLE: datum_size = sizeof(double); break;
			
	}
	
	return(datum_size);
}

-(BCDataSeries *) getSubSeriesfromStartIndex:(unsigned long)startIndex toEndIndex:(unsigned long)endIndex {
	
	// if index block is longer than dataseries
	// return a subseries that is truncated to end of parent series
	// example: parent 0-99, indexblock 50-150, returns subseries with pts 50-99
	
	BCDataSeriesHeader *new_header;
	unsigned long startPt,endPt, numNewPts;
	double *new_error = NULL;
	unsigned long *new_n = NULL;
	char * new_data = NULL;
	unsigned long datum_size;
	
	if (startIndex > num_pts) return nil;
	else startPt = startIndex;
	if (endIndex >= num_pts) endPt = num_pts - 1;
	else endPt = endIndex;
	
	new_header = header;
	
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
	
	BCDataSeries *newDS = [[BCDataSeries alloc] initWithHeader:new_header andData:new_data andNumOfPts:numNewPts andN:new_n andError:new_error];
	
	return(newDS);
	
}

-(void) findMaxMin {
	
	unsigned long i;
	BOOL firstPass = YES;
	double datum;
	
	if (num_pts < 1) {
		header.maximum= header.missing_value;
		header.minimum= header.missing_value;
		return;
	}	
	
	for (i=0;i<num_pts;i++) {
		
		
		datum = [self getDataAsDoubleAtIndex:i];
		
		if (  datum !=  header.missing_value ) {
			
			if (firstPass) {
				
				header.minimum = datum;
				header.maximum = datum;
				firstPass = NO;
				
			}
			
			if (header.maximum < datum) header.maximum = datum;
			if (datum < header.minimum) header.minimum = datum;
		}
		
	}
	
}		

-(void) setMissingFromIndex:(unsigned long) startIndex toIndex:(unsigned long) endIndex {
	
	// set a run of data points equal to the missing data value	
	unsigned long index;
	if (startIndex > num_pts-1) return;
	if (endIndex > num_pts-1) endIndex = num_pts -1;
	
	for (index=startIndex;index<=endIndex;index++) {
		
		switch (header.data_numeric_type) {
				
			case tBOOLEAN:
				((Boolean *)(data))  [index]  = header.missing_value;
				break;
				
			case tBYTE:
				((unsigned char *)(data))[index]  = header.missing_value;
				break;
				
			case tSHORT:
				((short *)(data))[index]  = header.missing_value;
				break;
				
			case tUSSHORT:
				((unsigned short *)(data))[index]  = header.missing_value;
				break;
				
			case tLONG:
				((long *)(data))[index]  = header.missing_value;
				break;
				
			case tUSLONG:
				((unsigned long *)(data))[index]  = header.missing_value;
				break;
				
			case tDOUBLE:
				((double *)(data))[index]  = header.missing_value;
				break;
				
				
		}
		
	}
	
	
	
}

// ----------------------------------------------------------------------------------------------
// Setting and Getting individual data points ---------------------------------------------------
// ----------------------------------------------------------------------------------------------

-(BOOL) getIndexDataPointDescriptor:(BCDataPointDescriptor *)dp {
	
	// NOTE: this seems awkward, because it gets a descriptor and error and n, but not the actual values
	
	// caller has passed a BCDataPoint (descriptor) which only contains an index number
	// we fill in the remaining fields of the BCDataPoint  (descriptor)
	
	if (dp.index >= num_pts) return(NO);
	
	dp.has_error =  header.has_error;
	
	if (header.has_error) {
		// error is double *
		// n is unsigned long *
		dp.error = (error)[dp.index];
		dp.n = (n)[dp.index];
	}
	
	dp.data_size = header.data_size;
	dp.data_numeric_type = header.data_numeric_type;
	dp.data_unit = header.data_unit;
	
	return(YES);
}



-(BOOL) setIndexDataPointDescriptor:(BCDataPointDescriptor *)dp {
	// caller has passed a BCDataPoint (descriptor) which  contains an index number
	// and also contains an "standard error" term and a "n" for that particular datum

	// set the data point at the passed index value to the passed time and data values
	
	if (dp.index >= num_pts) {
		// a new point to be added at the end of the timeseries
		
		num_pts = dp.index + 1;
		
		if (num_pts >= arraySize / [self getDatumSize]) 
			if(![self enlargeDataArray:num_pts]) 
				return(NO);
		// check if the data array needs to be enlarged
	}
	
	
	if (header.has_error) {
		// error is double *
		// n is unsigned long *
		(error)[dp.index] = dp.error;
		(n)[dp.index] = dp.n;
		
		
	}
	
	return(YES);
}




- (BOOL) getIndexData:(NSNumber *)theNumber atDataPoint:(BCDataPointDescriptor *)dp {
	
	// use the passed index value to retrieve time and data values
	
	if (! [self getIndexDataPointDescriptor:dp] ) return (NO);
	
	// auto convert the data type
	
	switch (header.data_numeric_type) {
			
		case tBOOLEAN:
			[theNumber initWithBool:(Boolean)(   ((Boolean *)(data))  [dp.index]  )];
			break;
			
		case tBYTE:
			[theNumber initWithUnsignedChar:(unsigned char)(((unsigned char *)(data))[dp.index] )];
			break;
			
		case tSHORT:
			[theNumber initWithShort: (short)(((short *)(data))[dp.index] )];
			break;
			
		case tUSSHORT:
			[theNumber initWithUnsignedShort: (unsigned short)(((unsigned short *)(data))[dp.index] )];
			break;
			
		case tLONG:
			[theNumber initWithLong: (long)(((long *)(data))[dp.index] )];
			break;
			
		case tUSLONG:
			[theNumber initWithUnsignedLong: (unsigned long)(((unsigned long *)(data))[dp.index] )];
			break;
			
		case tDOUBLE:
			[theNumber  initWithDouble: (double)(((double *)(data))[dp.index] )];
			break;
			 
			
	}
	
	return(YES);
	
	
	
}


- (double) getDataAsDoubleAtIndex:(unsigned long) index {
	
	// use the passed index value to retrieve data values as a double
	double datum;
	
	if (index > [self num_pts]) {
		datum = header.missing_value;
		return datum;
	}
	
	switch (header.data_numeric_type) {
			
		case tBOOLEAN:
			datum = (double)(((Boolean *)(data))[index]);
			break;
			
		case tBYTE:
			datum = (double)(((unsigned char *)(data))[index] );
			break;
			
		case tSHORT:
			datum = (double)(((short *)(data))[index] );
			break;
			
		case tUSSHORT:
			datum = (double)(((unsigned short *)(data))[index] );
			break;
			
		case tLONG:
			datum = (double)(((long *)(data))[index] );
			break;
			
		case tUSLONG:
			datum = (double)(((unsigned long *)(data))[index] );
			break;
			
		case tDOUBLE:
			datum = (double)(((double *)(data))[index] );
			break;
			
			
	}
	
	return(datum);
	
	
	
}

- (unsigned long) getDataAsUnsignedLongAtIndex:(unsigned long) index {
	
	// use the passed index value to retrieve data values as a double
	double datum;
	
	if (index > [self num_pts]) {
		datum = header.missing_value;
		return datum;
	}
	
	switch (header.data_numeric_type) {
			
		case tBOOLEAN:
			datum = (unsigned long)(((Boolean *)(data))[index]);
			break;
			
		case tBYTE:
			datum = (unsigned long)(((unsigned char *)(data))[index] );
			break;
			
		case tSHORT:
			datum = (unsigned long)(((short *)(data))[index] );
			break;
			
		case tUSSHORT:
			datum = (unsigned long)(((unsigned short *)(data))[index] );
			break;
			
		case tLONG:
			datum = (unsigned long)(((long *)(data))[index] );
			break;
			
		case tUSLONG:
			datum = (unsigned long)(((unsigned long *)(data))[index] );
			break;
			
		case tDOUBLE:
			datum = (unsigned long)(((double *)(data))[index] );
			break;
			
			
	}
	
	return(datum);
	
	
	
}



-(BOOL) setIndexData:(NSNumber *)theNumber atDataPoint:(BCDataPointDescriptor *)dp {
	
	// set the data point at the passed index value to the passed time and data values
	
	if (![self setIndexDataPointDescriptor:dp] ) return(NO);
	
	
	switch (header.data_numeric_type) {
			
		case tBOOLEAN:
			((Boolean *)(data))[dp.index] = [theNumber boolValue];
			break;
			
		case tBYTE:
			((unsigned char *)(data))[dp.index] = [theNumber unsignedCharValue];
			break;
			
		case tSHORT:
			((short *)(data))[dp.index] = [theNumber shortValue];
			break;
			
		case tUSSHORT:
			((unsigned short *)(data))[dp.index] = [theNumber unsignedShortValue];
			break;
			
		case tLONG:
			((long *)(data))[dp.index] = [theNumber longValue];
			break;
			
		case tUSLONG:
			((unsigned long *)(data))[dp.index] = [theNumber unsignedLongValue];
			break;
			
		case tDOUBLE:
			((double *)(data))[dp.index] = [theNumber doubleValue];
			break;
			
			
	}
	
	
	return (TRUE);
	
}

-(BOOL) insertIndexData:(NSNumber *)theNumber beforeDataPoint:(BCDataPointDescriptor *)dp {
	
	
	// NOTE need to implement this!
	
	return NO;

}


-(BOOL) appendBlock:(char*)new_data ofDataType:(short) datatype ofNumPts:(unsigned long)numPts {
	
	// a quick way to add stuff without having to set up and merge a series
	// just given a handle of evenlyspaced data points, and stuff it in
	// return FALSE if a memory allocation problem, or if datatype doesn't match
	
	if (datatype != header.data_numeric_type) return (FALSE);
	
	
	// a quick way to add stuff without having to set up and merge a time series
	// just given a handle of evenlyspaced data points, and stuff it in at end
	
	unsigned long startPt,endPt,datumSize;
	

	
	startPt =  num_pts;
	endPt = startPt + numPts - 1;
	
	if (endPt >=num_pts) {
		// new points to be added at the end of the timeseries
		
		num_pts = endPt + 1;
		
		if (num_pts >= arraySize / [self getDatumSize]) [self enlargeDataArray:num_pts];
		// check if the data array needs to be enlarged
	}
	
	datumSize = [self getDatumSize];
	
	memcpy( (data + (datumSize * startPt)), new_data, (datumSize * numPts) );
	
	[self updateHeader];
	
	return(TRUE);
	
}

-(BOOL) appendBlock:(char*)new_data ofDataType:(short) datatype ofNumPts:(unsigned long)numPts withN:(unsigned long *)new_n withError:(double *)new_error {

	// same as above, but with added error values
	unsigned long startPt,endPt;
	
	startPt =  num_pts;
	endPt = startPt + numPts - 1;
	
	if (![self appendBlock:new_data ofDataType: datatype ofNumPts:numPts]) return NO;

	if (new_error != NULL) {
		memcpy(  (error + (sizeof(double) * startPt)), new_error,(sizeof(double) * numPts) );
	}
	if (new_n != NULL) {
		
		memcpy( (n + (sizeof(unsigned long) * startPt)), new_n, (sizeof(unsigned long) * numPts) );
		
	}
	return YES;
}




@end
