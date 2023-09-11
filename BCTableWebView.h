//
//  BCTableWebView.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/15.
//  Copyright 2012 Behavioral Cybernetics LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@class DailyData;

@interface BCTableWebView : WebView {
	
	DailyData *dailyData;
	
	NSTableView *tableView;
	
	NSMutableString *htmlString;
	
	BOOL useAlternatingRowColors;
	BOOL useVerticalLines;
	BOOL useHorizontalLines;
	BOOL useCaption;
	BOOL useRowNumbers;

}

- (id) initWithTableView:(NSTableView *)table;

-(void)  appendDailyDataInfoToString:(NSMutableString *)buffer;
- (void) appendHtmlFromTableToString:(NSMutableString *)buffer;
- (void) appendHeadersToString:(NSMutableString *)buffer;
- (void) appendRowAtIndex:(NSInteger)rowIndex toString:(NSMutableString *)buffer;
- (NSString *) stringForObjectValue:(id)anObject;

// -(void)print:(id)sender; 
//- (void)drawRect:(NSRect)dirtyRect;

@end
