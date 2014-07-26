//
//  BCTableHtmlFormatter.m
//  Bartender
//
//  Created by Tom Houpt on 12/7/15.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BCTableHtmlFormatter.h"


@implementation BCTableHtmlFormatter


-(id)initWithTableView:(NSTableView *)table andTableID:(NSString *)tid; {
	
	
	self = [super  init];
	
	if (self) {
		
		tableView = table;
		tableID = tid;
		
		useVerticalLines = YES;
		useAlternatingRowColors = YES;
	}
	
	return self;
	
}

-(void) setTableView:(NSTableView *)table; { tableView = table; } 

- (NSString *) htmlString; {
	
	NSMutableString *htmlString = [[NSMutableString alloc] init];
	
	[self appendHtmlToString:htmlString];
	
	return htmlString;
	
	
}

-(void)appendCssToString:(NSMutableString *)buffer; {
		
	
	NSMutableString *cssString = [[NSMutableString alloc] init];
	
	[cssString appendString: @"<style>\n"];
	
	NSString *prefixString;
	
	if (nil == tableID) prefixString = @".datatable";
	else prefixString = [NSString stringWithFormat:@"#%@",tableID];
		
	// specify 12 pt fonts for table
	
	[cssString appendFormat: @"%@ th, td {font-family: Helvetica, sans-serif; font-size:9pt;} \n", prefixString];
//	[cssString appendFormat: @"%@ table { border-style: hidden } \n", prefixString];


//	// to put vertical rules between columns, set 
//	td: { border-style: none solid none solid; border-width:thin; }
//  or is this better?
//	col { border-style: none solid }

//	
//	// to put rule under header row, set 
//	th: { border-style: none none solid none; }
		
	
	// make san-serif
	if (useAlternatingRowColors) {
		
		//  http://www.w3.org/Style/Examples/007/evenodd.en.html
		
		[cssString appendFormat: @"%@ tr:nth-child(odd)  { background-color:#ddd; } \n", prefixString];
		[cssString appendFormat: @"%@ tr:nth-child(even)   { background-color:#fff; } \n", prefixString];
		
		// be sure to set up the webpreferences of the webview to print backgrounds, e.g.
		
		//		[myWebView setPreferencesIdentifier:@"myWebPreferences"];
		//		WebPreferences *prefs = [myWebView preferences];
		//		[prefs setShouldPrintBackgrounds:YES];
		
		
	}
	
	[cssString appendString: @"</style>\n"];
	
	[buffer appendString:cssString];
	
}



- (void) appendHtmlToString:(NSMutableString *)buffer; {
	
	
	
	[self appendCssToString:buffer];
	
	[buffer appendFormat: @"<TABLE "];
	
	
	if (nil == tableID)[buffer appendString: @"class = \"datatable\" "];
	else [buffer appendFormat: @"id = \"%@\" ",tableID];

	
	
	NSString *rulesString;	
	
	if (!useVerticalLines && !useHorizontalLines) {rulesString = @"rules=none ";}
	if ( useVerticalLines && !useHorizontalLines) {rulesString = @"rules=cols "; }
	if (!useVerticalLines &&  useHorizontalLines) {rulesString = @"rules=rows "; }
	if ( useVerticalLines &&  useHorizontalLines) {rulesString = @"rules=all "; }
	
	if (nil == tableID)[buffer appendString: rulesString];
	
	[buffer appendString: @">\n"];

	[self appendHeadersToString:buffer];
	
	NSInteger rowIndex;
	NSInteger numRows = [tableView numberOfRows];
	
	for (rowIndex=0;rowIndex<numRows;rowIndex++) {
		
		[self appendRowAtIndex:rowIndex toString:buffer];
		
	}
		
	[buffer appendString: @"</TABLE>\n"];
	
//	NSError *error;
//    
//    NSString *testFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] stringByAppendingPathComponent:@"tableHtmlTest.html"];
//    
//	[buffer writeToFile:testFilePath atomically:YES encoding:NSUnicodeStringEncoding error:&error];
//    
//    if (nil != error)  {
//        NSLog(@"BCTabledHtmlFormatter appendHtmlToString Error Desc: %@",[error localizedDescription]);
//        NSLog(@"BCTabledHtmlFormatter appendHtmlToString Error Sugg: %@",[error  localizedRecoverySuggestion]);
//    }
    
		
}

-(void)appendHeadersToString:(NSMutableString *)buffer; {
	

	[buffer appendString: @"\t<TR frame=\"below\">\n"];

	for (NSTableColumn *aTableColumn in [tableView tableColumns]) {

		[buffer appendString: @"\t\t<TH>"];
		
		[buffer appendString:[[aTableColumn headerCell] stringValue]];
	
		[buffer appendString: @"</TH>\n"];
		
	}
	
	[buffer appendString: @"\t</TR>\n"];

}

-(void)appendRowAtIndex:(NSInteger)rowIndex toString:(NSMutableString *)buffer; {
	

	[buffer appendString: @"\t<TR>\n"];
	
	
	for (NSTableColumn *aTableColumn in [tableView tableColumns]) {
			
		[buffer appendString: @"\t\t<TD>"];
		
		NSString *objectValue = [[tableView dataSource] tableView:tableView objectValueForTableColumn:aTableColumn row:rowIndex];
		
		if (objectValue) { [buffer appendString:objectValue]; }
		
		else {
			
			// if blank column, leave table cell blank
			if ([[[aTableColumn headerCell] stringValue] isEqualToString:[NSString string]]){
				[buffer appendString:kBlankCellText];		
			}
			else { [buffer appendString:kNoDataCellText]; }
		
		
		}
		
		[buffer appendString: @"</TD>\n"];
		
	}

	[buffer appendString: @"\t</TR>\n"];
	
	
}
	

//- (NSString *)stringForObjectValue:(id)anObject; {
//	
//	// Textual representation of cell content
//	// taken from "MyValueFormatter.m" of "QTMetadataEditor" sample code
//		
//	NSString *resultString;
//		
//	if ([anObject isMemberOfClass:[NSData class]]) {
//		// resultString = [MyValueFormatter hexStringFromData:(NSData *)anObject];
//	}
//	else if ([anObject isMemberOfClass:[NSString class]]) {
//		resultString = anObject;
//	}
//	else if ([anObject isMemberOfClass:[NSNumber class]]) {
//		resultString = [anObject stringValue];
//	}
//	return resultString;
//}
	


@end
