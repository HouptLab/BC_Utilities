//
//  BCMshColorSpace.c
//  Xynk
//
//  Created by Tom Houpt on 14/3/6.
//
//

#include <stdio.h>

#include <math.h>


// source of algorithms:
// Moreland, K. Diverging Color Maps for Scientific Visualization (Expanded), Sandia National Laboratories
// http://en.wikipedia.org/wiki/Lab_color_space
// http://www.cs.rit.edu/~ncs/color/t_convert.html#XYZ%20to%20CIE%20L*a*b*%20(CIELAB)%20&%20CIELAB%20to%20XYZ


// r,g, and b vary from 0 to 1
typedef struct rgbtype {
    double r;
    double g;
    double b;
} RGBType;

// CIE XYZ color space
// X,Y,Z range from 0 to 100?
typedef struct xyztype {
    double X;
    double Y;
    double Z;
} XYZType;

// CIE L*a*b* color space
// L* varies from 0 to 100
// in theory: a* in +-500 and b* in +-200
typedef struct labtype {
    double L;
    double a;
    double b;
} LabType;

typedef struct mshtype {
    double M;
    double s;
    double h;
} MshType;

// Here refWhite.X,Y,Z = (Xn, Yn and Zn) are the tristimulus values of the reference white.
// D65 White point: X=95.047, Y=100.00, Z=108.883. source: http://en.wikipedia.org/wiki/Illuminant_D65
// "D65 corresponds roughly to a midday sun in Western Europe / Northern Europe"

#define  D65_WHITE_X 95.047
#define  D65_WHITE_Y 100.00
#define  D65_WHITE_Z 108.883

double eye_function(double t);

XYZType RGB2XYZ(RGBType rgb);
RGBType XYZ2RGB(XYZType xyz);

LabType XYZ2Lab(XYZType xyz);
XYZType Lab2XYZ(LabType lab);

MshType RGB2Msh(RGBType rgb);
RGBType Msh2RGB(MshType msh);

double RadianDifference(double x, double y);

double AdjustHue(MshType msh, double M);
RGBType InterpolateMshColor(RGBType rgb1, RGBType rgb2, double interp);
// usage: given 2 colors rgb1 and rgb2, if you want to find 100 gradiations in between those 2 colors,
// then iterate:  for (i=0; i<=1.0, i+= 0.01) { gradiation_color = InterpolateMshColor(rgb1, rgb2, i); }


//-------------------------------------------------------------------------------------

// Here refWhite.X,Y,Z = (Xn, Yn and Zn) are the tristimulus values of the reference white.
XYZType refWhite = {D65_WHITE_X, D65_WHITE_Y, D65_WHITE_Z};


double eye_function(double t) {
    // where f(t) = t^1/3      for t > 0.008856
    // f(t) = 7.787 * t + 16/116    otherwise

    if ( t > 0.008856) {
        return pow(t, 1.0/3.0);
    }

    return (7.787 * t + 16.0/116.0);
}




XYZType RGB2XYZ(RGBType rgb) {
    
    //    RGB values in a particular set of primaries can be transformed to and from CIE XYZ via a 3x3 matrix transform. These transforms involve tristimulus values, that is a set of three linear-light components that conform to the CIE color-matching functions. CIE XYZ is a special set of tristimulus values. In XYZ, any color is represented as a set of positive values.
    //    The range for valid R, G, B values is [0,1]. Note, this matrix has negative coefficients. Some XYZ color may be transformed to RGB values that are negative or greater than one. This means that not all visible colors can be produced using the RGB system.

    // source: http://www.cs.rit.edu/~ncs/color/t_convert.html#XYZ%20to%20CIE%20L*a*b*%20(CIELAB)%20&%20CIELAB%20to%20XYZ
    
    //    [ X ]   [  0.412453  0.357580  0.180423 ]   [ R ]
    //    [ Y ] = [  0.212671  0.715160  0.072169 ] * [ G ]
    //    [ Z ]   [  0.019334  0.119193  0.950227 ]   [ B ].
    
    XYZType xyz;

   // x = a*r+b*g + c*b
    
    xyz.X = 0.412453*rgb.r +  0.357580*rgb.g + 0.180423*rgb.b;
    xyz.Y = 0.212671*rgb.r +  0.715160*rgb.g + 0.072169*rgb.b;
    xyz.Z = 0.019334*rgb.r +  0.119193*rgb.g + 0.950227*rgb.b;
    
    return xyz;
    
}

