//
//  BCFontUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 13/8/10.
//
//

#import <Foundation/Foundation.h>

// formatting bit flags
#define kBCBoldFlag 1
#define kBCItalicFlag 2
#define kBCUnderlinedFlag 4

enum justify { LEFT_JUSTIFIED = 0, CENTER_JUSTIFIED, RIGHT_JUSTIFIED };

enum verticalAlignment { TOP_ALIGNED = 0, MIDDLE_ALIGNED, BOTTOM_ALIGNED };

void SetFontStyleControlSelection(NSSegmentedControl *fontStyleControl, NSInteger styleFlags);
NSInteger  GetFontStyleFlagsFromControlSelection(NSSegmentedControl *fontStyleControl);

void SetJustificationControlSelection(NSSegmentedControl *justificationControl, NSInteger justification);
NSInteger GetJustificationFromControlSelection(NSSegmentedControl *justificationControl);

void SetAlignmentControlSelection(NSSegmentedControl *alignmentControl, NSInteger justification);
NSInteger GetAlignmentFromControlSelection(NSSegmentedControl *alignmentControl);

void BuildTypeFacePopUpButton(NSPopUpButton *typeFaceButton,NSString *currentTypeFace);




