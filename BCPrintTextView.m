//
//  BCPrintTextView.m
//  Xynk
//
//  Created by Tom Houpt on 14/7/24.
//
//

#import "BCPrintTextView.h"



NSSize documentSizeForPrintInfo(NSPrintInfo *printInfo) {
    NSSize paperSize = [printInfo paperSize];
    paperSize.width -= ([printInfo leftMargin] + [printInfo rightMargin]) - kDefaultTextPadding * 2.0;
    paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
    return paperSize;
}

@implementation BCPrintTextView

@synthesize thePrintInfo;

@synthesize title;
@synthesize author;
@synthesize borderTextAttributes;

@synthesize printAuthor;
@synthesize printTitle;
@synthesize printPageNums;
@synthesize wrappingToFit;

@synthesize originalSize;


- (id)initWithFrame:(NSRect)frame { // designated initializer
    if ((self = [super initWithFrame:frame])) {
        
        printAuthor = NO;
        printTitle = YES;
        printPageNums = YES;
        wrappingToFit = YES;
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)printWithHeader; {

    self.thePrintInfo = [NSPrintInfo sharedPrintInfo];
    [self.thePrintInfo  setVerticallyCentered:NO];
    [self.thePrintInfo  setHorizontallyCentered:NO];

    [self.thePrintInfo setHorizontalPagination:NSFitPagination];
    [self.thePrintInfo setVerticallyCentered: NSAutoPagination];

    [self setOriginalSize:[self frame].size];
    
    [[NSPrintOperation printOperationWithView:self printInfo:self.thePrintInfo] runOperation];
    
    // restore original size
    [self setFrameSize:self.originalSize];
    // NOTE: do we need to reset any textContainer or layoutManager settings altered by knowsPageRange:?

}

#pragma mark Printing
- (void)drawPageBorderWithSize:(NSSize)borderSize {

    NSMutableString *headerString = [[NSMutableString alloc] init];

    // Create attributes dictionary for drawing border text.
    borderTextAttributes = [[NSMutableDictionary alloc] init];
    [borderTextAttributes setObject:[NSFont
                                     fontWithName:@"Helvetica" size:9.0] forKey:NSFontAttributeName];

    // Temporarily set print view frame size to border size (paper
    // size), to print in margins.
    NSRect savedFrame = [self frame];
    [self setFrame:NSMakeRect(0, 0, borderSize.width,
                              borderSize.height)];

    // NO == 0 but YES is only guaranteed to be non-zero for
    // [NSNumber boolValue]
    if (printAuthor  != NO) {
        [headerString appendString: self.author];
    }

    if (printTitle != NO) {
        if (![headerString isEqual: @""])
            [headerString appendString: @", "];
        [headerString appendString: self.title];
    }

    if (printPageNums != NO) {
        pageNumber = [[NSPrintOperation currentOperation] currentPage];
        NSString *pageNumberString = [NSString stringWithFormat:@"p. %ld", pageNumber];

              if (![headerString isEqual: @""]) {
                  [headerString appendString: @", "];
              }

              [headerString appendString: pageNumberString];
    }

    if (![headerString isEqual: @""]) {
      // Draw right header in top margin.
      NSSize headerStringSize = [headerString sizeWithAttributes:
                                 [self borderTextAttributes]];

      CGFloat headerStringX = borderSize.width - [self.thePrintInfo
                                                rightMargin] - headerStringSize.width-5.0; // add 5 for an extra buffer
      CGFloat headerStringY = headerStringSize.height * 2;
      [self lockFocus];
      [headerString
       drawAtPoint:NSMakePoint(headerStringX, headerStringY)
       withAttributes:[self borderTextAttributes]];
      [self unlockFocus];

      // Restore print view frame size.
      [self setFrame:savedFrame];
    }
}




// from TextEdit PrintView.m
/* Override of knowsPageRange: checks printing parameters against the last invocation, and if not the same, resizes the view and relays out the text.  On first invocation, the saved size will be 0,0, which will cause the text to be laid out.
 */
- (BOOL)knowsPageRange:(NSRangePointer)range {
    NSSize documentSizeInPage = documentSizeForPrintInfo(self.thePrintInfo);
    
    if (!NSEqualSizes(previousValueOfDocumentSizeInPage, documentSizeInPage) || (previousValueOfWrappingToFit != wrappingToFit)) {
        previousValueOfDocumentSizeInPage = documentSizeInPage;
        previousValueOfWrappingToFit = wrappingToFit;
        
        NSSize size = wrappingToFit ? documentSizeInPage : self.originalSize;
        [self setFrame:NSMakeRect(0.0, 0.0, size.width, size.height)];
        [[[self textContainer] layoutManager] setDefaultAttachmentScaling:wrappingToFit ? NSImageScaleProportionallyDown : NSImageScaleNone];
        [self textEditDoForegroundLayoutToCharacterIndex:NSIntegerMax];     // Make sure the whole document is laid out
    }
    return [super knowsPageRange:range];
}

/* This method causes the text to be laid out in the foreground (approximately) up to the indicated character index.  Note that since we are adding a category on a system framework, we are prefixing the method with "textEdit" to greatly reduce chance of any naming conflict.
 */
- (void)textEditDoForegroundLayoutToCharacterIndex:(NSUInteger)loc {
    NSUInteger len;
    if (loc > 0 && (len = [[self textStorage] length]) > 0) {
        NSRange glyphRange;
        if (loc >= len) loc = len - 1;
        /* Find out which glyph index the desired character index corresponds to */
        glyphRange = [[self layoutManager] glyphRangeForCharacterRange:NSMakeRange(loc, 1) actualCharacterRange:NULL];
        if (glyphRange.location > 0) {
            /* Now cause layout by asking a question which has to determine where the glyph is */
            (void)[[self layoutManager] textContainerForGlyphAtIndex:glyphRange.location - 1 effectiveRange:NULL];
        }
    }
}


 @end

