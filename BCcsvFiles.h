//
//  BCcsvFiles.h
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
 each column field is an NSString containing a comma-delimited text field
*/
	-(NSArray *)csvRows;

/** parse the given NSString as a tab-delimited file, into rows and columns
 
 @return an array of rows; each row is an array of column fields;
 each column field is an NSString containing a tab-delimited text field
 */

    -(NSArray *)tabRows;

@end
