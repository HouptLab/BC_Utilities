//
//  BCPrintTextView.h
//  Xynk
//
//  Created by Tom Houpt on 14/7/24.
//
//

#import <Cocoa/Cocoa.h>

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
    
    NSPrintInfo *printInfo;
    NSMutableDictionary *borderTextAttributes;
    NSMutableAttributedString *printString;
    NSInteger pageNumber;
    
}

@property (copy) NSString *title;
@property (copy) NSString *author;
@property (copy) NSMutableDictionary *borderTextAttributes;

@property (assign)  BOOL printAuthor;
@property (assign)  BOOL printTitle;
@property (assign)  BOOL printPageNums;

- (id)initWithFrame:(NSRect)frame;
- (void)drawPageBorderWithSize:(NSSize)borderSize;

@end
