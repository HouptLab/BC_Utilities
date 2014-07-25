//
//  BCTableViewExtensions.h
//  Xynk
//
//  Created by Tom Houpt on 14/7/25.
//
//

#import <Cocoa/Cocoa.h>

#define kBlankTabCellText @" "
#define kNoDataTabCellText @"--"

@interface NSTableView (ExportExtensions)

/** format the NSTableView into a tab-delimited NSString
 
 @return an NSString with table cells in tab-delimited format
 
 */
-(NSString *)tableAsTabDelimitedString;

-(NSString *)rowsAsTabDelimitedString:(NSIndexSet *)indexOfRows;

-(NSString *)columnsAsTabDelimitedString:(NSIndexSet *)indexOfColumns;

@end
