/*
 *  BCColorUtilities.m
 *  MindsEye
 *
 *  Created by Tom Houpt on 4/27/11.
 *  Copyright 2011 BehavioralCybernetics. All rights reserved.
 *
 */

#import "BCColorUtilities.h"


BOOL NSColorIsClearColor(NSColor *theColor) {
	
	// NOTE: always convert color to calibrated RGB before accessing the components
	NSColor *testColor = [theColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	
	if (0.0 == [testColor redComponent] &&
		0.0 == [testColor greenComponent] &&
		0.0 == [testColor blueComponent] &&
		0.0 == [testColor alphaComponent]
										) return YES;
	
	return NO;
		
}

NSColor *NSColorFromBCColorIndex(NSInteger bcColorIndex) {	
	
	// assigns clear color if bcCOlorIndex does not match a preset color
	NSColor *color;

	switch (bcColorIndex) {
			
		case NOFILLCOLOR: 
			color = [NSColor clearColor];
			break;
			
		case REDCOLOR: 
			color = [NSColor redColor];
			break;
			
		case MAROONCOLOR: 
			color = [NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0];
			color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
			break;
			
		case BROWNCOLOR:
			color = [NSColor brownColor];
			break;
			
		case ORANGECOLOR: 
			color = [NSColor orangeColor];
			break;
			
		case YELLOWCOLOR: 
			color = [NSColor yellowColor];
			break;
			
		case OLIVECOLOR: 
			color = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.0 alpha:1.0];
			color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

			break;
			
		case LIMECOLOR: 
			color = [NSColor greenColor];
			break;
			
		case GREENCOLOR: 
			color = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0];
			color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

			break;
			
			
		case TEALCOLOR: 
			color = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.5 alpha:1.0];
			color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

			break;
			
		case AQUACOLOR: 
			color = [NSColor cyanColor];
			break;
			
		case BLUECOLOR: 
			color = [NSColor blueColor];
			break;
			
		case NAVYCOLOR: 
			color = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.5 alpha:1.0];
			color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

			break;
			
		case FUSCHIACOLOR: 
			color = [NSColor magentaColor];
			break;
			
		case PURPLECOLOR: 
			color = [NSColor purpleColor];
			break;
			
		case WHITECOLOR: 
			color = [NSColor whiteColor];
			break;
			
		case SIVLERCOLOR:
			color = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
			color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

			break;
			
		case LIGHTGRAYCOLOR:
			color = [NSColor lightGrayColor];
			break;
			
			
		case GRAYCOLOR: 
			color = [NSColor grayColor];
			break;
			
		case DARKGRAYCOLOR:
			color = [NSColor darkGrayColor];
			break;
			
		case BLACKCOLOR:
			color = [NSColor blackColor];
			break;
			
		default:
			color =[NSColor clearColor];
	}
	
	
	// [color retain];
	return color;
	
	
}


