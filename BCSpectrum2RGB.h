//
//  BCSpectrum2RGB.h
//  Xynk
//
//  Created by Tom Houpt on 13/6/12.
//
//

#ifndef Xynk_BCSpectrum2RGB_h
#define Xynk_BCSpectrum2RGB_h

/*
 Colour Rendering of Spectra
 
 by John Walker
 http://www.fourmilab.ch/
 
 Last updated: March 9, 2003
 
 This program is in the public domain.
 
 For complete information about the techniques employed in
 this program, see the World-Wide Web document:
 
 http://www.fourmilab.ch/documents/specrend/
 
 The xyz_to_rgb() function, which was wrong in the original
 version of this program, was corrected by:
 
 Andrew J. S. Hamilton 21 May 1999
 Andrew.Hamilton@Colorado.EDU
 http://casa.colorado.edu/~ajsh/
 
 who also added the gamma correction facilities and
 modified constrain_rgb() to work by desaturating the
 colour by adding white.
 
 A program which uses these functions to plot CIE
 "tongue" diagrams called "ppmcie" is included in
 the Netpbm graphics toolkit:
 http://netpbm.sourceforge.net/
 (The program was called cietoppm in earlier
 versions of Netpbm.)
 
 */

/* A colour system is defined by the CIE x and y coordinates of
 its three primary illuminants and the x and y coordinates of
 the white point. */

struct colourSystem {
    char *name;     	    	    /* Colour system name */
    double xRed, yRed,	    	    /* Red x, y */
    xGreen, yGreen,  	    /* Green x, y */
    xBlue, yBlue,    	    /* Blue x, y */
    xWhite, yWhite,  	    /* White point x, y */
    gamma;   	    	    /* Gamma correction for system */
};



/*  	    	    	    UPVP_TO_XY
 
 Given 1976 coordinates u', v', determine 1931 chromaticities x, y
 
 */

void upvp_to_xy(double up, double vp, double *xc, double *yc);

/*  	    	    	    XY_TO_UPVP
 
 Given 1931 chromaticities x, y, determine 1976 coordinates u', v'
 
 */


void xy_to_upvp(double xc, double yc, double *up, double *vp);


/*                             XYZ_TO_RGB
 
 Given an additive tricolour system CS, defined by the CIE x
 and y chromaticities of its three primaries (z is derived
 trivially as 1-(x+y)), and a desired chromaticity (XC, YC,
 ZC) in CIE space, determine the contribution of each
 primary in a linear combination which sums to the desired
 chromaticity.  If the  requested chromaticity falls outside
 the Maxwell  triangle (colour gamut) formed by the three
 primaries, one of the r, g, or b weights will be negative.
 
 Caller can use constrain_rgb() to desaturate an
 outside-gamut colour to the closest representation within
 the available gamut and/or norm_rgb to normalise the RGB
 components so the largest nonzero component has value 1.
 
 */

void xyz_to_rgb( struct colourSystem *cs,
                double xc, double yc, double zc,
                double *r, double *g, double *b);


/*                            INSIDE_GAMUT
 
 Test whether a requested colour is within the gamut
 achievable with the primaries of the current colour
 system.  This amounts simply to testing whether all the
 primary weights are non-negative. */

int inside_gamut(double r, double g, double b);

/*                          CONSTRAIN_RGB
 
 If the requested RGB shade contains a negative weight for
 one of the primaries, it lies outside the colour gamut
 accessible from the given triple of primaries.  Desaturate
 it by adding white, equal quantities of R, G, and B, enough
 to make RGB all positive.  The function returns 1 if the
 components were modified, zero otherwise.
 
 */

int constrain_rgb(double *r, double *g, double *b);

/*                          GAMMA_CORRECT_RGB
 
 Transform linear RGB values to nonlinear RGB values. Rec.
 709 is ITU-R Recommendation BT. 709 (1990) ``Basic
 Parameter Values for the HDTV Standard for the Studio and
 for International Programme Exchange'', formerly CCIR Rec.
 709. For details see
 
 http://www.poynton.com/ColorFAQ.html
 http://www.poynton.com/GammaFAQ.html
 */

void gamma_correct(const struct colourSystem *cs, double *c);
void gamma_correct_rgb(const struct colourSystem *cs, double *r, double *g, double *b);

/*  	    	    	    NORM_RGB
 
 Normalise RGB components so the most intense (unless all
 are zero) has a value of 1.
 
 */

void norm_rgb(double *r, double *g, double *b);

/*                          SPECTRUM_TO_XYZ
 
 Calculate the CIE X, Y, and Z coordinates corresponding to
 a light source with spectral distribution given by  the
 function SPEC_INTENS, which is called with a series of
 wavelengths between 380 and 780 nm (the argument is
 expressed in meters), which returns emittance at  that
 wavelength in arbitrary units.  The chromaticity
 coordinates of the spectrum are returned in the x, y, and z
 arguments which respect the identity:
 
 x + y + z = 1.
 */

void spectrum_to_xyz(double (*spec_intens)(double wavelength),
                     double *x, double *y, double *z);


/*                            BB_SPECTRUM
 
 Calculate, by Planck's radiation law, the emittance of a black body
 of temperature bbTemp at the given wavelength (in metres).  */
double bb_spectrum(double wavelength);



/*				INTENSITY_AT_WAVELENGTH
 return intensity at given wavelength;
 wavelength is from 380 nm to 780.1 nm in 5 nm increments
 this function is passed to spectrum_to_xyz as data source for spectrum
 */
double intensity_at_wavelength(double wavelength);

void spectrum2RGB(double *red, double *green, double *blue);

#endif
