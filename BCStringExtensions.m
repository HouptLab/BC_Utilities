//
//  BCcsvFiles.m
//  Xynk
//
//  Created by Tom Houpt on 12/2/13.
//  Copyright 2012 Behavioral Cybernetics LLC. All rights reserved.
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
// http://www.cocoadev.com/ReadWriteCSVAndTSV
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

#import "BCStringExtensions.h"


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
    // NOTE: shouldn't importantCharacterSet include CR and LF as per RFC4180
	
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
               if ( ![currentColumn isEqualToString:@""] ) {
                        [columns addObject:currentColumn];
                }
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
                    [currentColumn appendString:@"\""];
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
                    // get rid of any whitespace after
//                    NSString *whiteString;
//                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&whiteString]; // should be NULL
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
	
    return rows;
}

-(NSMutableDictionary *)lengthUnitsDictionary; {
    static NSMutableDictionary *unitsDictionary;
    if (!unitsDictionary) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *plistPath = [bundle pathForResource:@"LengthUnits" ofType:@"plist"];
        unitsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return unitsDictionary;
}

/** parse the string into Quartz2D points
 
 interprets the string as a length in Quartz2D points, assuming 1 pt = 1/72 of an inch
 parses names or abbreviations of units at the end of the string,
 and converts to points
 e.g. @"2 in" -> CGFloat 144
 
 @return a CGFloat number of points; unitsFlag set to YES if parsable units suffix found
 */
