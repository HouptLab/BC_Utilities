//
//  BCTableHtmlFormatter.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/15.
//  Copyright 2012 Behavioral Cybernetics LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* USAGE:
 #import <WebKit/WebKit.h>

WebView *myWebView; // be sure to allocate
NSMutableString *htmlBuffer; // be sure to allocate
 
// initialze the formater with your NSTableView
BCTableHtmlFormatter *htmlFormatter = [[BCTableHtmlFormatter alloc] initWithTableView:mTableView andTableID:@"myTableID"];

[htmlFormatter appendHtmlToString:htmlBuffer];

 // render the table in the NSWebView
[[myWebView mainFrame] loadHTMLString:htmlString baseURL:nil];

*/

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

/**
 <#Description#>
 
 @param table an NSTableView to be converted to html
 @param tid   an html id label for use on web page
 
 @return an initialized HTMLTableFormatter; now when appendHtmlToString is called, the contents of the NSTableView will be converted to an html table, then appended to the string
 
 */
- (id) initWithTableView:(NSTableView *)table andTableID:(NSString *)tid;
- (void) setTableView:(NSTableView *)table;
- (NSString *) htmlString;
- (void) appendCssToString:(NSMutableString *)buffer;
- (void) appendHtmlToString:(NSMutableString *)buffer;
- (void) appendHeadersToString:(NSMutableString *)buffer;
- (void) appendRowAtIndex:(NSInteger)rowIndex toString:(NSMutableString *)buffer;

@end
