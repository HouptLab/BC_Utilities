//
//  BCColorPopupMenuItemView.m
//  Xynk
//
//  Created by Tom Houpt on 13/3/3.
//
//

#import "BCColorPopupMenuItemView.h"
#import "BCColorUtilities.h"

// #import "NSImageThumbnailExtensions.h"

void SetUpColorPickerMenu(NSPopUpButton *colorPickerPopup) {
    
    // load the custom view and its controller, attach to the menu item of the popup menu
    
    // define a PopupButtonMenu with one item with tag 1000
    // call setUpColorPickerMenu to set up the menu
    
    [[colorPickerPopup menu] removeAllItems];
    NSMenuItem *colorMenuItem = [NSMenuItem new];
   // [colorMenuItem setTitle:@"colorPickerView"];
    [colorMenuItem setTag:1000];
    
   // NSMenuItem *colorMenuItem = [[colorPickerPopup menu] itemWithTag:1000];
    // Load the custom view from its nib
    NSViewController *viewController = [[NSViewController alloc] initWithNibName:@"BCColorPopupMenuItemView" bundle:nil];
    [colorMenuItem setView:viewController.view];
    [[colorPickerPopup menu] addItem:colorMenuItem];
    
    [(BCColorPopupMenuItemView *)viewController.view setMyPopUpButton: colorPickerPopup];
    
    //    [colorMenuItem setTag:1001]; // set the tag to 1001 so we can remove this instance on rebuild (see above)
    //    [colorMenuItem setHidden:NO];
    //
    // Insert the custom menu item
    //    [menu insertItem:imagesMenuItem atIndex:[menu numberOfItems] - 2];
    
    [[colorPickerPopup menu] addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *colorPanelItem =[NSMenuItem new];
    [colorPanelItem setTitle:@"Color Panel…"];
    [colorPanelItem setImage: [NSImage imageNamed:@"NSColorPanel"]];
    [colorPanelItem setTarget:(BCColorPopupMenuItemView *)viewController.view];
    [colorPanelItem setAction:@selector(showColorPanel:)];
    [[colorPickerPopup menu] addItem:colorPanelItem];
    
}

NSInteger GetSelectedColorIndex(NSPopUpButton *colorPickerPopup) {
    
    NSMenuItem *colorMenuItem = [[colorPickerPopup menu] itemWithTag:1000];
    return [(BCColorPopupMenuItemView *)[colorMenuItem view] selectedIndex];
    
}

void SetSelectedColorIndex(NSPopUpButton *colorPickerPopup, NSInteger index) {
    
    NSMenuItem *colorMenuItem = [[colorPickerPopup menu] itemWithTag:1000];
    return [(BCColorPopupMenuItemView *)[colorMenuItem view] setSelectedIndex:index];
    
}
void SetSelectedColor(NSPopUpButton *colorPickerPopup, NSColor *theColor) {
    
    NSMenuItem *colorMenuItem = [[colorPickerPopup menu] itemWithTag:1000];
     [(BCColorPopupMenuItemView *)[colorMenuItem view] setSelectedColor:theColor];
    
}

void SetThemePaletteForColorPicker(NSPopUpButton *colorPickerPopup, NSArray * themePalette) {
    
    NSMenuItem *colorMenuItem = [[colorPickerPopup menu] itemWithTag:1000];
    [(BCColorPopupMenuItemView *)[colorMenuItem view] setThemePalette:themePalette];
}


NSColor *GetSelectedColor(NSPopUpButton *colorPickerPopup) {
    
    NSMenuItem *colorMenuItem = [[colorPickerPopup menu] itemWithTag:1000];
    return [(BCColorPopupMenuItemView *)[colorMenuItem view] selectedColor];
    
}


//@interface BCColorPopupMenuItemView ()
//
///* declare the selectedIndex property in an anonymous category since it is a private property
// */
//@property(nonatomic, assign) NSInteger selectedIndex;
//@property(nonatomic, assign) NSInteger lastSelectedIndex;
//
//@end

@implementation BCColorPopupMenuItemView

// key for dictionary in NSTrackingAreas's userInfo
#define kTrackerKey @"whichColorSquare"

#define kNoSelection -1

@synthesize selectedIndex = _selectedIndex;
@synthesize selectedImageUrl;
@synthesize lastSelectedIndex = _lastSelectedIndex;
@synthesize imageUrls = _imageUrls;
@synthesize unknownColor;
@synthesize themePalette;
@synthesize myPopUpButton;

/* Make sure that any key value observer of selectedImageUrl is notified when change our internal selected index.
 Note: Internally, keep track of a selected index so that we can eaasily refer to the imageView spinner and URL associated with index. Externally, supply only a selected URL.
 */
+ (NSSet *)keyPathsForValuesAffectingSelectedImageUrl
{
    return [NSSet setWithObjects:@"selectedIndex", nil];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIndex = kNoSelection;
        self.lastSelectedIndex = self.selectedIndex;
        svgColors = GetSvgColorArray();
    }
    return self;
}