-(CGFloat)pointValueUsingUnits:(BOOL *)unitsFlag; {
    
    // split the string into a numeric and alpha components
    NSString *unitsString;
    CGFloat value;
        
    NSRange rangeOfLetters = [self rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if (rangeOfLetters.location == NSNotFound) {
        (*unitsFlag) = NO;
        
#define kDefaultUnitOfLengthKey @"unitOfLength"
        unitsString = [[ NSUserDefaults standardUserDefaults] stringForKey:kDefaultUnitOfLengthKey];
        assert(nil != unitsString);
        value = [self doubleValue];
        // NOTE: this should be in user-defined prefered units, e.g. cm or in, not necessarily points...
    }
    else {
    
        NSString *numberString  = [self substringToIndex:rangeOfLetters.location];
        value         = [numberString doubleValue];

        unitsString   = [self substringFromIndex:rangeOfLetters.location];
    }
    
    CGFloat conversionFactor = [unitsString pointConversionFactorValueUsingUnits:unitsFlag];

    return conversionFactor * value;
    
}
/** return an NSString with length and units text
 
 allocates and formats a string using the value as a length in Quartz2D points, assuming 1 pt = 1/72 of an inch
 converts to given units, and puts names of units at the end of the string,
 and converts to points
 e.g. CGFloat 144, @"inch" -> @"2 inch"
 
 @return a CGFloat number of points
 */
-(NSString *)lengthStringFromValue:(double)value usingUnit:(NSString *)unitString; {
    
    double convertedValue;
    
    NSMutableDictionary *units = [self lengthUnitsDictionary];
    
    NSNumber *conversionFactor = [units objectForKey:unitString];
    
    if (nil != conversionFactor) {
        
        convertedValue = value / [conversionFactor doubleValue];
    }
    else {
        
        convertedValue = value;
    }
    
    
    NSString *lengthString = [NSString stringWithFormat:@"%.3g %@",convertedValue, unitString];
    
    return lengthString;
}



-(CGFloat)pointConversionFactorValueUsingUnits:(BOOL *)unitsFlag; {
    
    // strip out the white space and convert to lowercase before looking up in dictionary
    NSArray* words = [self componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pluralString = [[words componentsJoinedByString:@""] lowercaseString];

    NSString* unitsString;
    
    // remove any "es" or "s" suffix
    if ([pluralString hasSuffix:@"es"]) {
        // take off last two characters
        unitsString = [pluralString substringToIndex:[pluralString length]-2];
    }
    else if ([pluralString hasSuffix:@"s"]) {
        // take off last character
        unitsString = [pluralString substringToIndex:[pluralString length]-1];
    }
    else {
        
        unitsString = pluralString;
    }
    
    NSMutableDictionary *units = [self lengthUnitsDictionary];
    
    NSNumber *conversionFactor = [units objectForKey:unitsString];
        
    if (nil != conversionFactor) {
        (*unitsFlag) = YES;
        return [conversionFactor doubleValue];
    }
    
    (*unitsFlag) = NO;
    return 1.0;
}


/** Given a string, extract an array of paragraphs using NSString's getParagraphStart method
 
 @param source A source string to parse for paragraphs
 @return A mutable array of strings, each one a paragraph extracted from the source string
 
 */
-(NSMutableArray *)extractParagraphs; {
	
	NSUInteger length = [self length];
	NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
	NSRange currentRange;
	
	NSMutableArray *lineArray = [NSMutableArray array];
	
	
	while (paraEnd < length) {
		
		[self getParagraphStart:&paraStart end:&paraEnd
					  contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
		
		currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
		
		[lineArray addObject:[self substringWithRange:currentRange]];
		
	}
	
	return lineArray;
	
}


- (BOOL)isEmpty; {
    if([self length] == 0) { //string is empty or nil
        return YES;
    }
    
    if([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        //string is all whitespace
        return YES;
    }
    
    return NO;
}




-(NSMutableAttributedString *)makeTableAttributedStringFromTabTextString;
// given an NSString in tabbed text table format, convert to an NSMutableAttributedString containing an NSTextTable
// if the text of a cell is bracketed by asterices, e.g. "*significant text*\t", then highlight that cell (backgrondColor = [NSColor yellowColor]

{
    // tableString is an ivar declared in the header file as NSMutableAttributedString *tableString;
    NSMutableAttributedString *tableString = [[NSMutableAttributedString alloc] initWithString:@"\n\n"];
    
    NSTextTable *table = [[NSTextTable alloc] init];
	[table setCollapsesBorders:YES];

    // convert tabbed text into an array of array of cells
    // each  tabRow is an array of cells from the columns of that row
    NSArray *tabRows = [self tabRows]; // NSString extension defined in BCcvsFiles.h
    
    
    unsigned long numColumns = 0;
    for (NSArray *columns in tabRows) {
        
        if ([columns count] > numColumns) {
            numColumns = [columns count];
        }
    }
    
    [table setNumberOfColumns:numColumns];
    
    //   NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\*(.+?)\\*'"];
    NSString *regexString = @"\\*(.+?)\\*.*";
    
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    
    NSColor *backgroundColor;
    
    unsigned long rowIndex = 0, columnIndex = 0;
    
    for (NSArray *columns in tabRows) {
        columnIndex = 0;
        for (NSString *cell in columns) {
            
            NSString *cellContentString;
            // if cell string is bracketed by asterices, e.g., "*text*", then highlight the cell
            
            if ([regex evaluateWithObject:cell]) {
                
                backgroundColor = [NSColor yellowColor];
                cellContentString = [[cell stringByReplacingOccurrencesOfString:@"*" withString:[NSString string]]stringByAppendingString:@"\n"];
            }
            else {
               // backgroundColor = [NSColor clearColor];
                backgroundColor = nil;
                cellContentString = [cell stringByAppendingString:@"\n"];
            }
            
            
            NSMutableAttributedString * tableCellString = [cellContentString makeTableCellAttributedStringForTable:table
                                                                                                        background:backgroundColor
                                                                                                            border:[NSColor blackColor]
                                                                                                               row:rowIndex
                                                                                                            column:columnIndex];
            
            
            [tableString appendAttributedString:tableCellString];
            
            columnIndex++;
        }
        rowIndex++;
    }
    
    return tableString;
}

-(NSMutableAttributedString *)makeTableCellAttributedStringForTable:(NSTextTable *)table
                                                         background:(NSColor *)backgroundColor
                                                             border:(NSColor *)borderColor
                                                                row:(unsigned long)row
                                                             column:(unsigned long)column;
{
    NSTextTableBlock *block = [[NSTextTableBlock alloc]
                               initWithTable:table
                               startingRow:row
                               rowSpan:1
                               startingColumn:column
                               columnSpan:1];
    
    [block setBackgroundColor:backgroundColor];
    [block setBorderColor:borderColor];
    [block setWidth:1.0 type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder];
    [block setWidth:6.0 type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockPadding];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setTextBlocks:[NSArray arrayWithObjects:block, nil]];
    
    NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] initWithString:self];
    
    [cellString addAttribute:NSParagraphStyleAttributeName
                       value:paragraphStyle
                       range:NSMakeRange(0, [cellString length])];
    
    return cellString;
}


- (NSString *)stringWithSubstitute:(NSString *)subs forCharactersFromSet:(NSCharacterSet *)set; {
    
    
    NSRange rangeOfSubString;
    NSString *replacedString  = [self copy];
    
    do {
        
        rangeOfSubString = [replacedString rangeOfCharacterFromSet:set];
        
        if (rangeOfSubString.location != NSNotFound) {
        
            replacedString = [replacedString stringByReplacingCharactersInRange:rangeOfSubString withString:subs];
        }
        
    } while  (rangeOfSubString.location != NSNotFound);
    
    return replacedString;
    
}

-(NSString *)stringWithDashesForWhiteSpace; {
    return [self stringWithSubstitute:@"-" forCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 reverse the order of characters in the string
 
 @return a string containing the reversed characters of this string
 */
-(NSString *)reverseString; {
    
    NSMutableString *reversed = [NSMutableString string];
    NSInteger charIndex = [self length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subRange = NSMakeRange(charIndex, 1);
        [reversed appendString:[self substringWithRange:subRange]];
    }
    return reversed;
    
}


#define kCSVEscapedCharacters @",\"\r\n"

-(NSString *)stringAsCSVField; {
    
    NSCharacterSet *csvCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                          kCSVEscapedCharacters];

    if ([self rangeOfCharacterFromSet:csvCharacters].location != NSNotFound) {
        
        // need to bracket in quotes, and  escape " character as ""
        NSMutableString *csvField = [NSMutableString stringWithString:@"\""];
        [csvField appendString:[self stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""]];
        [csvField appendString:@"\""];
        
        return csvField;
    }
    
    // if no escaping characters, then return an unmodified copy of self
    return [self copy];
    
}

-(uint32_t)crc32; {
    
    // NOTE: should we get bytes from NSString, or characters, or C string?
    // for Papers citeKey, the citeKey method has already converted to canonical string
    // javascript strings are probably arrays of unicode characters...
    // try getting as ascii strings...
    // what should encoding be?
    // NSUnicodeStringEncoding
    // NSUTF8StringEncoding
    // NSASCIIStringEncoding

    NSRange stringRange = NSMakeRange(0, [self length]);
    size_t  bufferCount = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    // make buffer 1 byte longer so we can null terminate
    // useful for examining string in buffer...
    char *buffer = calloc(bufferCount+1,1);

        [self getBytes:buffer
             maxLength:bufferCount
            usedLength:NULL
              encoding:NSUTF8StringEncoding
               options:NSStringEncodingConversionAllowLossy
                 range:stringRange
        remainingRange:NULL];
    
    buffer[bufferCount] = 0;
    printf("%s\n",buffer);

    uint32_t myCrc32 = crc32(0,buffer,bufferCount);
    
    free(buffer);
    
    return myCrc32;
    
}

@end

    // from: http://www.opensource.apple.com/source/xnu/xnu-1456.1.26/bsd/libkern/crc32.c
    
    /*-
     *  COPYRIGHT (C) 1986 Gary S. Brown.  You may use this program, or
     *  code or tables extracted from it, as desired without restriction.
     *
     *  First, the polynomial itself and its table of feedback terms.  The
     *  polynomial is
     *  X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0
     *
     *  Note that we take it "backwards" and put the highest-order term in
     *  the lowest-order bit.  The X^32 term is "implied"; the LSB is the
     *  X^31 term, etc.  The X^0 term (usually shown as "+1") results in
     *  the MSB being 1
     *
     *  Note that the usual hardware shift register implementation, which
     *  is what we're using (we're merely optimizing it by doing eight-bit
     *  chunks at a time) shifts bits into the lowest-order term.  In our
     *  implementation, that means shifting towards the right.  Why do we
     *  do it this way?  Because the calculated CRC must be transmitted in
     *  order from highest-order term to lowest-order term.  UARTs transmit
     *  characters in order from LSB to MSB.  By storing the CRC this way
     *  we hand it to the UART in the order low-byte to high-byte; the UART
     *  sends each low-bit to hight-bit; and the result is transmission bit
     *  by bit from highest- to lowest-order term without requiring any bit
     *  shuffling on our part.  Reception works similarly
     *
     *  The feedback terms table consists of 256, 32-bit entries.  Notes
     *
     *      The table can be generated at runtime if desired; code to do so
     *      is shown later.  It might not be obvious, but the feedback
     *      terms simply represent the results of eight shift/xor opera
     *      tions for all combinations of data and CRC register values
     *
     *      The values must be right-shifted by eight bits by the "updcrc
     *      logic; the shift must be unsigned (bring in zeroes).  On some
     *      hardware you could probably optimize the shift in assembler by
     *      using byte-swap instructions
     *      polynomial $edb88320
     *
     *
     * CRC32 code derived from work by Gary S. Brown.
     */
    
    //#include <sys/param.h>
    //#include <sys/systm.h>
    
    static uint32_t crc32_tab[] = {
        0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f,
        0xe963a535, 0x9e6495a3,	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
        0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91, 0x1db71064, 0x6ab020f2,
        0xf3b97148, 0x84be41de,	0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
        0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,	0x14015c4f, 0x63066cd9,
        0xfa0f3d63, 0x8d080df5,	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
        0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,	0x35b5a8fa, 0x42b2986c,
        0xdbbbc9d6, 0xacbcf940,	0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
        0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423,
        0xcfba9599, 0xb8bda50f, 0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
        0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,	0x76dc4190, 0x01db7106,
        0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
        0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d,
        0x91646c97, 0xe6635c01, 0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
        0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 0x65b0d9c6, 0x12b7e950,
        0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
        0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7,
        0xa4d1c46d, 0xd3d6f4fb, 0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
        0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 0x5005713c, 0x270241aa,
        0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
        0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81,
        0xb7bd5c3b, 0xc0ba6cad, 0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
        0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683, 0xe3630b12, 0x94643b84,
        0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
        0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb,
        0x196c3671, 0x6e6b06e7, 0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
        0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5, 0xd6d6a3e8, 0xa1d1937e,
        0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
        0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55,
        0x316e8eef, 0x4669be79, 0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
        0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f, 0xc5ba3bbe, 0xb2bd0b28,
        0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
        0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f,
        0x72076785, 0x05005713, 0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
        0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 0x86d3d2d4, 0xf1d4e242,
        0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
        0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69,
        0x616bffd3, 0x166ccf45, 0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
        0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db, 0xaed16a4a, 0xd9d65adc,
        0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
        0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693,
        0x54de5729, 0x23d967bf, 0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
        0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
    };
    
uint32_t crc32(uint32_t crc, const void *buf, size_t size) {
    
    //    char *fox = "The quick brown fox jumps over the lazy dog";
    //    UInt32 foxCRC = crc32(0, fox, strlen(fox));
    //    should be 414fa339, 1095738169 decimal
    
        const uint8_t *p;
        
        p = buf;
        crc = crc ^ ~0U;
        
        while (size--)
            crc = crc32_tab[(crc ^ *p++) & 0xFF] ^ (crc >> 8);
        
        return crc ^ ~0U;
    

    
}


NSDictionary *MakePapersCiteKey(NSString *firstAuthor, NSInteger year, NSString *title, NSString *doi) {
    
    // based on: http://support.mekentosj.com/kb/read-write-cite/universal-citekey
    // adapted from javascript code at: https://github.com/cparnot/universal-citekey-js
    
    // citekey base
//    var author_name = author_input.value;
//    if (author_name.match(/^\s*$/))
//        author_name = 'Anonymous';
//    author_name = author_name.replace(/\s+/,'-');
//    var citekey_base = author_name + ':' + year_input.value;
    
    
    NSString *fox = @"The quick brown fox jumps over the lazy dog";
    UInt32 foxCRC = [fox crc32];
    
    printf("%lX\n",(unsigned long)foxCRC);
    printf("%lu\n",(unsigned long)foxCRC);


    // if no author name provided, use "Anonymous"
    // otherwise, use canonical form of author name, and replace white space with dashes
    
    NSString *author_name;
    if (nil == firstAuthor || 0 == [firstAuthor length]) {
        author_name = @"Anonymous";
    }
    else {
        author_name = [[firstAuthor decomposedStringWithCanonicalMapping] stringWithDashesForWhiteSpace];
    }
    NSString *citeKeyBase = [NSString stringWithFormat:@"%@:%ld",author_name,(long)year];
    
    // doi hash
//    var doi = doi_input.value;
//    var crc_doi = 0;
//    if (doi)
//        crc_doi = crc32.genBytes(doi);
//    var doi_hash1 = 'b'.charCodeAt(0) + Math.floor((crc_doi % (10*26)) / 26)
//    var doi_hash2 = 'a'.charCodeAt(0) + (crc_doi % 26)
//    var uc_doi = citekey_base + String.fromCharCode(doi_hash1) + String.fromCharCode(doi_hash2);
    
    NSString * ucDoi;
    if (nil == doi || 0 == [doi length]) {
        // nil string if no doi provided
        ucDoi = nil;
    }
    else {
        // need to confirm that crc32 uses same table as Papers citekey
        UInt32 crcDoi = [doi crc32];
        char doiHash1 = 'b' + (char)floor((crcDoi % (10 * 26))/26);
        char doiHash2 = 'a' + (char)(crcDoi % 26);
        ucDoi = [NSString stringWithFormat:@"%@%c%c",citeKeyBase,doiHash1,doiHash2];
    }
    
    // title hash
//    var title = canonical_string(title_input.value, true);
//    var crc_title = 0;
//    if (title)
//        crc_title = crc32.genBytes(title);
//    var title_hash1 = 't'.charCodeAt(0) + Math.floor((crc_title % (4*26)) / 26)
//    var title_hash2 = 'a'.charCodeAt(0) + (crc_title % 26)
//    var uc_title = citekey_base + String.fromCharCode(title_hash1) + String.fromCharCode(title_hash2);
    
    
    NSString * ucTitle;
    if (nil == title || 0 == [title length]) {
        // nil string if no doi provided
        ucTitle = nil;
    }
    else {
        // convert strings to "canonical form"
        // see http://unicode.org/reports/tr15/
        // see http://www.objc.io/issue-9/unicode.html
        // I think Papers citekey uses equivalent of [NSString decomposed​String​With​Canonical​Mapping]
        // and not precomposedStringWithCanonicalMapping
        
    // NOTE: while the DOI is returned correctly, the title key is not correct
        // I suspect there is some difference in how javascript represents/converts
        // the canonical string (or how NSString returns bytes with encoding in [NSString crc32]
        //        [self getBytes:buffer
        //             maxLength:bufferCount
        //            usedLength:NULL
        //              encoding:NSUTF8StringEncoding
        //               options:NSStringEncodingConversionAllowLossy
        //                 range:stringRange
        //        remainingRange:NULL];
        //
        // but I don't know how to look at javascript intermediates...
        // for title, don't replace with stringWithDashesForWhiteSpace
        
        // Note: need to replace multiple whitespace with single whitespace
        NSString *canonicalTitle = [[title  lowercaseString] decomposedStringWithCanonicalMapping];
        UInt32 crcTitle = [canonicalTitle crc32];
        char titleHash1 = 't' + (char)floor((crcTitle % (4 * 26))/26);
        char titleHash2 = 'a' + (char)(crcTitle % 26);
        ucTitle = [NSString stringWithFormat:@"%@%c%c",citeKeyBase,titleHash1,titleHash2];
    }

    //  return both doi and title citeKey
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *ucRefs = [NSMutableArray array];
    
    if (nil != ucDoi) {
        [keys addObject:kDOICiteKey];
        [ucRefs addObject:ucDoi];
    }
    if (nil != ucTitle) {
        [keys addObject:kTitleCiteKey];
        [ucRefs addObject:ucTitle];
    }

    NSDictionary *citeKeys = [NSDictionary dictionaryWithObjects:ucRefs
                                                         forKeys:keys];

    return citeKeys;

}


