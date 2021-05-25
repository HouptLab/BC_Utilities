/*
 *  BCColorUtilities.h
 *  MindsEye
 *
 *  Created by Tom Houpt on 4/27/11.
 *  Copyright 2011 BehavioralCybernetics LLC. All rights reserved.
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

NSColor * NSColorFromHexValuesString(NSString *hexValues);
NSString *HexValuesStringFromNSColor(NSColor *theColor);
// converts strings in format like @"#ffffff<alpha>" or @"fff<alpha>" (alpha characters are optional...


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


// compare 2 colors by first converting to a common color space
BOOL NSColorsAreEqual(NSColor *color1, NSColor *color2);

@interface NSColor (BrightnessExtensions)

-(NSColor *)lighter:(CGFloat) factor;
-(NSColor *)darker:(CGFloat) factor;
@end
