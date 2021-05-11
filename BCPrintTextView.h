//
//  BCPrintTextView.h
//  Xynk
//
//  Created by Tom Houpt on 14/7/24.
//
//

#import <Cocoa/Cocoa.h>

#define kDefaultTextPadding 9 // 0.125 inch padding
NSSize documentSizeForPrintInfo(NSPrintInfo *printInfo);

// http://www.cocoabuilder.com/archive/cocoa/147444-nstextview-printing-page-numbers-and-headers.html

//This code was adapted from a class given to me by Bill Cheeseman. It
//is a text view that will tack on page numbers, document title, and
//author name when it is printed. The interesting stuff is in
//drawPageBorderWithSize: which Bill figured out does not work as
//documented (at the time, I think the docs are better now).
//
//Todd Ransom
//Return Self Software
//http://returnself.com
//
//
//originally named: AVNRprintTextView : NSTextView


/** USAGE:

-(void)printDocument:(id)sender; {
    
    NSLog(@"AnovaResultsView: print");
    
    // NSString *currentTitle = [NSString stringWithFormat:@"%@ ANOVA results.rtf", dependent_measure_name];
    
    [self setTitle:@"ANOVA results"];
    [self setAuthor:@"Mr. Xynk"];

    self.printAuthor = YES;
    self.printTitle = YES;
    self.printPageNums = YES;
    
    // will print @"Mr. Xynk, ANOVA results, p. #" in top right corner
    // in Helvetica 9 pt
    // if flags are NO, it will leave out field and trailing ","
 
 // NOTE: need a way to set page size properly before printing

    NSPrintInfo *thePrintInfo = [NSPrintInfo sharedPrintInfo];
       [[NSPrintOperation printOperationWithView:self printInfo:thePrintInfo] runOperation];
    
}
*/


@interface BCPrintTextView : NSTextView {
    
    // for adding header with author, title, pagenum
    NSMutableDictionary *borderTextAttributes;
    NSMutableAttributedString *printString;
    NSInteger pageNumber;
    
    
    NSSize originalSize;            // The original size of the text view in the window (used for non-rewrapped printing)
    NSSize previousValueOfDocumentSizeInPage;   // As user fiddles with the print panel settings, stores the last document size for which the text was relaid out
    BOOL previousValueOfWrappingToFit;      // Stores the last setting of whether to rewrap to fit page or not
    
}

@property  NSPrintInfo *thePrintInfo;
@property (copy) NSString *title;
@property (copy) NSString *author;
@property (copy) NSMutableDictionary *borderTextAttributes;

// flags for showing author, title, pagenumber in header
@property  BOOL printAuthor;
@property  BOOL printTitle;
@property  BOOL printPageNums;

// flag for wrappng textview to fit width of printer page
@property  BOOL wrappingToFit;


@property NSSize originalSize;

- (id)initWithFrame:(NSRect)frame;


-(void)printWithHeader;

- (void)drawPageBorderWithSize:(NSSize)borderSize;

- (BOOL)knowsPageRange:(NSRangePointer)range;


- (void)textEditDoForegroundLayoutToCharacterIndex:(NSUInteger)loc;

@end
