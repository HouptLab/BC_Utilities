//
//  BCFontUtilities.m
//  Xynk
//
//  Created by Tom Houpt on 13/8/10.
//
//

#import "BCFontUtilities.h"


void SetFontStyleControlSelection(NSSegmentedControl *fontStyleControl, NSInteger styleFlags) {
    
    
    [fontStyleControl setSelected:(BOOL)(styleFlags & kBCBoldFlag) forSegment:0];
    [fontStyleControl setSelected:(BOOL)(styleFlags & kBCItalicFlag) forSegment:1];
    [fontStyleControl setSelected:(BOOL)(styleFlags & kBCUnderlinedFlag) forSegment:2];
}

NSInteger  GetFontStyleFlagsFromControlSelection(NSSegmentedControl *fontStyleControl) {
    NSInteger fontStyleFlags = 0;
    fontStyleFlags =  kBCBoldFlag * [fontStyleControl isSelectedForSegment:0]
    + kBCItalicFlag * [fontStyleControl isSelectedForSegment:1]
    + kBCUnderlinedFlag * [fontStyleControl isSelectedForSegment:2];
    return fontStyleFlags;
}

void SetJustificationControlSelection(NSSegmentedControl *justificationControl, NSInteger justification) {
    
    NSInteger i;
    for (i=LEFT_JUSTIFIED; i <= RIGHT_JUSTIFIED; i++) {
        if (i != justification) {
            [justificationControl setSelected:NO forSegment:i];
        }
        else {
            [justificationControl setSelected:YES forSegment:i];

        }
    }
}

NSInteger  GetJustificationFromControlSelection(NSSegmentedControl *justificationControl) {
    NSInteger i;
    for (i=LEFT_JUSTIFIED; i <= RIGHT_JUSTIFIED; i++) {
            if ([justificationControl isSelectedForSegment:i]) {
                return i;
            };
    }
    return LEFT_JUSTIFIED;
}

void SetAlignmentControlSelection(NSSegmentedControl *alignmentControl, NSInteger justification) {
    
    SetJustificationControlSelection(alignmentControl,justification);
}

NSInteger GetAlignmentFromControlSelection(NSSegmentedControl *alignmentControl) {
    
    return GetJustificationFromControlSelection(alignmentControl);
}

void BuildTypeFacePopUpButton(NSPopUpButton *typeFaceButton,NSString *currentTypeFace) {
    
    // Populate font pop-up.
    // problems mixing and matching pop-up button routines and menu routines (i.e. inserting separator item)
    
    NSMutableArray *fontList = [[NSMutableArray alloc] initWithArray:[[NSFontManager
                                                                       sharedFontManager] availableFontFamilies]];
    [fontList sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [[typeFaceButton menu ] removeAllItems];
    if (![currentTypeFace isEqualToString:@"Helvetica"] || [currentTypeFace isEqualToString:@"Times New Roman"] ) {
        
        [[typeFaceButton menu ] addItemWithTitle:currentTypeFace action:NULL keyEquivalent:@""];
    }
    [[typeFaceButton menu ] addItemWithTitle:@"Helvetica" action:NULL keyEquivalent:@""];
    [[typeFaceButton menu ] addItemWithTitle:@"Times New Roman" action:NULL keyEquivalent:@""];
    
    // NOTE: insert list of recent fonts used here?
    [[typeFaceButton menu ] addItem:[NSMenuItem separatorItem]];
    for (NSString *fontName in fontList) {
        [[typeFaceButton menu] addItemWithTitle:fontName action:NULL keyEquivalent:@""];
    }
    if (![currentTypeFace isEqualToString:@"Helvetica"] || [currentTypeFace isEqualToString:@"Times New Roman"] ) {
        [typeFaceButton selectItemAtIndex:0];
    }
    else if ([currentTypeFace isEqualToString:@"Helvetica"]) {
        [[typeFaceButton menu] addItemWithTitle:currentTypeFace action:NULL keyEquivalent:@""];
        [typeFaceButton selectItemAtIndex:0];
    }
    else if ([currentTypeFace isEqualToString:@"Times New Roman"]) {
        [[typeFaceButton menu ] addItemWithTitle:currentTypeFace action:NULL keyEquivalent:@""];
        [typeFaceButton selectItemAtIndex:1];
    }
}

NSTextAlignment BCtoNSTextAlignment(BCFontHorzAlignmentOptions just) {
    if (just == 1) { just = 2; }
    else if (just == 2) {just = 1; }
    return (NSTextAlignment)just;
}
