//
//  BCTableViewExtensions.m
//  Xynk
//
//  Created by Tom Houpt on 14/7/25.
//
//

#import "BCTableViewExtensions.h"

@implementation NSTableView (ExportExtensions)



-(NSString *)tableAsTabDelimitedString; {
    
    NSIndexSet *allColumns = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfColumns])];

    return [self columnsAsTabDelimitedString:allColumns];
    
}

-(NSString *)rowsAsTabDelimitedString:(NSIndexSet *)indexOfRows; {
    
    NSMutableString *buffer = [NSMutableString string];
    
    

    // add headers to buffer based on tableColumn titles
    // add table cells to buffer, row by row
	NSInteger rowIndex;
	NSInteger numRows = [self numberOfRows];
	BOOL firstPass;
	for (rowIndex=0;rowIndex<numRows;rowIndex++) {
        
        if ([indexOfRows containsIndex:rowIndex]) {
            
            firstPass = YES;
            
            // add cells to row, column by column
            
            for (NSTableColumn *aTableColumn in [self tableColumns]) {
                
                if (!firstPass) {[buffer appendString: @"\t"]; }
                else { firstPass = NO; }
                
                NSString *objectValue = [[self dataSource] tableView:self objectValueForTableColumn:aTableColumn row:rowIndex];
                
                if (objectValue) { [buffer appendString:objectValue]; }
                
                else {
                    
                    // if blank column, leave table cell blank
                    if ([[[aTableColumn headerCell] stringValue] isEqualToString:[NSString string]]){
                        [buffer appendString:kBlankTabCellText];
                    }
                    else { [buffer appendString:kNoDataTabCellText]; }
                    
                    
                }
                
            } // next column
            
            [buffer appendString: @"\r"];
            
        } // row is in index
		
	} // next row
    
    return buffer;
}

-(NSString *)columnsAsTabDelimitedString:(NSIndexSet *)indexOfColumns; {
    
    NSMutableString *buffer = [NSMutableString string];
    
    // add headers to buffer based on tableColumn titles
    BOOL firstPass = YES;
	for (NSTableColumn *aTableColumn in [self tableColumns]) {
        
        if ([indexOfColumns containsIndex:[[self tableColumns] indexOfObject:aTableColumn ]]) {

            if (!firstPass) {[buffer appendString: @"\t"]; }
            else { firstPass = NO; }
            
            [buffer appendString:[[aTableColumn headerCell] stringValue]];
                
        }
        
	}
	
	[buffer appendString: @"\r"];
    
    // add headers to buffer based on tableColumn titles
    // add table cells to buffer, row by row
	NSInteger rowIndex;
	NSInteger numRows = [self numberOfRows];

	for (rowIndex=0;rowIndex<numRows;rowIndex++) {
        
        
            firstPass = YES;
            
            // add cells to row, column by column
            
            for (NSTableColumn *aTableColumn in [self tableColumns]) {
                
                if ([indexOfColumns containsIndex:[[self tableColumns] indexOfObject:aTableColumn ]]) {

                    if (!firstPass) {[buffer appendString: @"\t"]; }
                    else { firstPass = NO; }
                    
                    NSString *objectValue = [[self dataSource] tableView:self objectValueForTableColumn:aTableColumn row:rowIndex];
                    
                    if (objectValue) { [buffer appendString:objectValue]; }
                    
                    else {
                        
                        // if blank column, leave table cell blank
                        if ([[[aTableColumn headerCell] stringValue] isEqualToString:[NSString string]]){
                            [buffer appendString:kBlankTabCellText];
                        }
                        else { [buffer appendString:kNoDataTabCellText]; }
                        
                        
                    }
                    
                } // column is in index
                
            } // next column
            
            [buffer appendString: @"\r"];
        
	} // next row
    
    return buffer;
}

@end