NSInteger BCColorIndexFromNSColor(NSColor * theColor) {
	
	// returns NOFILLCOLOR if it can't find a match
	
	CGFloat red,blue,green, alpha;
	CGFloat test_red,test_blue,test_green, test_alpha;
	
	NSColor *matchColor;
	NSColor *testColor;
	
	
	if (NSColorIsClearColor(theColor)) return NOFILLCOLOR;
		
	// NOTE: always convert color to calibrated RGB before accessing the components
	matchColor = [theColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	[matchColor getRed:&red green:&green blue:&blue alpha:&alpha];
	
	int i;
	// skip over clear color (color index 0)
	
	for (i=1;i< COLORS_COUNT;i++) {
		
		testColor = NSColorFromBCColorIndex(i);
		
		// NOTE: always convert color to calibrated RGB before accessing the components
		testColor = [testColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		
		[testColor getRed:&test_red green:&test_green blue:&test_blue alpha:&test_alpha]; 		
		
		// ignore alpha, because we have a separate menu for opacity
		if (red == test_red && green == test_green && blue == test_blue) { return i; }
		
	} // next color
	
	return NOFILLCOLOR;  // couldn't find a match
	
	
}


CGColorRef CreateCGColorFromNSColor(NSColor *color) {
	
	if (nil == color) return NULL;
	
    NSColor *rgb = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat rgba[4];
    [rgb getComponents:rgba];
    return CGColorCreateGenericRGB(rgba[0], rgba[1], rgba[2], rgba[3]);
}

NSColor *CreateNSColorFromCGColor(CGColorRef color) {
	
	if (nil == color) return nil;
	NSColorSpace *cp = [[NSColorSpace alloc] initWithCGColorSpace:CGColorGetColorSpace(color)];
	const CGFloat *components = CGColorGetComponents(color);
	size_t componentCount = CGColorGetNumberOfComponents(color);
	return [NSColor colorWithColorSpace:cp components:components count:componentCount];
	
}


// a little helper routine to get color of enabled or disabled control

NSColor *enableColor(BOOL flag) {
    
    if (!flag) { return [NSColor disabledControlTextColor]; }
    return [NSColor controlTextColor];
}

	
	
NSColor *CreateNSColorFromRGBValues(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha ) {
    
    NSColor *color;
    
    color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    return color;
    
}

NSArray *GetSvgColorArray(void) {
    
    NSMutableArray *svgColorArray = [[NSMutableArray alloc] init];
 
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.000	, 	0.000	, 	0	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.000	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.184	, 	0.310	, 	0.310	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.412	, 	0.412	, 	0.412	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.439	, 	0.502	, 	0.565	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.502	, 	0.502	, 	0.502	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.467	, 	0.533	, 	0.600	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.663	, 	0.663	, 	0.663	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.753	, 	0.753	, 	0.753	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.827	, 	0.827	, 	0.827	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.863	, 	0.863	, 	0.863	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.961	, 	0.961	, 	0.961	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	1.000	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.647	, 	0.165	, 	0.165	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.545	, 	0.271	, 	0.075	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.627	, 	0.322	, 	0.176	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.824	, 	0.412	, 	0.118	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.804	, 	0.522	, 	0.247	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.737	, 	0.561	, 	0.561	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.957	, 	0.643	, 	0.376	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.824	, 	0.706	, 	0.549	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.871	, 	0.722	, 	0.529	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.855	, 	0.725	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.961	, 	0.871	, 	0.702	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.871	, 	0.678	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.545	, 	0.000	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.000	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.698	, 	0.133	, 	0.133	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.863	, 	0.078	, 	0.235	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.078	, 	0.576	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.271	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.804	, 	0.361	, 	0.361	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.388	, 	0.278	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.412	, 	0.706	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.498	, 	0.314	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.941	, 	0.502	, 	0.502	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.980	, 	0.502	, 	0.447	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.549	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.914	, 	0.588	, 	0.478	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.647	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.627	, 	0.478	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.714	, 	0.757	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.753	, 	0.796	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.894	, 	0.769	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.894	, 	0.882	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.722	, 	0.525	, 	0.043	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.855	, 	0.647	, 	0.125	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.843	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.933	, 	0.910	, 	0.667	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.894	, 	0.710	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	1.000	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	1.000	, 	0.941	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.392	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.502	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.333	, 	0.420	, 	0.184	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.502	, 	0.502	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.133	, 	0.545	, 	0.133	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.180	, 	0.545	, 	0.341	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.502	, 	0.502	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.420	, 	0.557	, 	0.137	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.125	, 	0.698	, 	0.667	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.235	, 	0.702	, 	0.443	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.196	, 	0.804	, 	0.196	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.561	, 	0.737	, 	0.561	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.741	, 	0.718	, 	0.420	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	1.000	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.604	, 	0.804	, 	0.196	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.980	, 	0.604	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	1.000	, 	0.498	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.486	, 	0.988	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.498	, 	1.000	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.565	, 	0.933	, 	0.565	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.678	, 	1.000	, 	0.184	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.596	, 	0.984	, 	0.596	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.941	, 	0.902	, 	0.549	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.000	, 	0.502	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.000	, 	0.545	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.000	, 	0.804	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.000	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.098	, 	0.098	, 	0.439	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.282	, 	0.239	, 	0.545	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.416	, 	0.353	, 	0.804	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.255	, 	0.412	, 	0.882	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.545	, 	0.545	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.482	, 	0.408	, 	0.933	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.275	, 	0.510	, 	0.706	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.118	, 	0.565	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.373	, 	0.620	, 	0.627	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.392	, 	0.584	, 	0.929	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.749	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.808	, 	0.820	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.282	, 	0.820	, 	0.800	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.400	, 	0.804	, 	0.667	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.251	, 	0.878	, 	0.816	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.529	, 	0.808	, 	0.922	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.690	, 	0.769	, 	0.871	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.529	, 	0.808	, 	0.980	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	1.000	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.678	, 	0.847	, 	0.902	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.690	, 	0.878	, 	0.902	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.686	, 	0.933	, 	0.933	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.498	, 	1.000	, 	0.831	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.294	, 	0.000	, 	0.510	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.502	, 	0.000	, 	0.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.502	, 	0.000	, 	0.502	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.545	, 	0.000	, 	0.545	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.580	, 	0.000	, 	0.827	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.780	, 	0.082	, 	0.522	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.000	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.541	, 	0.169	, 	0.886	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.600	, 	0.196	, 	0.800	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.729	, 	0.333	, 	0.827	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.576	, 	0.439	, 	0.859	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.859	, 	0.439	, 	0.576	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.855	, 	0.439	, 	0.839	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.933	, 	0.510	, 	0.933	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.867	, 	0.627	, 	0.867	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.847	, 	0.749	, 	0.847	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.902	, 	0.902	, 	0.980	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	1.000	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.000	, 	0.000	, 	0.000	, 	0	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.184	, 	0.310	, 	0.310	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.412	, 	0.412	, 	0.412	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.439	, 	0.502	, 	0.565	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.502	, 	0.502	, 	0.502	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.467	, 	0.533	, 	0.600	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.663	, 	0.663	, 	0.663	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.827	, 	0.827	, 	0.827	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.000	, 	1.000	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.992	, 	0.961	, 	0.902	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.980	, 	0.922	, 	0.843	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.922	, 	0.804	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.937	, 	0.835	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.980	, 	0.941	, 	0.902	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.961	, 	0.961	, 	0.863	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.961	, 	0.933	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.980	, 	0.980	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	1.000	, 	0.941	, 	0.961	, 	1	) 	];
    [svgColorArray addObject: 	CreateNSColorFromRGBValues(	0.980	, 	0.980	, 	0.824	, 	1	) 	];
    
    return svgColorArray;
    
}

