//
//  BCStringExtensions.h
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


#import <Cocoa/Cocoa.h>


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

@end