/* Place all the image views and spinners (circular progress indicators) that are wired up in the nib into NSArrays. This dramtically reduces code allowing us to easily link image view, spinners and URL sets.
 */
- (void)awakeFromNib {
//    _imageViews = [[NSArray alloc] initWithObjects:imageView1, imageView2, imageView3, imageView4, nil];
//    _spinners = [[NSArray alloc] initWithObjects:spinner1, spinner2, spinner3, spinner4, nil];
}

//- (void)dealloc {
//    // tracking areas are removed from the view during dealloc, all we need to do is release our area of them
//    [_trackingAreas release];
//    
//    [_imageUrls release];
//    [_imageViews release];
//    [_spinners release];
//    
//    [super dealloc];
//}

/* Custom selectedIndex property setter so that we can be sure to redraw when the selection index changes.
 */
- (void)setSelectedIndex:(NSInteger)index {
    if (_selectedIndex != index) {
        _selectedIndex = index;
    }
    
    [self setNeedsDisplay:YES];
}


/* If there is a selection, fill a rect behind the selected image view. Since the image view is a subview of this view, it will look like a border around the image.
 */
- (void)drawRect:(NSRect)dirtyRect {
    
    // try a transform to offset by 0.5 pixels
	NSAffineTransform* xform = [NSAffineTransform transform];
    
    // Add the transformations
    [xform translateXBy:0.5 yBy:0.5];

    // Apply the changes
    [xform concat];

    [self drawSvgColorMatrix];
    if (nil != themePalette) { [self drawPaletteMatrix]; }

    // now highlight the selected color
    if (self.selectedIndex == kNoSelection  ) {
        self.selectedIndex = self.lastSelectedIndex;
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect r;
     r = [self getPaletteSquare: 0];

    if (-100 <= self.selectedIndex && self.selectedIndex < -93) {
        r = [self getPaletteSquare: self.selectedIndex];
       
    }
    else if (0 <= self.selectedIndex && self.selectedIndex < numColors) {
        r = [self getIndexSquare: self.selectedIndex];
    }
    [path appendBezierPathWithRect:r];
    [path setLineWidth: 3.0];
    [[NSColor blackColor] set];
    [path stroke];
    


}

/* As the window that contains the popup menu is created, the view associated with the menu item (this view) is added to the window. When the window is destroyed the view is removed from the window, but still retained by the menu item. A new window is created and destroyed each time a menu is displayed. This makes this method the ideal place to start and stop animations.
 */
- (void)viewDidMoveToWindow {
//    if (self.window) {
//        // In IB, this view is set to stretch to the width of the menu window. However, we cannot set the springs and struts of our containing image and spinner views to auto center themeselves. We get around this by placing the the image and spinner views inside another, non-resizeable NSView in IB. Now, all we need to do here, is center that one non-resizeable container view.
//        NSView *containerView = [[self subviews] objectAtIndex:0];
//        NSRect parentFrame = self.frame;
//        NSRect centeredFrame = containerView.frame;
//        centeredFrame.origin.x = floorf((parentFrame.size.width - centeredFrame.size.width) / 2.0f) + parentFrame.origin.x;
//        centeredFrame.origin.y = floorf((parentFrame.size.height - centeredFrame.size.height) / 2.0f) + parentFrame.origin.y;
//        containerView.frame = centeredFrame;
//        
//        // Start any animations here
//        // The spinner animation is only done when we need to generate new thumbnail images. See the -viewWillDraw method implementation in this file.
//    } else {
//        // Make sure that all the spinners stop animating
//        for  (NSProgressIndicator *spinner in _spinners) {
//            [spinner stopAnimation:nil];
//            [spinner setHidden:YES];
//        }
//    }
}

/* Do everything associated with sending the action from user selection such as terminating menu tracking.
 */
- (void)sendAction {
    NSMenuItem *actualMenuItem = [self enclosingMenuItem];
    
    // Send the action set on the actualMenuItem to the target set on the actualMenuItem, and make come from the actualMenuItem.
    [NSApp sendAction:[actualMenuItem action] to:[actualMenuItem target] from:actualMenuItem];
	
	// dismiss the menu being tracked
	NSMenu *menu = [actualMenuItem menu];
	[menu cancelTracking];
    
    [self updateMenuImage];

    
    self.lastSelectedIndex = self.selectedIndex;
    
	//[self setNeedsDisplay:YES];
}

-(NSRect)getPaletteSquare:(NSInteger)index; {
    
    
    NSRect r =  NSMakeRect((index +100) * (paletteSquareSize + 3) + sideMargin,
                           (numRows * squareSize + 2* topMargin),
                           paletteSquareSize,
                           paletteSquareSize);
    
    return r;

    
}

-(NSRect)getIndexSquare:(NSInteger)index; {
    
    NSInteger rowIndex = index / numColumns;
    NSInteger columnIndex = index % numColumns;
    
    NSRect r =  NSMakeRect(columnIndex * squareSize + sideMargin,
                           (numRows * squareSize + topMargin) - ((rowIndex + 1)* squareSize),
                           squareSize,
                           squareSize);

    return r;
}

#pragma mark -
#pragma mark Mouse Tracking

/* Mouse tracking is easily accomplished via tracking areas. We setup a tracking area for each image view and watch as the mouse moves in and out of those tracking areas. When a mouse up occurs, we can send our action and close the menu.

 */
-(id) trackingAreaForPalette; {
    
    // make tracking data (to be stored in NSTrackingArea's userInfo) so we can later determine the color square without hit testing
    NSDictionary *trackerData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:-1], kTrackerKey, nil];

    // trackingRect will be the square drawn for the given index color
    NSRect trackingRect = NSMakeRect(sideMargin,topMargin,numColumns * squareSize,numRows * squareSize);

    NSTrackingAreaOptions trackingOptions = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp;

    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect options:trackingOptions owner:self userInfo:trackerData];

    return trackingArea;

}
/* Properly create a tracking area for an image view.
 */
