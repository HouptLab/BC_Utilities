//
//  BCPatternUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 14/11/19.
//
//

#ifndef Xynk_BCPatternUtilities_h
#define Xynk_BCPatternUtilities_h

#import <Cocoa/Cocoa.h>
// --------------------------------------------------------------------------------
// drawing hatch and dot patterns into an NSImage of width x width size

// Hatch Patterns flags

typedef NS_OPTIONS(NSUInteger, BCFillPatternFlags) {
    
    kFillPatternSolid = 0, // return nil or solid image?
    
    kFillPatternInverted = 1 << 0, // if 0, stroke with fill color on background; if 1, stroke with background color on fill color background
    
    // type of fill pattern: hatch lines or stippled dots?
    kFillPatternLineHatch = 1 << 1, // fill with hatch Lines
    kFillPatternDotStipple = 1 << 2, // if 0, fill with stipple dots
    
    // flags used by both hatch lines and dots
    // density flags: spacing between lines/dots can be sparse, regular, or dense
    kFillPatternSparse  =  1 << 3,
    kFillPatternDense  =  1 << 4,
    // thickness flags: lines can be thin, regular or thick, dots can be small, regular, or large
    kFillPatternThinElements = 1 << 5,
    kFillPatternThickElements = 1 << 6,
    
    // flags used by hatch lines; these flags can be combined
    kFillPatternLinesTopLeft2BottomRight = 1 << 7, // diagonal: top left to bottom right
    kFillPatternLinesTopRight2BottomLeft =  1 << 8, // diagonal :top right to bottom left
    kFillPatternLinesVertical = 1 << 9,  //  vertical
    kFillPatternLinesHorizontal =  1 << 10,   // horizontal
    
    // flags used by dots
    kFillPatternStaggeredDots = 1 << 11 // if 1, then dots are staggered; if 0, then dots are in regular grid
    
    
};


// NOTE: rewrite these to return an NSColor directly?

/** constructs a hatched image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 
 the pattern of hatching is specified in a pattern mask of flags for diagonal lines (tl2br, tr2bl)
 or vertical lines (t2b) or horizontal lines (l2r). Cross hatching is achieved by setting multiple flags,
 i.e. tl2br & tr2bl gives a diagonal cross hatch...
 
 @param lineSpacing       distance between stripe lines (center-to-center) of the hatch
 @param strokeWidth width of lines in hatch in points
 @param strokeColor color of  lines
 @param fillColor   color of background fill
 @param patternMask type of pattern specified as a bit mask of tl2br, tr2bl, t2b,l2r
 
 @return returns an image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 */
NSImage *HatchPatternImage(CGFloat lineSpacing, CGFloat strokeWidth, NSColor *strokeColor, NSColor *fillColor, NSInteger patternMask);

// Dot Patterns
#define REGULAR_DOTS 0 // dots in a rectilinear grid, with width pts between each dot (both horz & vertical)
#define STAGGERED_DOTS 1 // note: if staggered, 2 dots in width x width square

/** constructs a stippled image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 
 if REGULAR_DOTS pattern is passed, then dots in a rectilinear grid, with width pts between each dot (both horz & vertical)
 if STAGGERED_DOTS pattern is selected, then 2 dots in width x width square
 
 @param dotSpacing       distance between dots (center-to-center) in the stipple pattern
 @param dotDiameter diameter of the dots in points
 @param strokeColor color of  dots (fill & stroke)
 @param fillColor   color of background fill
 @param staggered type of pattern: REGULAR_DOTS or STAGGERED_DOTS
 
 @return returns an image suitable for tiling, i.e., in a  [NSColor colorWithPatternImage:] call
 */

NSImage *DotPatternImage(CGFloat dotSpacing, CGFloat dotDiameter, NSColor *strokeColor, NSColor *fillColor, BOOL staggered);

/**
 given a pattern, return an nsimage which can be used to construct an NSColor
 note that if kFillPatternInvert is set, then the patternColor and backgroundColor are swapped.
 
 @param patternMask     a mask of BCFillPatternFlags specifying pattern; if kFillPatternSolid (0), then nil is return
 @param patternColor    the color for drawing the lines or dots
 @param backgroundColor the background color on which the lines or dots are drawn; can be nil (then lines/dots are drawn on clearColor background)
 
 @return an NSImage drawn with the given colors, or nil if kFillPatternSolid was passed as the pattern mask.
 */

NSImage *FillPatternImage(BCFillPatternFlags patternMask, NSColor *patternColor, NSColor *backgroundColor);

/**
 given a pattern, construct an NSColor based on that pattern, suitable for 
 filling an outline
 
 @param patternMask     a mask of BCFillPatternFlags specifying pattern; if kFillPatternSolid (0), then patternColor is returned as the fill color
 @param patternColor    the color for drawing the lines or dots
 @param backgroundColor the background color on which the lines or dots are drawn; can be nil (then lines/dots are drawn on clearColor background)
 
 @return an NSColor constructed from the given colors and patterns
 */

NSColor *FillColorWithPattern(BCFillPatternFlags patternMask, NSColor *patternColor, NSColor *backgroundColor);

NSArray *GetFillPatternArray(void);
NSInteger GetPatternArrayIndexByMatchingPattern(NSNumber *thePattern);

// --------------------------------------------------------------------------------
// STROKE DASH OR DOT PATTERNS

#define kNumDashPatterns 11

typedef NS_ENUM(NSInteger, BCStrokePatternType) {
    kSolidStroke = 0,
    kDotted = 1,        ///< ••••••
    kDottedSpaced = 2,      ///< • • • •
    kDottedTriple = 3,      ///< ••• ••• •••
    
    kDashedShort = 4,   ///< ----- (5 pixels long, 2 pixels space)
    kDashedShortSpaced = 5,   ///< - - - - - (double space)
    kDashedLong = 6,    ///< — — — — (10 pixels long, 4 pixels space),
    kDashedShortLong = 7,    ///< -—-—-—-—
    kDotDashShort = 8,  ///< •-•-•-•-
    kDotDashLong = 9,   ///< •—•—•—•—
    kDotDotDashDashLong = 10 ///< ••——••——••——
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

NSMenu *SetUpDashPickerMenu(CGFloat strokeWidth, NSColor *strokeColor, NSColor *backgroundColor);



#endif