RGBType XYZ2RGB(XYZType xyz) {
    
    // source: http://www.cs.rit.edu/~ncs/color/t_convert.html#XYZ%20to%20CIE%20L*a*b*%20(CIELAB)%20&%20CIELAB%20to%20XYZ
    
    //    [ R ]   [  3.240479 -1.537150 -0.498535 ]   [ X ]
    //    [ G ] = [ -0.969256  1.875992  0.041556 ] * [ Y ]
    //    [ B ]   [  0.055648 -0.204043  1.057311 ]   [ Z ].

    RGBType rgb;
    
    rgb.r =  3.240479*xyz.X + -1.537150*xyz.Y + -0.498535*xyz.Z;
    rgb.g = -0.969256*xyz.X +  1.875992*xyz.Y +  0.041556*xyz.Z;
    rgb.b =  0.055648*xyz.X + -0.204043*xyz.Y +  1.057311*xyz.Z;
    
    return rgb;
    
}



LabType XYZ2Lab(XYZType xyz) {

// source: http://www.cs.rit.edu/~ncs/color/t_convert.html#XYZ%20to%20CIE%20L*a*b*%20(CIELAB)%20&%20CIELAB%20to%20XYZ

// XYZ to CIE L*a*b* (CIELAB) & CIELAB to XYZ

// CIE 1976 L*a*b* is based directly on CIE XYZ and is an attampt to linearize the perceptibility of color differences. The non-linear relations for L*, a*, and b* are intended to mimic the logarithmic response of the eye. Coloring information is referred to the color of the white point of the system, subscript n.
    

// Here refWhite.X,Y,Z = (Xn, Yn and Zn) are the tristimulus values of the reference white.
    
    LabType  lab;
    
    if (xyz.Y/ refWhite.Y > 0.008856) {
        lab.L = 116 * pow((xyz.Y/ refWhite.Y),1.0/3.0) - 16;
    }
    else {
        lab.L = 903.3 * xyz.Y/ refWhite.Y;
    }

    lab.a = 500 * ( eye_function(xyz.X/ refWhite.X) - eye_function(xyz.Y/ refWhite.Y) );
    lab.b = 200 * ( eye_function(xyz.Y/ refWhite.Y) - eye_function(xyz.Z/ refWhite.Z) );
    
    return lab;
}

XYZType Lab2XYZ(LabType lab) {

// source: http://www.cs.rit.edu/~ncs/color/t_convert.html#XYZ%20to%20CIE%20L*a*b*%20(CIELAB)%20&%20CIELAB%20to%20XYZ
    
// Here refWhite.X,Y,Z = (Xn, Yn and Zn) are the tristimulus values of the reference white.

// The reverse transformation (for Y/Yn > 0.008856) is

    XYZType xyz;

    
    double P = (lab.L + 16) / 116;

    xyz.X = refWhite.X * pow(( P + lab.a / 500 ), 3);
    xyz.Y = refWhite.Y * pow(P,3);
    xyz.Z = refWhite.Z * pow(( P - lab.b / 200 ), 3);
    
    return xyz;

}



