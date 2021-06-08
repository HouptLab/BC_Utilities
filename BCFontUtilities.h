//
//  BCFontUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 13/8/10.
//
//

#import <Cocoa/Cocoa.h>

// formatting bit flags

typedef NS_OPTIONS(NSUInteger,BCFontFormatOptions) {
    kBCPlainFlag = 0,
    kBCBoldFlag = 1 << 0,
    kBCItalicFlag = 1 << 1,
    kBCUnderlinedFlag = 1 << 2
};

// NOTE: make congruent with NSTextAlignment

typedef NS_ENUM(NSInteger, BCFontHorzAlignmentOptions)  { LEFT_JUSTIFIED = 0,
    CENTER_JUSTIFIED,
    RIGHT_JUSTIFIED
};

typedef NS_ENUM(NSInteger, BCFontVertAlignmentOptions) {
    TOP_ALIGNED = 0,
    MIDDLE_ALIGNED,
    BOTTOM_ALIGNED
};

void SetFontStyleControlSelection(NSSegmentedControl *fontStyleControl, NSUInteger styleFlags);
NSUInteger  GetFontStyleFlagsFromControlSelection(NSSegmentedControl *fontStyleControl);

void SetJustificationControlSelection(NSSegmentedControl *justificationControl, NSInteger justification);
NSInteger GetJustificationFromControlSelection(NSSegmentedControl *justificationControl);

void SetAlignmentControlSelection(NSSegmentedControl *alignmentControl, NSInteger justification);
NSInteger GetAlignmentFromControlSelection(NSSegmentedControl *alignmentControl);

void BuildTypeFacePopUpButton(NSPopUpButton *typeFaceButton,NSString *currentTypeFace);
void BuildTypeFacePopUpButtonWithSystemFont(NSPopUpButton *typeFaceButton,NSString *currentTypeFace);

NSTextAlignment BCtoNSTextAlignment(BCFontHorzAlignmentOptions just);

/** wrapper for NSFont fontWithName:size:
 
 @param fontName the name of the font. If fontName is nil or @"System Font Regular", then the current sytem font is returned using [NSFont systemFontOfSize:]
 @param fontSize the size of the font in points
 @return an NSFont with the given name and font size, or system font if fontName nil
 */
NSFont *FontWithNameAndSize(NSString *fontName, CGFloat fontSize);