- (id)trackingAreaForIndex:(NSInteger)index; {
    // make tracking data (to be stored in NSTrackingArea's userInfo) so we can later determine the color square without hit testing    
    NSDictionary *trackerData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:index], kTrackerKey, nil];
    
    // trackingRect will be the square drawn for the given index color
    NSRect trackingRect =  [self getIndexSquare:index];
    
    NSTrackingAreaOptions trackingOptions = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp;
    
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect options:trackingOptions owner:self userInfo:trackerData];
    
    return trackingArea;
    
}
- (id)trackingAreaForPaletteIndex:(NSInteger)index; {
    // make tracking data (to be stored in NSTrackingArea's userInfo) so we can later determine the color square without hit testing
    
    NSDictionary *trackerData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:index], kTrackerKey, nil];
    
    // trackingRect will be the square drawn for the given index color
    NSRect trackingRect =  [self getPaletteSquare:index];
    
    NSTrackingAreaOptions trackingOptions = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp;
    
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect options:trackingOptions owner:self userInfo:trackerData];
    
    return trackingArea;
    
}

/* The view is automatically asked to update the tracking areas at the appropriate time via this overridable methos.
 */
- (void)updateTrackingAreas {
    // Remove any existing tracking areas
	if (_trackingAreas) {
        for (NSTrackingArea *trackingArea in _trackingAreas) {
            [self removeTrackingArea:trackingArea];
        }
        
    }
    
    NSTrackingArea *trackingArea;
    _trackingAreas = [NSMutableArray array] ;	// keep all tracking areas in an array
    
    
    // add a big tracking area for the entire palette, to deselect when exited
    _paletteTrackingArea = [self trackingAreaForPalette];
    [self addTrackingArea:_paletteTrackingArea];
    

    
    /* Add a tracking area for each image view. We use an integer for-loop instead of fast enumeration because we need to link the tracking area to the index.
     */
    for (NSInteger index = 0; index < (NSInteger)numColors; index++) {
        trackingArea = [self trackingAreaForIndex:index];
        [_trackingAreas addObject:trackingArea];
        [self addTrackingArea: trackingArea];
      //  NSLog(@"Tracking Area %@",[trackingArea description]);
    }
    
    if (nil != themePalette) {
        for (NSInteger index = -100; index < -93; index++) {
            trackingArea = [self trackingAreaForPaletteIndex:index];
            [_trackingAreas addObject:trackingArea];
            [self addTrackingArea: trackingArea];
        }
    }
}

