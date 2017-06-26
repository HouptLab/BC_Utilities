//
//  BCFillPatternPopupMenuItemView.h
//  Xynk
//
//  Created by Tom Houpt on 14/11/21
//
//

/* Set up the custom views in the popup button menu. This method should be called whenever the baseURL changes.
 In MainMenu.xib, the menu for the popup button is defined. There is one menu item with a tag of 1000 that is used as the prototype for the custom menu items. Each colorPickerMenuItemView can contain 4 images. So we keep duplicating the prototype menu item until we have enough menu items for each image found in the directory specified by _baseURL. Duplicating the prototype menu allows us to reuse the target action wiring done in IB.
 We need to rebuild this menu each time the _baseURL changes. To accomplish this, we set the tag of each dupicated prototype to 1001. This way we can easily find and remove them to start over.
 */

// USAGE:
// in nib, define a NSPopupButton with one menu item with tag 1000
// call SetUpColorPickerMenu(NSPopupButtonMenu) to set up the menu
// set the selected index with SetSelectedColorIndex
// find the selected index with GetSelectedColorIndex
// make sure the NSPopUpButton is 30 x 15
// make sure the "position" is set to "image only"



#import <Cocoa/Cocoa.h>
#import "BCPatternUtilities.h"

#define sideMargin 8.0
#define topMargin 8.0

#define numPatternColumns 6
#define numPatterns [fillPatterns count]
#define numPatternRows (([fillPatterns count]-1)/numPatternColumns)
#define patternSquareSize 28.0


void SetUpFillPatternPickerMenu(NSPopUpButton *fillPatternPickerPopup);
NSInteger GetSelectedFillPatternIndex(NSPopUpButton *fillPatternPickerPopup);
void SetSelectedFillPatternIndex(NSPopUpButton *fillPatternPickerPopup, NSInteger index);
NSNumber *GetSelectedFillPattern(NSPopUpButton *fillPatternPickerPopup);
void SetSelectedFillPattern(NSPopUpButton *fillPatternPickerPopup, NSNumber *theFillPattern);


@interface BCFillPatternPopupMenuItemView : NSView {
@private
    
    NSInteger _selectedIndex;
    NSInteger _lastSelectedIndex;
	NSMutableArray *_trackingAreas;
  //  BOOL _thumbnailsNeedUpdate; not used
    NSTrackingArea *_paletteTrackingArea;
    NSArray *fillPatterns;


}

/* These two properties are used to detemine which images to use and the current selection, if any. They me be set and interrogated manually, but in this sample code, they are bound to an NSDictionary in CustomMenusAppDelegate.m -setupImagesMenu.
 */
@property (nonatomic, retain) NSArray *imageUrls;
@property (nonatomic, retain, readonly) NSURL *selectedImageUrl;

// exposed these 2 properties (originally private)
// so that we can get index instead of imageURL
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) NSInteger lastSelectedIndex;
@property (nonatomic,assign) NSNumber * unknownFillPattern;

-(NSRect)getIndexSquare:(NSInteger)index;

-(NSNumber *)selectedFillPattern;
-(void)setSelectedPattern:(NSNumber *)theFillPattern;
-(void)updateMenuImage;

@end

