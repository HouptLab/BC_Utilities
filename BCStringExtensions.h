//
//  BCStringExtensions.h
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


#import <Cocoa/Cocoa.h>

#define kTSVSeparator @"\t"
#define kOSXEndOfLine @"\n"
#define kCSVSeparator @","
#define kCSVEndOfLine @"\r\n"


@interface  NSString (ParsingExtensions)

/** parse the given NSString as a CSV file, into rows and columns
 
 @return an array of rows; each row is an array of column fields;
 each column field is an NSString derived from a comma-delimited text field
*/
	-(NSArray *)csvRows;

/** parse the given NSString as a tab-delimited file, into rows and columns
 
 @return an array of rows; each row is an array of column fields;
 each column field is an NSString derived from a tab-delimited text field


 */

    -(NSArray *)tabRows;



/** parse the string into Quartz2D points
 
 interprets the string as a length in Quartz2D points, assuming 1 pt = 1/72 of an inch
 parses names or abbreviations of units at the end of the string,
 and converts to points
 e.g. @"2 in" -> CGFloat 144
 
 @return a CGFloat number of points; unitsFlag set to YES if parsable units suffix found

 */
-(CGFloat)pointValueUsingUnits:(BOOL *)unitsFlag;

/** return an NSString with length and units text
 
 allocates and formats a string using the value as a length in Quartz2D points, assuming 1 pt = 1/72 of an inch
 converts to given units, and puts names of units at the end of the string,
 and converts to points
 e.g. CGFloat 144, @"inch" -> @"2 inch"
 
 @return a CGFloat number of points
 */
-(NSString *)lengthStringFromValue:(double)value usingUnit:(NSString *)unitString;

-(NSMutableDictionary *)lengthUnitsDictionary;
-(CGFloat)pointConversionFactorValueUsingUnits:(BOOL *)unitsFlag; 


/** return an array of paragraphs using NSString's getParagraphStart method
 
 @param source A source string to parse for paragraphs
 @return A mutable array of strings, each one a paragraph extracted from the source string
 
 */
-(NSMutableArray *)extractParagraphs;

/** check if string is empty or all white space
 
 @return YES if length is 0 or all white space; otherwise NO
 */
- (BOOL)isEmpty;


/** convert string to a TableAttributedString
 
 convert us (a tab-delimited NSString) into a TableAttributedSting
 if the text of a cell is bracketed by asterices, e.g. "*significant text*\t", 
 then highlight that cell (backgrondColor = [NSColor yellowColor]
 based on Apple example code
 
*/

-(NSMutableAttributedString *)makeTableAttributedStringFromTabTextString;


/** convert string to a TableCellAttributedString
 
 given a string (us), convert to a table cell within the given table
 we specify the color of the cell, and the position of the new cell within the table
 called by makeTableAttributedStringFromTabTextString
 
 
 based on Apple example code
 
 */
-(NSMutableAttributedString *)makeTableCellAttributedStringForTable:(NSTextTable *)table
                                                         background:(NSColor *)backgroundColor
                                                             border:(NSColor *)borderColor
                                                                row:(unsigned long)row
                                                             column:(unsigned long)column;


/**
 replace occurance of given characters with string "subs"
 
 @param subs e.g. "_" (underscore)
 @param set  e.g. [NSCharacterSet whitespaceAndNewlineCharacterSet]
 
 @return <#return value description#>
 */
- (NSString *)stringWithSubstitute:(NSString *)subs forCharactersFromSet:(NSCharacterSet *)set; 

/**
 reverse the order of characters in the string
 
 @return a string containing the reversed characters of this string
 */
-(NSString *)reverseString;

/**
return a copy of the string ; added because NSString does not natively have the selector stringValue
 
 @return a copy of the string in a new NSString
 */
-(NSString *)stringValue;




/** return a new string with self encoded as a CSV field (i.e. if contains comma, CR, LF, or double-quote, then enclose in double quotes and escape double-quote with a preceding double-quote
    see CSV file format, as exported by Excel at http://tools.ietf.org/html/rfc4180
 
 @return a string containing this string encoded as a CSV field
 
 */

-(NSString *)stringAsCSVField;

/**  whitespace characters are replaced with dashes, and capitalization is preserved
 
    calls [self stringWithSubstitute:@"-" forCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

*/

-(NSString *)stringWithDashesForWhiteSpace;


/** return an unsigned 32-bit integer containing the CRC32 checksum for self (turned into an array of bytes using NSUnicodeStringEncoding
 
    calls uint32_t crc32(uint32_t crc, const void *buf, size_t size) ;
 
*/

-(uint32_t)crc32;

/** find occurences of findString in entire string
 */
-(NSArray *)rangesOfString:(NSString *)findString;

/** find occurences of findString within the given range
 */
-(NSArray *)rangesOfString:(NSString *)findString inRange:(NSRange)range;

/** find occurences of strings in the string which match  matchRegexString
 */
-(NSArray *)rangesOfRegex:(NSString *)matchRegexString;

/** find occurences of strings in the string which match  matchRegexString within the given range
 */

-(NSArray *)rangesOfRegex:(NSString *)matchRegexString inRange:(NSRange)range;



@end

/**
 http://tools.ietf.org/html/rfc1952#section-8
 http://www.w3.org/TR/2003/REC-PNG-20031110/#D-CRCAppendix
 http://rosettacode.org/wiki/CRC-32#Implementation
 
 from http://stackoverflow.com/questions/2647935
 
  code by Gary S. Brown, taken from: http://www.opensource.apple.com/source/xnu/xnu-1456.1.26/bsd/libkern/crc32.c
 
*/
uint32_t crc32(uint32_t crc, const void *buf, size_t size) ;



/** given an author, year of publication, and title or DOI, generate two Papers style cite keys: one based on title, other based on paper's DOI.
 
 e.g. @"Smith", 1967, @"Trace conditioning with X-rays as an aversive stimulus"  returns @"Smith:1967tu"
 
 (note that delimitors "{...}" are not included in returned string...)
 
 based on:
 http://support.mekentosj.com/kb/read-write-cite/universal-citekey
 https://github.com/cparnot/universal-citekey-js
 
 @param firstAuthor the first author of the paper; if firstAuthor is nil or empty, then @"Anonymous" is used
 @param year year of publication
 @param title the paper's title; will be transformed into its equivalent canonical string, all lowercase
 @param doi the paper's DOI
 
 
 @return citekeys in a NSDictionary: get title based citeKey using kTitleCiteKey (@"titleCiteKey") and doi based citekey using kDOICiteKey (@"doiCiteKey")
 
 
 
 */
NSDictionary *MakePapersCiteKey(NSString *firstAuthor, NSInteger year, NSString *title, NSString *doi);

#define kTitleCiteKey @"titleCiteKey"
#define kDOICiteKey @"doiCiteKey"



