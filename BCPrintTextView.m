//
//  BCPrintTextView.m
//  Xynk
//
//  Created by Tom Houpt on 14/7/24.
//
//

#import "BCPrintTextView.h"

@implementation BCPrintTextView


@synthesize title;
@synthesize author;

@synthesize borderTextAttributes;
@synthesize printAuthor;
@synthesize printTitle;
@synthesize printPageNums;

- (id)initWithFrame:(NSRect)frame { // designated initializer
    if ((self = [super initWithFrame:frame])) {
        
        printInfo = [NSPrintInfo sharedPrintInfo];
        [printInfo setLeftMargin:72];
        [printInfo setRightMargin:72];
        [printInfo setTopMargin:72];
        [printInfo setBottomMargin:72];
        [printInfo setVerticallyCentered:NO];

        
        printAuthor = NO;
        printTitle = YES;
        printPageNums = YES;
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
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

      CGFloat headerStringX = borderSize.width - [printInfo
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


 @end