/* The mouse is now over one of our child image views. Update selection.
 */
- (void)mouseEntered:(NSEvent*)event {
    // The index of the image view is stored in the user data.
	NSInteger index = [[(NSDictionary*)[event userData] objectForKey:kTrackerKey] integerValue];
    if (-1 != index) {
        self.selectedIndex = index;
       // NSLog(@"mouseEntered square: %ld", index);
    }
}

/* The mouse has left one of our child image views.
 if it left the paletteTrackingArea (index = -1), then Set the selection to no selection.
 */
- (void)mouseExited:(NSEvent*)event {
    
    NSInteger index = [[(NSDictionary*)[event userData] objectForKey:kTrackerKey] integerValue];
    
  //  NSLog(@"mouseExited square: %ld", index);
    
    if (-1 == index) {
        self.selectedIndex = self.lastSelectedIndex;
    }
    [self setNeedsDisplay:YES];

    
}

/* The user released the mouse button. Send the action and let the target ask for the selection. Notice that there is no mouseDown: implementation. This is because the user may have held the mouse down as the menu popped up. Or the user may click on this view, but drag into another menu item. That menu item needs to be able to start tracking the mouse. Therefore, we only keep track of our selection via the tracking areas and send our action to our target when the user releases the mouse button inside this view.
 */
- (void)mouseUp:(NSEvent*)event {
    [self sendAction];
}

#pragma mark -
#pragma mark Keyboard Tracking

/* In addition to tracking the mouse, we want to allow changing our selection via the keyboard.
 */

/* Must return YES from -acceptsFirstResponder or we will not get key events. By default NSView return NO.
 */
- (BOOL)acceptsFirstResponder {
    return YES;
}

/* Set the selected index to the first image view if there is no current selection. We check for a current selection because a mouse down inside a child image view will cause this method to be called and we don't want to change the user's mouse selection.
 */
- (BOOL)becomeFirstResponder {
    if (self.selectedIndex == kNoSelection) {
        self.selectedIndex = 0;
    }
    
    return YES;
}

/* We will lose first responder status when the user arrows up or down, or when the menu window is destroyed. If the user keyboard navigates to another NSMenuItem then remove any selection, and if the menu window is destroyed, then the selection no longer matters.
 */
- (BOOL)resignFirstResponder {
    // 2024_3 don't reset selectedIndex -- might be resigning because multiple popup menus in this dialog, a la mindseye
  //  self.selectedIndex = kNoSelection;
    return YES;
}




