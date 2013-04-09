//
//  BCColorPopupMenuItemView.h
//  Xynk
//
//  Created by Tom Houpt on 13/3/3.
//
//


#import <Cocoa/Cocoa.h>

#define sideMargin 8.0
#define topMargin 8.0
#define numRows 10
#define numColumns 12
#define numColors 119
#define squareSize 16.0

@interface BCColorPopupMenuItemView : NSView {
@private
    
    NSInteger _selectedIndex;
    NSInteger _lastSelectedIndex;
	NSMutableArray *_trackingAreas;
    BOOL _thumbnailsNeedUpdate;
    NSTrackingArea *_paletteTrackingArea;
    NSArray *svgColors;


}

/* These two properties are used to detemine which images to use and the current selection, if any. They me be set and interrogated manually, but in this sample code, they are bound to an NSDictionary in CustomMenusAppDelegate.m -setupImagesMenu.
 */
@property (nonatomic, retain) NSArray *imageUrls;
@property (nonatomic, retain, readonly) NSURL *selectedImageUrl;

-(NSRect)getIndexSquare:(NSInteger)index;

@end

