//
//  BCDataRowsValidator.m
//  Xynk
//
//  Created by Tom Houpt on 21/9/23.
//

#import "BCDataRowsValidator.h"

@interface BCDataRowsValidator (Private)

-(DataValidationError)trimCells;
-(DataValidationError)trimRows; 
-(DataValidationError)numberOfColumns:(NSInteger *)num;
-(DataValidationError)trimColumns;
-(DataValidationError)checkRowNumber;
-(DataValidationError)checkColumnNumber; 
-(DataValidationError)checkHeaderRow;
-(void)setMissingValues; 

@end

@implementation BCDataRowsValidator

/* -------------------------------------------------------------- */

-(id)initWithRows:(NSMutableArray *)theRows; {


    self = [super init];
    if (self) {
        
        _rows = theRows;
        
        _errorStrings = @[
             @"Non-Equal Row Lengths",
             @"Not Enough Columns",
             @"Not Enough Rows",
             @"Some Rows Longer Than Header",
             @"Rows Shorter Than Header",
             @"Empty Header Cell",
             @"No Data on Pasteboard",
             @"Problem reading subject"
         ];
    }

    return self;
}

/* -------------------------------------------------------------- */
/**

given an DataValidationError, concatenate error strings corresponding to
the error bits which are set into a single error string message 


 */

-(NSString *)errorString:(DataValidationError)error; {
    NSMutableString *errorString = [NSMutableString string];

    BOOL firstString = YES;
    for (NSInteger bitIndex = 0; bitIndex < [_errorStrings count];bitIndex++) {
        if (error & 1 << bitIndex) {
            if (!firstString) {
                [errorString appendString:@"; "];
            }
            [errorString appendString:_errorStrings[bitIndex]];
            firstString = NO;
        }
    }

    return errorString;
}


/* -------------------------------------------------------------- */


/** trim Cells

_rows is an array of arrays of NSStrings

then delete any _rows that contain only empty cells

*/

-(DataValidationError)trimCells; {

    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    for (NSMutableArray *row in _rows) {
        for (NSInteger c =0; c < [row count];c++) {
            NSString *cell = [row objectAtIndex:c];
            [row replaceObjectAtIndex:c withObject:[cell stringByTrimmingCharactersInSet:whitespace]];
        }
    }
    
    return kDataValidationErrorNoError;

    

}
/* -------------------------------------------------------------- */

/** trim _rows

_rows is an array of arrays of NSStrings

delete any _rows that contain only empty cells, or which begin with an octothorpe in first cell

*/
-(DataValidationError)trimRows; {

    NSMutableArray *rowsToRemove = [NSMutableArray array];
    for (NSArray *row in [_rows reverseObjectEnumerator]) {

        NSInteger sum_cell_length = 0;
        for (NSString *cell in row) {
            sum_cell_length += [cell length];
        }
        if (0 == sum_cell_length || 0 == [row count]) {
            [rowsToRemove addObject: row];
        }
        else { // check for comment row
            
            NSString *firstCell = [row firstObject];
            
            if ([firstCell hasPrefix:@"#"]) {
                 [rowsToRemove addObject: row];
            }
            
        }
    }
    
    for (NSArray *row in rowsToRemove) {
        [_rows removeObject: row];
    }
        
    return kDataValidationErrorNoError;

}

/* -------------------------------------------------------------- */


/** number of Columns

find the maximum number of columns (ie. number of cells in a row)

@return TRUE if all _rows have the same number of cells; otherwise false if there are _rows with disparate number of _rows

*/

-(DataValidationError)numberOfColumns:(NSInteger *)num; {

   DataValidationError error =  kDataValidationErrorNoError;

    NSInteger headerColumns = [(NSMutableArray *)[_rows firstObject] count];
    NSInteger maxColumns = headerColumns;


    for (NSArray *row in _rows) {
    
        NSInteger rowColumns = [row count];
        if (rowColumns != maxColumns) {
            error |= kDataValidationErrorNonEqualRowLengths;
        }
        if (rowColumns > headerColumns) {
           error |=  kDataValidationErrorRowsLongerThanHeader;
        }
        if (rowColumns < headerColumns) {
           error |=  kDataValidationErrorRowsShorterThanHeader;
        }        
        if (rowColumns > maxColumns) { 
            maxColumns = rowColumns;
        }
    }
    (*num) = maxColumns;
    return error;
}

/* -------------------------------------------------------------- */


