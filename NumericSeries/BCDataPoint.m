//
//  BCDataPoint.m
//  TongueTwister
//
//  Created by Tom Houpt on 11/8/5.
//  Copyright 2011 Behavioral Cybernetics. All rights reserved.
//

#import "BCDataPoint.h"

@implementation BCUnit
	
	@synthesize name;
	@synthesize abbr;
	@synthesize dimensionless;

-(id)init; {
	
	self = [super init];
	if (self) {
	
		dimensionless = NO;
	}
	return self;
	
}
	
@end 

@implementation BCDataPointDescriptor 

	@synthesize index;
	@synthesize time_stamp;
	@synthesize data_size; 
	@synthesize data_numeric_type;
	@synthesize data_unit;
	@synthesize unit;
	@synthesize has_error;
	@synthesize error;
	@synthesize n;

-(id)init; {

	
	self = [super init];
	
	if (self) {
	
		unit = [[BCUnit alloc] init];
	
	}
	return self;
}


@end