//
//  BCTableHtmlFormatter.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/15.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// table cells without stringValue are given text @"--"
// unless headerCell stringValue is @"" (blank column name), 
// in which case the cells are made blank (@"  ")

#define kBlankCellText @"&nbsp"
#define kNoDataCellText @"--"

@interface BCTableHtmlFormatter : NSObject {
		
	NSTableView *tableView;
	NSString *tableID;
	
	BOOL useAlternatingRowColors;
	BOOL useVerticalLines;
	BOOL useHorizontalLines;
	BOOL useCaption;
	BOOL useRowNumbers;

}

- (id) initWithTableView:(NSTableView *)table andTableID:(NSString *)tid;
- (void) setTableView:(NSTableView *)table;
- (NSString *) htmlString;
- (void) appendCssToString:(NSMutableString *)buffer;
- (void) appendHtmlToString:(NSMutableString *)buffer;
- (void) appendHeadersToString:(NSMutableString *)buffer;
- (void) appendRowAtIndex:(NSInteger)rowIndex toString:(NSMutableString *)buffer;

@end