NSArray *GetSvgColorNameArray(void) {
    
    NSMutableArray *svgColorNameArray = [[NSMutableArray alloc] init];
    
    [svgColorNameArray addObject:	@"clear”"	];
    [svgColorNameArray addObject:	@"black"	];
    [svgColorNameArray addObject:	@"darkslategray"	];
    [svgColorNameArray addObject:	@"dimgray"	];
    [svgColorNameArray addObject:	@"slategray"	];
    [svgColorNameArray addObject:	@"gray/grey"	];
    [svgColorNameArray addObject:	@"lightslategray"	];
    [svgColorNameArray addObject:	@"darkgray"	];
    [svgColorNameArray addObject:	@"silver"	];
    [svgColorNameArray addObject:	@"lightgray"	];
    [svgColorNameArray addObject:	@"gainsboro"	];
    [svgColorNameArray addObject:	@"whitesmoke"	];
    [svgColorNameArray addObject:	@"white"	];
    [svgColorNameArray addObject:	@"brown"	];
    [svgColorNameArray addObject:	@"saddlebrown"	];
    [svgColorNameArray addObject:	@"sienna"	];
    [svgColorNameArray addObject:	@"chocolate"	];
    [svgColorNameArray addObject:	@"peru"	];
    [svgColorNameArray addObject:	@"rosybrown"	];
    [svgColorNameArray addObject:	@"sandybrown"	];
    [svgColorNameArray addObject:	@"tan"	];
    [svgColorNameArray addObject:	@"burlywood"	];
    [svgColorNameArray addObject:	@"peachpuff"	];
    [svgColorNameArray addObject:	@"wheat"	];
    [svgColorNameArray addObject:	@"navajowhite"	];
    [svgColorNameArray addObject:	@"darkred"	];
    [svgColorNameArray addObject:	@"red"	];
    [svgColorNameArray addObject:	@"firebrick"	];
    [svgColorNameArray addObject:	@"crimson"	];
    [svgColorNameArray addObject:	@"deeppink"	];
    [svgColorNameArray addObject:	@"orangered"	];
    [svgColorNameArray addObject:	@"indianred"	];
    [svgColorNameArray addObject:	@"tomato"	];
    [svgColorNameArray addObject:	@"hotpink"	];
    [svgColorNameArray addObject:	@"coral"	];
    [svgColorNameArray addObject:	@"lightcoral"	];
    [svgColorNameArray addObject:	@"salmon"	];
    [svgColorNameArray addObject:	@"darkorange"	];
    [svgColorNameArray addObject:	@"darksalmon"	];
    [svgColorNameArray addObject:	@"orange"	];
    [svgColorNameArray addObject:	@"lightsalmon"	];
    [svgColorNameArray addObject:	@"lightpink"	];
    [svgColorNameArray addObject:	@"pink"	];
    [svgColorNameArray addObject:	@"bisque"	];
    [svgColorNameArray addObject:	@"mistyrose"	];
    [svgColorNameArray addObject:	@"darkgoldenrod"	];
    [svgColorNameArray addObject:	@"goldenrod"	];
    [svgColorNameArray addObject:	@"gold"	];
    [svgColorNameArray addObject:	@"palegoldenrod"	];
    [svgColorNameArray addObject:	@"moccasin"	];
    [svgColorNameArray addObject:	@"yellow"	];
    [svgColorNameArray addObject:	@"ivory"	];
    [svgColorNameArray addObject:	@"darkgreen"	];
    [svgColorNameArray addObject:	@"green"	];
    [svgColorNameArray addObject:	@"darkolivegreen"	];
    [svgColorNameArray addObject:	@"teal"	];
    [svgColorNameArray addObject:	@"forestgreen"	];
    [svgColorNameArray addObject:	@"seagreen"	];
    [svgColorNameArray addObject:	@"olive"	];
    [svgColorNameArray addObject:	@"olivedrab"	];
    [svgColorNameArray addObject:	@"lightseagreen"	];
    [svgColorNameArray addObject:	@"mediumseagreen"	];
    [svgColorNameArray addObject:	@"limegreen"	];
    [svgColorNameArray addObject:	@"darkseagreen"	];
    [svgColorNameArray addObject:	@"darkkhaki"	];
    [svgColorNameArray addObject:	@"lime"	];
    [svgColorNameArray addObject:	@"yellowgreen"	];
    [svgColorNameArray addObject:	@"mediumspringgreen"	];
    [svgColorNameArray addObject:	@"springgreen"	];
    [svgColorNameArray addObject:	@"lawngreen"	];
    [svgColorNameArray addObject:	@"chartreuse"	];
    [svgColorNameArray addObject:	@"lightgreen"	];
    [svgColorNameArray addObject:	@"greenyellow"	];
    [svgColorNameArray addObject:	@"palegreen"	];
    [svgColorNameArray addObject:	@"khaki"	];
    [svgColorNameArray addObject:	@"navy"	];
    [svgColorNameArray addObject:	@"darkblue"	];
    [svgColorNameArray addObject:	@"mediumblue"	];
    [svgColorNameArray addObject:	@"blue"	];
    [svgColorNameArray addObject:	@"midnightblue"	];
    [svgColorNameArray addObject:	@"darkslateblue"	];
    [svgColorNameArray addObject:	@"slateblue"	];
    [svgColorNameArray addObject:	@"royalblue"	];
    [svgColorNameArray addObject:	@"darkcyan"	];
    [svgColorNameArray addObject:	@"mediumslateblue"	];
    [svgColorNameArray addObject:	@"steelblue"	];
    [svgColorNameArray addObject:	@"dodgerblue"	];
    [svgColorNameArray addObject:	@"cadetblue"	];
    [svgColorNameArray addObject:	@"cornflowerblue"	];
    [svgColorNameArray addObject:	@"deepskyblue"	];
    [svgColorNameArray addObject:	@"darkturquoise"	];
    [svgColorNameArray addObject:	@"mediumturquoise"	];
    [svgColorNameArray addObject:	@"mediumaquamarine"	];
    [svgColorNameArray addObject:	@"turquoise"	];
    [svgColorNameArray addObject:	@"skyblue"	];
    [svgColorNameArray addObject:	@"lightsteelblue"	];
    [svgColorNameArray addObject:	@"lightskyblue"	];
    [svgColorNameArray addObject:	@"cyan"	];
    [svgColorNameArray addObject:	@"lightblue"	];
    [svgColorNameArray addObject:	@"powderblue"	];
    [svgColorNameArray addObject:	@"paleturquoise"	];
    [svgColorNameArray addObject:	@"aquamarine"	];
    [svgColorNameArray addObject:	@"indigo"	];
    [svgColorNameArray addObject:	@"maroon"	];
    [svgColorNameArray addObject:	@"purple"	];
    [svgColorNameArray addObject:	@"darkmagenta"	];
    [svgColorNameArray addObject:	@"darkviolet"	];
    [svgColorNameArray addObject:	@"mediumvioletred"	];
    [svgColorNameArray addObject:	@"magenta"	];
    [svgColorNameArray addObject:	@"blueviolet"	];
    [svgColorNameArray addObject:	@"darkorchid"	];
    [svgColorNameArray addObject:	@"mediumorchid"	];
    [svgColorNameArray addObject:	@"mediumpurple"	];
    [svgColorNameArray addObject:	@"palevioletred"	];
    [svgColorNameArray addObject:	@"orchid"	];
    [svgColorNameArray addObject:	@"violet"	];
    [svgColorNameArray addObject:	@"plum"	];
    [svgColorNameArray addObject:	@"thistle"	];
    [svgColorNameArray addObject:	@"lavender"	];
    [svgColorNameArray addObject:	@"aqua"	];
    [svgColorNameArray addObject:	@"nofill”"	];
    [svgColorNameArray addObject:	@"darkslategrey"	];
    [svgColorNameArray addObject:	@"dimgrey"	];
    [svgColorNameArray addObject:	@"slategrey"	];
    [svgColorNameArray addObject:	@"grey"	];
    [svgColorNameArray addObject:	@"lightslategrey"	];
    [svgColorNameArray addObject:	@"darkgrey"	];
    [svgColorNameArray addObject:	@"lightgrey"	];
    [svgColorNameArray addObject:	@"fuchsia"	];
    [svgColorNameArray addObject:	@"oldlace"	];
    [svgColorNameArray addObject:	@"antiquewhite"	];
    [svgColorNameArray addObject:	@"blanchedalmond"	];
    [svgColorNameArray addObject:	@"papayawhip"	];
    [svgColorNameArray addObject:	@"linen"	];
    [svgColorNameArray addObject:	@"beige"	];
    [svgColorNameArray addObject:	@"seashell"	];
    [svgColorNameArray addObject:	@"snow"	];
    [svgColorNameArray addObject:	@"lavenderblush"	];
    [svgColorNameArray addObject:	@"lightgoldenrodyellow"	];

    return svgColorNameArray;
}
NSDictionary *GetSvgColorDictionary(void) {
    
    // http://www.w3.org/TR/SVG/types.html#ColorKeywords
    
   // returns 148 objects: "clear" and 138 unique colors,
    // then 9 duplicate colors (with alternate names) + duplicate "nofill" (duplicate of "clear")
    
    
    NSArray *svgColorArray = GetSvgColorArray();
    NSArray *svgColorNameArray = GetSvgColorNameArray();
    
    NSDictionary *svgColorDictionary = [[NSDictionary alloc] initWithObjects:svgColorArray forKeys:svgColorNameArray];
    
    return svgColorDictionary;
}