MshType RGB2Msh(RGBType rgb) {
    
    
    XYZType xyz;
    LabType lab;
    MshType msh;

    xyz = RGB2XYZ(rgb);
    lab = XYZ2Lab(xyz);
    
    msh.M = sqrt( lab.L*lab.L + lab.a*lab.a - lab.b*lab.b);
    msh.s = acos (lab.L/msh.M);
    msh.h = atan(lab.b/lab.a);
    
    return msh;
}

RGBType Msh2RGB (MshType msh) {
    
    XYZType xyz;
    LabType lab;
    RGBType rgb;
    
    lab.L = msh.M * cos (msh.s);
    lab.a = msh.M * sin (msh.s) * cos (msh.h);
    lab.b = msh.M * sin (msh.s) * sin (msh.h);
    
    xyz = Lab2XYZ(lab);
    rgb = XYZ2RGB(xyz);
    
    return rgb;
    
}


double RadianDifference(double x, double y) {
    
    return (atan2(sin(x-y), cos(x-y)));
    
}
double AdjustHue(MshType sat, double Munsat) {
    
// Function to provide an adjusted hue when interpolating to an unsaturated color in Msh space.
    
    
    if (sat.M >= Munsat) {
        // Best we can do
        return sat.h;
    }
    double hSpin = sat.s * sqrt( (Munsat * Munsat) - (sat.M * sat.M) )/ (sat.M * sin(sat.s));

    if (sat.h > -1.0 * M_PI/ 3.0) {
        // Spin away from purple
        return (sat.h + hSpin);
    }
    // else
    
    return (sat.h - hSpin);

}

RGBType InterpolateMshColor(RGBType rgb1, RGBType rgb2, double interp) {
    
    // Interpolation algorithm to automatically create continuous diverging color maps
    // interp is interpolation factor between 0.0 (rgb1) and 1.0 (rgb2)
    
    // The InterpolateColor algorithm works as follows. The colors are first converted to Msh.2 To enforce a diverging color map, white is added between the two control points (lines 3–9). The middle white points is not added if either color is already unsaturated (indicating that there is already a control point for the white part of the diverging color map) or if the angular difference between the two hue orientations (computed by RadDiff) is small (which would mean that both sides of the diverging color map would be roughly the same color).3 If either control point is unsaturated, its hue is adjusted (lines 10–13) using the AdjustHue function in Figure 11. Finally, the two Msh colors are linearly interpolated (line 14). The result is converted back to RGB and returned.
    
    MshType msh1 = RGB2Msh(rgb1);
    MshType msh2 = RGB2Msh(rgb2);
    
    MshType mid;
    RGBType rgb;

    // If points saturated and distinct, place white in middle
    if ( (msh1.s > 0.05) || (msh2.s > 0.05) || (RadianDifference(msh1.h, msh2.h) > M_PI )) {
        mid.M = fmax(fmax(msh1.M,msh2.M), 88);
    }
    
    if (interp < 0.5) {
        msh2.M = mid.M;
        msh2.s = 0;
        msh2.h = 0;
        interp = 2*interp;
    }
    else {
        msh1.M = mid.M;
        msh1.s = 0;
        msh1.h = 0;
        interp = 2*interp - 1;
    }
 
    // Adjust hue of unsaturated colors
    if ((msh1.s < 0.05) || (msh2.s >0.05) ) {
        msh1.h = AdjustHue(msh2, msh1.M);
    }
    else if ((msh2.s < 0.05) || (msh1.s > 0.05)) {
        msh2.h = AdjustHue(msh1, msh2.M);
    }

    // Linear interpolation on adjusted control points
    //    {Mmid, smid, hmid} ← (1 − interp){M1, s1, h1} + interp{M2, s2, h2}
    //    return Msh2RGB({Mmid, smid, hmid})

    mid.M = (1- interp) * msh1.M + interp * msh2.M;
    mid.s = (1- interp) * msh1.s + interp * msh2.s;
    mid.h = (1- interp) * msh1.h + interp * msh2.h;

    rgb = Msh2RGB(mid);
    return rgb;
    
}