-(void) drawSvgColorMatrix; {
    
    // assume svgColorDictionary is already instantiated, without any duplicates
    // save first square for no-fill
    
    // empty + 138 colors = 139 squares
   // plot in a 12 x 12 matrix
   // make each square 10px x 10 px

        
    NSUInteger colorIndex;
    NSBezierPath *path;
    NSRect r;
     

    
    // now draw all the other little squares
    
    for (colorIndex = 0; colorIndex < numColors; colorIndex++) {
    
        path = [NSBezierPath bezierPath];

        r = [self getIndexSquare:colorIndex];

        [path appendBezierPathWithRect:r];
        [(NSColor *)[svgColors objectAtIndex:colorIndex] set];
        [path fill];
        [[NSColor blackColor] set];
        [path setLineWidth: 0.5];
        [path stroke];

    }
    
    // add diagonal red line from right top to left bottom of clear square
    r =  [self getIndexSquare:0];
    NSBezierPath *diagonalPath = [NSBezierPath bezierPath];
    [diagonalPath moveToPoint:NSMakePoint(r.origin.x, r.origin.y)];
    [diagonalPath lineToPoint:NSMakePoint(r.origin.x+squareSize, r.origin.y+squareSize)];
    [[NSColor redColor] set];
    [diagonalPath setLineWidth: 2.0];
    [diagonalPath stroke];

 

    
}

-(void)drawPaletteMatrix; {
    
    
    NSRect r;
    NSBezierPath *path;
    
    for (NSInteger i =-100; i< -93; i++) {
        path = [NSBezierPath bezierPath];
        
        r = [self getPaletteSquare:i];
        
        [path appendBezierPathWithRect:r];
        [(NSColor *)[themePalette objectAtIndex:i+100] set];
        [path fill];
        [[NSColor blackColor] set];
        [path setLineWidth: 0.5];
        [path stroke];
        
    }
    

}

 
 -(NSColor *)selectedColor; {
     
     if (self.selectedIndex == kNoSelection) {
         if (nil != self.unknownColor) {
             return self.unknownColor;
         }
         return [NSColor clearColor];
     }
     
     if (-100 <= self.selectedIndex && self.selectedIndex < -93) {
     
         return (NSColor *)[themePalette objectAtIndex:self.selectedIndex+100];
      
     }
     
     return (NSColor *)[svgColors objectAtIndex:self.selectedIndex];
     
 }

-(void)setSelectedColor:(NSColor *)theColor {
    
    if (nil == theColor) {
        self.selectedIndex = kNoSelection;
    }
    else {
        self.selectedIndex = GetSvgArrayIndexByMatchingColor(theColor);
        if (kNoSelection == self.selectedIndex) {
            self.unknownColor = theColor;
        }
        
    }
    
    [self updateMenuImage];
    
    [self setNeedsDisplay:YES];
}

-(void)updateMenuImage; {
    
    NSMenuItem *actualMenuItem = [self enclosingMenuItem];

    // set the menu item image to our color
    NSRect colorRect = NSMakeRect(0,0,30,12);
    NSImage* colorImage = [[NSImage alloc] initWithSize:colorRect.size] ;
    
    [colorImage lockFocus];
    NSColor *theColor = [self.selectedColor  colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    
    if (0.0 == [theColor alphaComponent]) {
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:colorRect];
        [[NSColor blackColor] setStroke];
        [[NSColor whiteColor] setFill];
        [path fill];
        [path stroke];
        
        path = [NSBezierPath bezierPath];
        [path moveToPoint:colorRect.origin];
        [path lineToPoint:NSMakePoint(colorRect.size.width,colorRect.size.height)];
        [[NSColor redColor] setStroke];
        [path stroke];
        
        
    }
    else {
        [self.selectedColor setFill];
        NSRectFill(colorRect);
    }
    [colorImage unlockFocus];
    
    
    [actualMenuItem setImage:colorImage];
}

-(IBAction)showColorPanel:(id)sender; {
    
    // show the …, and tell it to send us a message when a color is chosen...
    NSColorPanel* panel=[NSColorPanel sharedColorPanel];

    [panel setTarget:self];
    [panel setAction:@selector(colorFromColorPanel:)];
    [panel makeKeyAndOrderFront:self];

    
}
-(IBAction)colorFromColorPanel:(id)sender; {
    
    // NOTE: this is a hack to 1) close the NSColorPanel, rather than leave it connected (since we (the ColorPopupMenuItemView) may disappear) and 2) to set out popup menu to display us rather then the … menu item
    [self setSelectedColor:((NSColorPanel *)sender).color];
    [((NSColorPanel *)sender) setTarget:nil];
    [((NSColorPanel *)sender) close];
    [ myPopUpButton selectItem:[self enclosingMenuItem]];
    [self sendAction];
}
@end
