//
//  BCDataPoint.h
//  TongueTwister
//
//  Created by Tom Houpt on 10/4/29.
//  Copyright 2010 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum dtype {tBOOLEAN = 0, tBYTE,tSHORT ,tUSSHORT, tFIXED,tLONG,tUSLONG, tDOUBLE};
// numeric type of the data 
// NOTE: for cocoa rewrite, we may constrain this to a smaller set of types, e.g. BOOL, USLONG, and DOUBLE

enum samtype {CUMULATIVE = 0, INSTANT, AVERAGE};
// sample type of the data

enum datatype {ACTIVITY = 0, TEMPERATURE};
// measure type of the data
// left over from circadia, I think 

enum align {BINSTART = 0, BINEND, BINMID, TIMESTAMP};
// data that is collected across bins could be timestamped with the start, middle, or end of the collection bin,
// if it is instantaneous data, then it is just time stamped



@interface BCUnit : NSObject {
	
	NSString *name;
	NSString *abbr;
	BOOL dimensionless;
	
}

@property NSString *name;
@property NSString *abbr;
@property BOOL dimensionless;

@end




// data point gives all the parameters of the data point without the actual value


@interface BCDataPointDescriptor : NSObject {
		
		unsigned long index;
		unsigned long time_stamp;
		// not used by data series, but is used by time series
		// for convenience we leave it here
		unsigned long data_size; 
		// size in bits 
		unsigned long data_numeric_type;
		// e.g. byte, word, short, long int, fixed, float, double 
		unsigned long data_unit;
		// e.g. act, temp, pH, blood pressure, etc. 
		BCUnit *unit;
		// text representation of unit type
		
		// does the data point have an error associated with it?
		// if so, here is the error and n
		BOOL has_error;
		double error;
		unsigned long n;
		
	
}

@property unsigned long index;
@property unsigned long time_stamp;
@property unsigned long data_size; 
@property unsigned long data_numeric_type;
@property unsigned long data_unit;
@property BCUnit *unit;
@property BOOL has_error;
@property double error;
@property unsigned long n;


@end


