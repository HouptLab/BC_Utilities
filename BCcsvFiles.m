//
//  BCcsvFiles.m
//  Xynk
//
//  Created by Tom Houpt on 12/2/13.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//
//	CSV Parsing code from:
//
//	http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data
//	Cocoa for Scientists (Part XXVI): Parsing CSV Data
//	By drewmccormack at Mon, Jun 2 2008 6:33am |Tutorials
//	Author: Drew McCormack
//	Web Site: www.mentalfaculty.com
//	released into the public domain
//
// NOTE: cocoadev thread on reading/writing CSV/TDL files:
// http://www.cocoadev.com/index.pl?ReadWriteCSVAndTSV
//
// Gopher standard for tab-separated values, 1993:
// http://www.iana.org/assignments/media-types/text/tab-separated-values
//
// CSV file format, as exported by Excel
// http://tools.ietf.org/html/rfc4180
//
// MS Office binary formats:
// http://www.microsoft.com/interop/docs/OfficeBinaryFormats.mspx
// "However: abandon hope, ye who enter. The formats are crufty, bloated, complicated, and simply horrible in every way."
//
// NOTE: european data files may be 'semi-colon'-separated values, because comma is used as a decimal point
// Does locale handle this automatically?

#import "BCcsvFiles.h"


@implementation NSString (ParsingExtensions)

-(NSArray *)csvRows {
    
    // using the parent string, returns an array of arrays
    // each object in "rows" is an NSArray *columns;
    // each NSArray *column is an array of NSString *cell;
    // each cell contains the text  of each cell in the file
    // rows are separated by newlineCharacterSet (newline and nextline characters (U+000A–U+000D, U+0085))
    // columns are separated by commas ","
    // allows for nested quotes using "\""
    
    NSMutableArray *rows = [NSMutableArray array];
	
    // Get newline character set
    // NOTE: make the character sets immutable to speed up performance?
    // NOTE: why did Mccormack make newLineCharacterSet by intersection? Can't we just usenewlineCharacterSet?
	
	NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
	
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
	
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {        
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
			
            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {  
                if ( insideQuotes ) {
                    [currentColumn appendString:@","];
                }
                else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
	
    return rows;
}

// (NSArray) componentsJoinedByString:.

//To separate a text file by lines, use NSString's
//getLineStart:end:contentsEnd:range instead. It's only a little more
//work, but it will properly handle various line endings for you (UNIX, Mac, DOS, etc.).


-(NSArray *)tabRows {
    
    // using the parent string, returns an array of arrays
    // each object in "rows" is an NSArray *columns;
    // each NSArray *column is an array of NSString *cell;
    // each cell contains the text  of each cell in the file
    // rows are separated by newlineCharacterSet (newline and nextline characters (U+000A–U+000D, U+0085))
    // columns are separated by tabs "\t"  (U+0009) 
    // allows for nested quotes using "\""
    

    NSMutableArray *rows = [NSMutableArray array];
	
    // Get newline character set
    // NOTE: make the character sets immutable to speed up performance?
    // NOTE: why did Mccormack make newLineCharacterSet by intersection? Can't we just usenewlineCharacterSet?

	
	NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
	
    // Characters that are important to the parser -- tab and double-quote
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@"\t\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
	
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
			
            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""];
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"\t" intoString:NULL] ) {
                if ( insideQuotes ) {
                    [currentColumn appendString:@"\t"];
                }
                else {
                    // This is a column separating tab
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
	
    return rows;
}


@end
