//
//  BCFontUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 13/8/10.
//
//

#import <Foundation/Foundation.h>

// formatting bit flags

typedef NS_OPTIONS(NSUInteger,BCFontFormatOptions) {
    kBCPlainFlag = 0,
    kBCBoldFlag = 1 << 0,
    kBCItalicFlag = 1 << 1,
    kBCUnderlinedFlag = 1 << 2
};

typedef NS_ENUM(NSInteger, BCFontHorzAlignmentOptions)  { LEFT_JUSTIFIED = 0,
    CENTER_JUSTIFIED,
    RIGHT_JUSTIFIED
};

typedef NS_ENUM(NSInteger, BCFontVertAlignmentOptions) {
    TOP_ALIGNED = 0,
    MIDDLE_ALIGNED,
    BOTTOM_ALIGNED
};

void SetFontStyleControlSelection(NSSegmentedControl *fontStyleControl, NSInteger styleFlags);
NSInteger  GetFontStyleFlagsFromControlSelection(NSSegmentedControl *fontStyleControl);

void SetJustificationControlSelection(NSSegmentedControl *justificationControl, NSInteger justification);
NSInteger GetJustificationFromControlSelection(NSSegmentedControl *justificationControl);

void SetAlignmentControlSelection(NSSegmentedControl *alignmentControl, NSInteger justification);
NSInteger GetAlignmentFromControlSelection(NSSegmentedControl *alignmentControl);

void BuildTypeFacePopUpButton(NSPopUpButton *typeFaceButton,NSString *currentTypeFace);




