//
//  BCTableWebView.m
//  Bartender
//
//  Created by Tom Houpt on 12/7/15.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BCTableWebView.h"
#import "DailyData.h"
#import "BarExperiment.h"

@implementation BCTableWebView


-(id)initWithTableView:(NSTableView *)table; {
	
	NSRect frameRect = NSMakeRect(0,0,490,720);
	// NOTE: this should be paper size? 
	// or should it be calculated from size of NSTableView?
	
	self = [super  initWithFrame:frameRect frameName:nil groupName:nil];
	
	if (self) {
		
		tableView = table;
		
		if (nil == htmlString) {
			
			htmlString = [[NSMutableString alloc] init];
			
			[self appendDailyDataInfoToString:htmlString];
			
			[self appendHtmlFromTableToString:htmlString];
			
			[[self mainFrame] loadHTMLString:htmlString baseURL:nil];
			
		}
		
		
	}
	
	return self;
	
}


-(void) appendDailyDataInfoToString:(NSMutableString *)buffer; {
	
	// expt_code: expt_name
	[buffer appendFormat:@"<P><STRONG>%@</STRONG></P>",[[dailyData theExperiment] codeName]];
	
	// Days completed: expt_days
	[buffer appendFormat:@"<P>Days completed: %d</P>", [[dailyData theExperiment] numberOfDays]];
	
	// Phase: phase name; Day phase_day
	[buffer appendFormat:@"<P>Phase: %@ Day %d</P>", [dailyData phaseName], [dailyData phaseDayIndex]];
	
	// weighed on:
	[buffer appendFormat:@"<P>Weighed on: %@</P>", [dailyData onTimeString]];

	// weighed off:
	[buffer appendFormat:@"<P>Weighed off: %@</P>", [dailyData onTimeString]];
	
}

- (void) appendHtmlFromTableToString:(NSMutableString *)buffer; {
	
	
	[buffer appendString: @"<table>\r"];
	
	[self appendHeadersToString:buffer];
	
	unsigned long rowIndex;
	unsigned long numRows = [tableView numberOfRows];
	
	for (rowIndex=0;rowIndex<numRows;rowIndex++) {
		
		[self appendRowAtIndex:rowIndex toString:buffer];
		
	}
		
	[buffer appendString: @"</table>\r"];
		
}

-(void)appendHeadersToString:(NSMutableString *)buffer; {
	

	[buffer appendString: @"\t<TR>\r"];

	for (NSTableColumn *aTableColumn in [tableView tableColumns]) {

		[buffer appendString: @"\t\t<TH>"];
		
		[buffer appendString:[[aTableColumn headerCell] stringValue]];
	
		[buffer appendString: @"</TH>\r"];
		
	}
	
	[buffer appendString: @"\t</TR\r>"];

}

-(void)appendRowAtIndex:(unsigned long)rowIndex toString:(NSMutableString *)buffer; {
	

	[buffer appendString: @"\t<TR>"];
	
	
	for (NSTableColumn *aTableColumn in [tableView tableColumns]) {
			
		[buffer appendString: @"\t\t<TD>"];
		
		NSString *objectValue = [[tableView dataSource] tableView:tableView objectValueForTableColumn:aTableColumn row:rowIndex];
		
		if (objectValue) { [buffer appendString:objectValue]; }
		
		else { [buffer appendString:@"--"]; }
		
		[buffer appendString: @"</TD>\r"];
		
	}

	[buffer appendString: @"\t</TR>\r"];
	
	
}
	

- (NSString *)stringForObjectValue:(id)anObject; {
	
	// Textual representation of cell content
	// taken from "MyValueFormatter.m" of "QTMetadataEditor" sample code
		
	NSString *resultString;
		
	if ([anObject isMemberOfClass:[NSData class]]) {
		// resultString = [MyValueFormatter hexStringFromData:(NSData *)anObject];
	}
	else if ([anObject isMemberOfClass:[NSString class]]) {
		resultString = anObject;
	}
	else if ([anObject isMemberOfClass:[NSNumber class]]) {
		resultString = [anObject stringValue];
	}
	return resultString;
}
	


@end
