/*
 *  BCColorUtilities.h
 *  MindsEye
 *
 *  Created by Tom Houpt on 4/27/11.
 *  Copyright 2011 BehavioralCybernetics. All rights reserved.
 *
 */


#import <Cocoa/Cocoa.h>

#if __MAC_OS_X_VERSION_MAX_ALLOWED > 1070
    typedef NS_ENUM(NSInteger, BColorMenuColorIndex) {
        NOFILLCOLOR = 0,
        REDCOLOR,
        MAROONCOLOR,
        BROWNCOLOR,
        ORANGECOLOR,
        YELLOWCOLOR,
        OLIVECOLOR,
        LIMECOLOR,
        GREENCOLOR,
        TEALCOLOR,
        AQUACOLOR,
        BLUECOLOR,
        NAVYCOLOR,
        FUSCHIACOLOR,
        PURPLECOLOR,
        WHITECOLOR,
        SIVLERCOLOR,
        LIGHTGRAYCOLOR,
        GRAYCOLOR,
        DARKGRAYCOLOR,
        BLACKCOLOR
    };
#else
    typedef enum {
        NOFILLCOLOR = 0,
        REDCOLOR,
        MAROONCOLOR,
        BROWNCOLOR,
        ORANGECOLOR,
        YELLOWCOLOR,
        OLIVECOLOR,
        LIMECOLOR,
        GREENCOLOR,
        TEALCOLOR,
        AQUACOLOR,
        BLUECOLOR,
        NAVYCOLOR,
        FUSCHIACOLOR,
        PURPLECOLOR,
        WHITECOLOR,
        SIVLERCOLOR,
        LIGHTGRAYCOLOR,
        GRAYCOLOR,
        DARKGRAYCOLOR,
        BLACKCOLOR
    } BColorMenuColorIndex;
        
        
#endif

#define COLORS_COUNT 21

// settings for the 16 web standard "vga" colors plus:
// clearColor, brown, orange, lightgray, and darkgray that are pre-defined
// by NSCOlor with preset components
// we arrange the items in ROYGBIV order...
// NOTE: NSColor orangeColor is slightly darker than web standard CSS orange -- we use NSColor settings



NSColor * NSColorFromBCColorIndex(NSInteger bcColorIndex);

NSInteger BCColorIndexFromNSColor(NSColor *theColor);

BOOL NSColorIsClearColor(NSColor *theColor);

CGColorRef CreateCGColorFromNSColor(NSColor *color);

NSColor *CreateNSColorFromCGColor(CGColorRef color);


NSColor *enableColor(BOOL flag);
// a little helper routine to get color of enabled or disabled control

NSColor *CreateNSColorFromRGBValues(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);

// SVG Colors (X11 colors)
// http://www.w3.org/TR/SVG/types.html#ColorKeywords
// total of 149 colors
//  119 colors for display in menu: "clear" and 118 unique colors,
// then 9 duplicate colors (with alternate names) + 1 duplicate "nofill" (duplicate of "clear") + 20 "too-light" colors
NSArray *GetSvgColorArray(void);
NSArray *GetSvgColorNameArray(void);
NSDictionary *GetSvgColorDictionary(void);
NSColor *GetSvgColorByName(NSString *name); // name should be all lower case, no whitespace

NSInteger GetSvgArrayIndexByMatchingColor(NSColor *theColor);

// sort the colors
// http://blog.visualmotive.com/2009/sorting-colors/ gives marix of sorting by different methods
// suggests sorting by YIQ
// various conversion formula: http://www.cs.rit.edu/~ncs/color/t_convert.html
// RGB to YIQ: www.eembc.org/techlit/datasheets/yiq_consumer.pdf

// x11 sorted into pastels, reds, greens, blues, yellows, browns, oranges
// http://www.tayloredmktg.com/rgb/

// ------------------------------------------------------------------
// adding support for NSColors in user defaults

@interface NSUserDefaults(myColorSupport)
- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;
@end

// --------------------------------------------------------------------------------
// drawing hatch and dot patterns into an NSImage of width x width size

// Hatch Patterns flags
#define nohatch 0 // return nil or solid image?
#define tl2br 1 // top left to bottom right
#define tr2bl 2 // top right to bottom left
#define t2b 4   // top to bottom
#define l2r 8   // left to right

// Dot Patterns
#define REGULAR_DOTS 1 // dots in a rectilinear grid, with width pts between each dot (both horz & vertical)
#define STAGGERED_DOTS 2 // note: if staggered, 2 dots in width x width square

// NOTE: rewrite these to return an NSColor directly?

/** constructs a hatched image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 
 the pattern of hatching is specified in a pattern mask of flags for diagonal lines (tl2br, tr2bl) 
 or vertical lines (t2b) or horizontal lines (l2r). Cross hatching is achieved by setting multiple flags,
 i.e. tl2br & tr2bl gives a diagonal cross hatch...
 
 @param width       distance between stripe lines of the hatch
 @param strokeWidth width of lines in hatch in points
 @param strokeColor color of  lines
 @param fillColor   color of background fill
 @param patternMask type of pattern specified as a bit mask of tl2br, tr2bl, t2b,l2r
 
 @return returns an image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 */
NSImage *HatchPatternImage(CGFloat width, CGFloat strokeWidth, NSColor *strokeColor, NSColor *fillColor, NSInteger patternMask);

/** constructs a stippled image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 
 if REGULAR_DOTS pattern is passed, then dots in a rectilinear grid, with width pts between each dot (both horz & vertical)
 if STAGGERED_DOTS pattern is selected, then 2 dots in width x width square
 
 @param width       distance between dots in the stipple pattern
 @param dotDiameter diameter of the dots in points
 @param strokeColor color of  dots (fill & stroke)
 @param fillColor   color of background fill
 @param patternMask type of pattern: REGULAR_DOTS or STAGGERED_DOTS
 
 @return returns an image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 */

NSImage *DotPatternImage(CGFloat width, CGFloat dotDiameter, NSColor *strokeColor, NSColor *fillColor, NSInteger patternMask);

#define kNumDashPatterns 12

typedef NS_ENUM(NSInteger, BCStrokePatternType) {
kSolidStroke = 0,
kDotted = 1,        //< ••••••
kDottedSpaced = 2,      //< • • • •
kDottedTriple = 3,      //< ••• ••• •••

kDashedShort = 4,   //< ----- (5 pixels long, 2 pixels space)
kDashedShortSpaced = 5,   //< - - - - - (double space)
kDashedLong = 6,    //< — — — — (10 pixels long, 4 pixels space),
kDashedLongSpaced =7,    //< —  —  —  — (double space)
kDashedShortLong = 8,    //< -—-—-—-—
    
kDotDashShort = 9,  //< •-•-•-•-
kDotDashLong = 10,   //< •—•—•—•—
kDotDotDashDashLong = 11 //< ••——••——••——
};


/**
 sets the line dash pattern of the given bezier path
 
  packages a call to [NSBezierPath setLineDash:count:phase:] with pre-defined line dash patterns
  the dash patterns are specified using the BCLineDashType enum
 
 @param thePath     the  bezier path which will receive the setLineDash call
 @param dashPattern an enum specifying which line dash pattern to use...
 @param strokeWidth the width of the line being drawn, so we can make dots square?
 */
void SetPathStrokePattern(NSBezierPath *thePath, BCStrokePatternType dashPattern, CGFloat strokeWidth);
 
NSMenu *SetUpDashPickerMenu(NSColor *strokeColor);


// compare 2 colors by first converting to a common color space
BOOL NSColorsAreEqual(NSColor *color1, NSColor *color2);