NSColor *GetSvgColorByName(NSString *name) {
    
    NSDictionary *svgColorDictionary = GetSvgColorDictionary();
    NSColor *theColor;
    theColor = [svgColorDictionary objectForKey:name];
    if (nil == theColor) { return [NSColor blackColor]; }
    return theColor;
}

NSInteger GetSvgArrayIndexByMatchingColor(NSColor *theColor) {
    
NSColor *testColor = [theColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if (0.0 == [testColor alphaComponent]) {
        return 0;
    }
    
    NSArray *svgArray = GetSvgColorArray();
    
    NSUInteger i;

    // skip svgArray[0] which is clear color
    for (i = 1; i < [svgArray count]; i++) {
        
        NSColor *eachColor= [svgArray objectAtIndex:i];
        
        if ([testColor redComponent] == [eachColor redComponent]
            &&
            [testColor greenComponent] == [eachColor greenComponent]
            &&
            [testColor blueComponent] == [eachColor blueComponent]
            ) {
            
            // return [svgArray indexOfObject:eachColor];
            
            return i;
        }
        
    }
    
    // can't find the color, return -1 (no selection)
    return -1;
}






// ------------------------------------------------------------------
// adding support for NSColors in user defaults

	
@implementation NSUserDefaults(myColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey
{
    NSColor *theColor=nil;
    NSData *theData=[self dataForKey:aKey];
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}

@end

/* some NSData versions of some colors
darkslategrey = <040b7374 7265616d 74797065 6481e803 84014084 8484074e 53436f6c 6f720084 84084e53 4f626a65 63740085 84016301 84046666 6666837f 6a3c3e83 52b89e3e 8352b89e 3e0186>
red = <040b7374 7265616d 74797065 6481e803 84014084 8484074e 53436f6c 6f720084 84084e53 4f626a65 63740085 84016301 84046666 66660100 000186>
darkgray = <040b7374 7265616d 74797065 6481e803 84014084 8484074e 53436f6c 6f720084 84084e53 4f626a65 63740085 84016303 84026666 83abaaaa 3e0186>
 
 */


// compare 2 colors by first converting to a common color space
BOOL NSColorsAreEqual(NSColor *color1, NSColor *color2) {
    
    // NOTE: always convert color to calibrated RGB before accessing the components
	NSColor *testColor1 = [color1 colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    NSColor *testColor2 = [color2 colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	
	return ([testColor1 redComponent] == [testColor2 redComponent] &&
		[testColor1 greenComponent] == [testColor2 greenComponent] &&
		[testColor1 blueComponent] == [testColor2 blueComponent] &&
		[testColor1 alphaComponent] == [testColor2 alphaComponent]
            );
	
    
}




// Fluorophore colors
// try mapping maximum emisson of each fluorophore to an RGB value

// see http://www.fourmilab.ch/documents/specrend/



