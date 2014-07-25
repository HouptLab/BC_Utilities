//
//  BCTableViewExtensions.h
//  Xynk
//
//  Created by Tom Houpt on 14/7/25.
//
//

#import <Cocoa/Cocoa.h>

/* reminder: if we want an attributed string/rtf from the tab-delimited, text we can use our method
 -(NSMutableAttributedString *)makeTableAttributedStringFromTabTextString; (from BCStringExtensions.h)
 
 */


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