/** trim Columns

    if a column (ie. all cells at row[columnIndex]) are empty,
    then the cells at columnIndex are removed from all _rows
    Note that a column may have a non-empty header cell (in row[0]) with empty cells underneath the header string

*/


-(DataValidationError)trimColumns; {

    DataValidationError error = kDataValidationErrorNoError;
   
   NSInteger numColumns;
    error |= [self numberOfColumns:&numColumns];
   
   if (error) {
        return kDataValidationErrorNonEqualRowLengths;
   }
   
     
    for (NSInteger c = numColumns - 1; c >= 0; c--) {
    
        BOOL emptyColumn = YES;
        for (NSArray *row in _rows) {
            NSString *cellString = [row objectAtIndex:c];
            NSInteger cellLength = [cellString length];
            if (0 < cellLength) {
                emptyColumn = NO; 
            }
        }
        if (emptyColumn) {
            for (NSMutableArray *row in _rows) {
                [row removeObjectAtIndex: c];
            }
        }

    }
    
    return error;
}

/* -------------------------------------------------------------- */

/**
    make sure we have the minimum number of rows (at least header and 1 subject)
    minimum is defined by constant kDataRowsMinimum
    
    @return kDataValidationErrorNoError if sufficient rows otherwise error kDataValidationErrorInsufficientRows
 */
-(DataValidationError)checkRowNumber; {


    NSInteger numRows = [_rows count];

    if (kDataRowsMinimum > numRows) {
         return kDataValidationErrorInsufficientRows;
    }
    return kDataValidationErrorNoError;
    
}
/* -------------------------------------------------------------- */

/**
    make sure we have the minimum number of columns (at least subject, group,  and 1 measure)
    minimum is defined by constant kDataColumnsMinimum

    @return kDataValidationErrorNoError if sufficient columns otherwise error kDataValidationErrorInsufficientColumns
 */
-(DataValidationError)checkColumnNumber; {

    NSInteger numColumns = [[_rows firstObject] count];

    if (kDataColumnsMinimum > numColumns) {
         return kDataValidationErrorInsufficientColumns;
    }
    return kDataValidationErrorNoError;

}

/* -------------------------------------------------------------- */

/**
    make sure we have a a header row that contains all non-empty cells
    @return kDataValidationErrorNoError if valid header row, otherwise return error kDataValidationErrorEmptyHeaderCell

 */
-(DataValidationError)checkHeaderRow; {

    NSMutableArray *headerRow = [_rows firstObject];
    
    DataValidationError error = kDataValidationErrorNoError;
    
        for (NSInteger c =0; c < [headerRow count];c++) {
        
            NSString *cell = [headerRow objectAtIndex:c];
            if ([cell length] == 0) {
                error |= kDataValidationErrorEmptyHeaderCell;
            }
        }
 
    return error;
}

/* -------------------------------------------------------------- */

/** if there are any empty cells (ie cells with string length 0
 
    set the cell contents to @"--"
    
 */
 
-(void)setMissingValues; {

    for (NSMutableArray *row in _rows) {
    
        for (NSInteger c =0; c < [row count];c++) {
        
            NSString *cell = [row objectAtIndex:c];
            if ([cell length] == 0) {
                [row replaceObjectAtIndex:c withObject:@"--"];
            }
        }
    }
}

/* -------------------------------------------------------------- */

/** validate _rows

    trim and validate data _rows
    
    trimming:
    - will remove white space from start and end of each cell string
    - will remove empty rows (rows that contain only cells with 0-length string and comment rows that begin with "#" in first cell)
    - will remove columns that consist of only empty cells
    
    validating:
    - check row number (must be at least kDataRowsMinimum, with header and 1 subject)
    - check column number (must be at least kDataColumnsMinimum, with subject, group, and 1 measure)
    - make sure all cells in header row contain non-empty strings
    - set any remaining empty cells to @"--"
    
    @return a DataValidationError error code that can be used to signal user of problem

*/


-(DataValidationError)validateRows; {

    DataValidationError error = kDataValidationErrorNoError;

    error |= [self trimCells];
    
    error |=  [self trimRows];
    
    error |= [self trimColumns];
    
    if (error) {
        return error;
    }
    

    
    error |=  [self checkRowNumber];
    
    error |= [self checkColumnNumber];
    
    error |= [self checkHeaderRow];
    
    if (error) {
        return error;
    }
    
    [self setMissingValues];
    
    return error;
}


@end
