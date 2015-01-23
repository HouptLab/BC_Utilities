//
//  BCMeanValue.m
//  TongueTwister
//
//  Created by Tom Houpt on 10/4/29.
//  Copyright 2010 Behavioral Cybernetics. All rights reserved.
//

#import "BCMeanValue.h"

#define SQUARE(x) ((x)*(x))

@implementation BCMeanValue

-(double)mean {return (mean); }
-(unsigned long)num {return (num); }
-(double)stdev; {return (stdev); }
-(double)SEM {return (SEM); }

-(void) zeroMean { mean = 0; stdev = 0; SEM = 0; num = 0; }

-(void) sumMean:(double) x { mean+= x; num++;}

-(void) sumNonZeroMean:(double) x { if (x != 0) {mean+= x; num++;}}

-(void) divideMean { if (num > 0) mean /= num; }

-(void) sumErr:(double) x { stdev += SQUARE( (x - mean) ); }

-(void) sumNonZeroErr:(double) x { if (x != 0) stdev += SQUARE( (x - mean) ); }

-(void) divideErr {
	// NOTE: we divide sum of squared deviations (in stdev) by (num - 1) to get sample standard deviation (final value of stdev)
	// NOTE: we divide stdev by sqrt(num) to get SEM
	if (num > 1) {
		stdev /= (num - 1);
		stdev = sqrt(stdev); // final stdev
		SEM = stdev/ sqrt((double)(num));
	}
	else {
		stdev = 0;
		SEM = 0;
	}
}

-(NSString *) justMean2Text {
	
	NSString *text;	
	
	if (num == 0) text = kNoDataCellText;
	else text = [NSString stringWithFormat:@"%.2f", mean];
	
	return text;
	
	
}

-(NSString *) justSEM2Text {
	
	NSString *text;	

	if (num < 2)  text = kNoDataCellText;
	else [NSString stringWithFormat:@"%.2f", SEM ];
	
	return text;
}

-(NSString *) mean2Text {
	
	NSString *text;	
	
	if (num == 0)  text =kNoDataCellText;
	else if (num == 1) text = [NSString stringWithFormat:@"%.2f (%lu)", mean,num];
	else text = [NSString stringWithFormat:@"%.2f ± %.2f (%lu)", mean,SEM,num];
	
	return text;
}

-(NSString *) mean2FileText {
	
	NSString *text;	
	
	if (num == 0) text = [NSString stringWithFormat:@"%@\t%@\t%@\t", kNoDataCellText,kNoDataCellText,kNoDataCellText];
	else if (num == 1) text = [NSString stringWithFormat:@"%f\t%@\t%lu\t", mean,kNoDataCellText,num];
	else text = [NSString stringWithFormat:@"%f\t%f\t%lu\t", mean,SEM,num];
				 
	return text;				 
}


@end
