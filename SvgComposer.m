//
//  SvgComposer.m
//  Xynk
//
//  Created by Tom Houpt on 12/12/8.
//
//

#import "SvgComposer.h"

@implementation SvgComposer

// Pict to SVG Library by Chuck Houpt, Copyright 2001
// May be copied under the terms of the GPL (http://www.gnu.org/licenses/gpl.html)

// converted to an Objective-C class by Tom Houpt, Copyright 2012


const bool comment = false;

// routines which generate text representations of SVG objects
// (i.e. which are objects of SVG commands)
// e.g. a point "{h,v}" that MoveTo moves to...

-(NSString *)stringFromRGBColor:(const RGBColor *)color; {
	
    double r = 100.0*color.red/USHRT_MAX;
	double g = 100.0*color.green/USHRT_MAX;
	double b = 100.0*color.blue/USHRT_MAX;
	
    return o << "rgb(" << r << "%, " << g << "%, " << b << "%)";
}

-(NSString *)stringFromPoint:(NSPoint *)p; {
	return o << "{"<< p.h << ", " << p.v << "}";
}

-(NSString *)stringFromRect:(NSRect); {
	return o << "{" << r.top << ", " << r.left << ", " << r.bottom << ", " << r.right << "}";
}


#if 0

-(NSString *)stringFromForegroundColor; {
    
// put foreground color into a string
	static char s[100];
	
	sprintf(s, "rgb(%g%%, %g%%, %g%%)",
            100.0*((CGrafPtr)qd.thePort)->rgbFgColor.red/65535.0,
            100.0*((CGrafPtr)qd.thePort)->rgbFgColor.green/65535.0,
            100.0*((CGrafPtr)qd.thePort)->rgbFgColor.blue/65535.0);
	
	return s;
}
#endif

// write text as UTF8 to the output stream o
// TAH - don't think we need this under OSX
//static void WriteUTF8(ostream &o, Ptr textBuf, short byteCount)
//{
//	Str255 fontName;
//    TextEncoding portEncoding;
//    TextEncoding utf8Encoding;
//    ByteCount actualInputLength, actualOutputLength;
//    TECObjectRef port2utf8Converter;
//    unsigned char oBuf[1024];
//    
//	GetFontName(GetPortTextFont(GetQDGlobalsThePort()), fontName);
//    
//    UpgradeScriptInfoToTextEncoding	(smCurrentScript,
//                                     kTextLanguageDontCare,
//                                     kTextRegionDontCare,
//                                     fontName,
//                                     &portEncoding);
//    
//    
//    utf8Encoding = CreateTextEncoding (
//                                       kTextEncodingUnicodeDefault,
//                                       kTextEncodingDefaultVariant,
//                                       //GetTextEncodingFormat(kUnicodeUTF8Format));
//                                       kUnicodeUTF8Format);
//    
//    TECCreateConverter (
//                        &port2utf8Converter,
//                        portEncoding,
//                        utf8Encoding);
//    
//    TECConvertText(
//                   port2utf8Converter,
//                   (unsigned char *)textBuf,
//                   byteCount,
//                   &actualInputLength,
//                   oBuf,
//                   1024,
//                   &actualOutputLength);
//    
//    TECDisposeConverter(port2utf8Converter);
//    
//    o.write((char *)oBuf, actualOutputLength);
//}


-(void)drawText:(NSString *)textString atNumer:(NSPoint)numer andDenom:(NSPoint)denom {
//static pascal void svgText(short byteCount, const void *textBuf, Point numer, Point denom)
    
    
    //	SVGPort *svg = (SVGPort *)qd.thePort;
	
	if (comment) {
        *svgo << "<!-- Text("
        << byteCount << ", " << ((void *)textBuf) << ", " << numer << ", " << denom
        << ") -->" << endl;
	}
	
	Point penLoc;
	RGBColor fgColor;
	Str255 fontName;
	char cFontName[256];
	
	GetPortPenLocation(GetQDGlobalsThePort(), &penLoc);
	GetPortForeColor(GetQDGlobalsThePort(), &fgColor);
	GetFontName(GetPortTextFont(GetQDGlobalsThePort()), fontName);
	strncpy(cFontName, (const char *)(fontName+1), fontName[0]);
	cFontName[fontName[0]] = 0;
	
	*svgo << "<text "
	<< "x=\"" << penLoc.h << "\" y=\"" << penLoc.v << "\" "
	<< "style=\"font-family:" << cFontName
	<< "; font-size:" << GetPortTextSize(GetQDGlobalsThePort())
	<< "; fill:" << fgColor
	<< "\">" << endl;
	WriteUTF8(*svgo, (char *)textBuf, byteCount);
    //	svgo->write(textBuf, byteCount);
	*svgo << endl << "</text>" << endl;
	
#if 0
	printf("<!-- Text(%d, %p, {%d, %d}, {%d, %d}) -->\n", byteCount, textBuf, numer.h, numer.v, denom.h, denom.v);
	printf("<text x=\"%d\" y=\"%d\" style=\"font-size:%d; fill:%s\">\n",
           qd.thePort->pnLoc.h, qd.thePort->pnLoc.v,
           qd.thePort->txSize, fgcolor());
	fwrite(textBuf, 1, byteCount, stdout);
	printf("\n</text>\n");
#endif
}


static pascal void lineTo:(NSPoint *)newPt toString:(NSMutableString *)svgo; {
	
    if (comment) {
        *svgo << "<!-- Line(" << newPt << ") -->" << endl;
	}
    
	Point penLoc, penSize;
	RGBColor fgColor;
	GetPortPenLocation(GetQDGlobalsThePort(), &penLoc);
	GetPortPenSize(GetQDGlobalsThePort(), &penSize);
	GetPortForeColor(GetQDGlobalsThePort(), &fgColor);
	
	if (penLoc.h != newPt.h || penLoc.v != newPt.v) {
		*svgo << "<line x1=\"" << penLoc.h+(penSize.h-1)/2
		<< "\" y1=\"" << penLoc.v+(penSize.v-1)/2 << "\" "
		<< "x2=\"" << newPt.h+(penSize.h-1)/2 << "\" y2=\"" << newPt.v+(penSize.v-1)/2 << "\" "
		<< "style=\"stroke:" << fgColor
		<< "; stroke-width:" << penSize.h << "\" />" << endl;
	}
    
#if 0
	printf("<!-- Line({%d, %d}) -->\n", newPt.h, newPt.v);
	if (qd.thePort->pnLoc.h != newPt.h || qd.thePort->pnLoc.v != newPt.v) {
		printf("<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" style=\"stroke:%s; stroke-width:%d\" />\n",
               qd.thePort->pnLoc.h+(qd.thePort->pnSize.h-1)/2,
               qd.thePort->pnLoc.v+(qd.thePort->pnSize.v-1)/2,
               newPt.h+(qd.thePort->pnSize.h-1)/2,
               newPt.v+(qd.thePort->pnSize.v-1)/2,
               fgcolor(), qd.thePort->pnSize.h);
	}
    //	StdLine(p);
    //	SetPort(FrontWindow());
    //	LineTo(p.h, p.v);
    //	SetPort((GrafPtr)&myport);
    #endif
}

static const char *GrafVerbName(GrafVerb verb)
{
	const char *name;
	
	switch (verb) {
#define NAMECASE(symbol)	case symbol: name = #symbol; break;
            NAMECASE(kQDGrafVerbFrame);
            NAMECASE(kQDGrafVerbPaint);
            NAMECASE(kQDGrafVerbErase);
            NAMECASE(kQDGrafVerbInvert);
            NAMECASE(kQDGrafVerbFill);
        default: name = "<Unknown GrafVerb>"; break;
#undef NAMECASE
	}
    
	return name;
}

static void GrafVerbToStyle(ostream &o, GrafVerb verb)
{
	RGBColor fgColor, bkColor;
	
	GetPortForeColor(GetQDGlobalsThePort(), &fgColor);
	GetPortBackColor(GetQDGlobalsThePort(), &bkColor);
	
	switch (verb) {
        case kQDGrafVerbFrame:
            o << "fill:none; stroke:" << fgColor;
            break;
        case kQDGrafVerbPaint:
            o << "fill:" << fgColor << "; stroke:" << fgColor;
            break;
        case kQDGrafVerbFill:
            o << "fill:" << fgColor << "; stroke:none";
            break;
        case kQDGrafVerbErase:
            o << "fill:" << bkColor << "; stroke:" << bkColor;
            break;
        case kQDGrafVerbInvert:
        default:
            o << "fill:unknown; stroke: unknown";
            break;
	}
    
}

void drawRect:(NSRect)r withVerb:(GrafVerb)verb; {
    
	if (comment) {
        *svgo << "<!-- Rect(" << GrafVerbName(verb) << ", " << r << ") -->" << endl;
	}
    
	*svgo << "<rect x=\"" << r->left << "\" y=\"" << r->top
	<< "\" width=\"" <<  r->right-r->left-1 << "\" height=\"" << r->bottom-r->top-1 << "\" style =\"";
	
	GrafVerbToStyle(*svgo, verb);
#if 0
	switch (verb) {
        case kQDGrafVerbFrame:
            *svgo << "fill:none; stroke:" << ((CGrafPtr)qd.thePort)->rgbFgColor;
            break;
        case kQDGrafVerbPaint:
            *svgo << "fill:" << ((CGrafPtr)qd.thePort)->rgbFgColor << "; stroke:" << ((CGrafPtr)qd.thePort)->rgbFgColor;
            break;
        case kQDGrafVerbFill:
            *svgo << "fill:" << ((CGrafPtr)qd.thePort)->rgbFgColor << "; stroke:none";
            break;
        case kQDGrafVerbErase:
            *svgo << "fill:" << ((CGrafPtr)qd.thePort)->rgbBgColor << "; stroke:" << ((CGrafPtr)qd.thePort)->rgbBgColor;
            break;
        case kQDGrafVerbInvert:
        default:
            *svgo << "fill:unknown; stroke: unknown";
            break;
	}
#endif
	
	Point penSize;
	GetPortPenSize(GetQDGlobalsThePort(), &penSize);
	
	*svgo << "; stroke-width:" << penSize.h << "\" />" << endl;
	
#if 0
	const char *fill, *stroke;
	
	switch (verb) {
        case kQDGrafVerbFrame:
            fill = "none"; stroke = fgcolor();
            break;
        case kQDGrafVerbPaint:
            fill = stroke = fgcolor();
            break;
        case kQDGrafVerbFill:
            fill = fgcolor(); stroke = "none";
            break;
        case kQDGrafVerbErase:
            
        case kQDGrafVerbInvert:
        default:
            fill = "unknown"; stroke = "unknown";
            break;
	}
	
	printf("<!-- Rect(%s, {%d, %d, %d, %d}) -->\n", GrafVerbName(verb), r->top, r->left, r->bottom, r->right);
	printf("<rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\" style=\"fill:%s; stroke:%s; stroke-width:%d\" />\n",
           r->left, r->top, r->right-r->left, r->bottom-r->top,
           fill, stroke, qd.thePort->pnSize.h);
#endif
}

static pascal void svgRRect(GrafVerb verb, const Rect *r, short ovalWidth, short ovalHeight)
{
	if (comment) {
        *svgo << "<!-- RRect(" << GrafVerbName(verb) << ", " << r << ", "
        << ovalWidth << ", " << ovalHeight << ") -->" << endl;
	}
    //	printf("<rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\" rx=\"%d\" ry=\"%d\" style=\"fill:none\" />\n",
    //			r->left, r->top, r->right-r->left, r->bottom-r->top, ovalWidth, ovalHeight);
}


static pascal void svgOval(GrafVerb verb, const Rect *r)
{
	if (comment) {
        *svgo << "<!-- Oval(" << GrafVerbName(verb) << ", " << r << ") -->" << endl;
	}
    
	*svgo << "<ellipse cx=\"" << (r->left+r->right)/2 << "\" cy=\"" << (r->top+r->bottom)/2
	<< "\" rx=\"" << (r->right-r->left)/2 << "\" ry=\"" << (r->bottom-r->top)/2 << "\" style=\"";
	
	GrafVerbToStyle(*svgo, verb);
    
	Point penSize;
	GetPortPenSize(GetQDGlobalsThePort(), &penSize);
    
	*svgo << "; stroke-width:" << penSize.h << "\" />" << endl;
}

static pascal void svgArc(GrafVerb verb, const Rect *r, short startAngle, short arcAngle)
{
	if (comment) {
        *svgo << "<!-- Arc(" << GrafVerbName(verb) << ", " << r
        << ", " << startAngle << ", " << arcAngle << ") -->" << endl;
	}
}

static pascal void svgPoly(GrafVerb verb, PolyHandle poly)
{
	if (comment) {
        *svgo << "<!-- Poly(" << GrafVerbName(verb) << ", " << poly << ") -->" << endl;
	}
	
	*svgo << "<polygon style=\"";
	
	GrafVerbToStyle(*svgo, verb);
	
	Point penSize;
	GetPortPenSize(GetQDGlobalsThePort(), &penSize);
    
	*svgo << "; stroke-width:" << penSize.h << "\" points=\"";
    
	short l = ((*poly)->polySize - sizeof(short) - sizeof(Rect))/sizeof(Point);
	for (short i = 0; i <l; i++, *svgo << " ") {
		*svgo << (*poly)->polyPoints[i].h << "," << (*poly)->polyPoints[i].v;
	}
    
	*svgo << "\" />" << endl;
	
    /*
     <polygon style="fill:lime; stroke:blue; stroke-width:10"
     points="850,75  958,137.5 958,262.5
     850,325 742,262.6 742,137.5" />
     */
}

static pascal void svgRgn(GrafVerb verb, RgnHandle rgn)
{
	if (comment) {
        *svgo << "<!-- Rgn(" << GrafVerbName(verb) << ", " << rgn << ") -->" << endl;
	}
}

static const char *ModeName(short mode)
{
	const char *name;
    
	switch (mode) {
#define NAMECASE(symbol)	case symbol: name = #symbol; break;
            NAMECASE(srcCopy);
            NAMECASE(srcOr);
            NAMECASE(srcXor);
            NAMECASE(srcBic);
            NAMECASE(notSrcCopy);
            NAMECASE(notSrcOr);
            NAMECASE(notSrcXor);
            NAMECASE(notSrcBic);
            NAMECASE(patCopy);
            NAMECASE(patOr);
            NAMECASE(patXor);
            NAMECASE(patBic);
            NAMECASE(notPatCopy);
            NAMECASE(notPatOr);
            NAMECASE(notPatXor);
            NAMECASE(notPatBic);
            NAMECASE(grayishTextOr);
            NAMECASE(hilitetransfermode);
            NAMECASE(blend);
            NAMECASE(addPin);
            NAMECASE(addOver);
            NAMECASE(subPin);
            NAMECASE(addMax);
            NAMECASE(subOver);
            NAMECASE(adMin);
            NAMECASE(ditherCopy);
            NAMECASE(transparent);
        default: name = "<Unknown mode>"; break;
#undef NAMECASE
	}
	
	return name;
}

static pascal void svgBits(const BitMap *srcBits, const Rect *srcRect, const Rect *dstRect, short mode, RgnHandle maskRgn)
{
	if (comment) {
        *svgo << "<!-- Bits(" << srcBits << ", " << srcRect << ", " << dstRect << ", "
        << ModeName(mode) << ", " << maskRgn << ") -->" << endl;
	}
}

static const char *KindName(short kind)
{
	const char *name;
    
	switch (kind) {
        case 150: name = "TextBegin"; break;
        case 151: name = "TextEnd"; break;
        case 152: name = "StringBegin"; break;
        case 153: name = "StringEnd"; break;
        case 154: name = "TextCenter"; break;
        case 155: name = "LineLayoutOff"; break;
        case 156: name = "LineLayoutOn"; break;
        case 157: name = "ClientLineLayout"; break;
            
        case 160: name = "PolyBegin"; break;
        case 161: name = "PolyEnd"; break;
        case 163: name = "PolyIgnore"; break;
        case 164: name = "PolySmooth"; break;
        case 165: name = "PolyClose"; break;
            
        case 200: name = "RotateBegin"; break;
        case 201: name = "RotateEnd"; break;
        case 202: name = "RotateCenter"; break;
            
        case 180: name = "DashedLine"; break;
        case 181: name = "DashedStop"; break;
        case 182: name = "SetLineWidth"; break;
            
        case 190: name = "PostScriptBegin"; break;
        case 191: name = "PostScriptEnd"; break;
        case 192: name = "PostScriptHandle"; break;
        case 193: name = "PostScriptFile"; break;
        case 194: name = "TextIsPostScript"; break;
        case 195: name = "ResourcePS"; break;
        case 196: name = "PSBeginNoSave"; break;
            
        case 210: name = "FormsPrinting"; break;
        case 211: name = "EndFormsPrinting"; break;
            
        case 220: name = "CMBeginProfile"; break;
        case 221: name = "CMEndProfile"; break;
        case 222: name = "CMEnableMatching"; break;
        case 223: name = "CMDisableMatching"; break;
        default: name = "<Unknown Comment Kind>"; break;
	}
	
	return name;
    
}

static pascal void svgComment(short kind, short dataSize, Handle dataHandle)
{
	if (comment) {
        *svgo << "<!-- Comment(" << KindName(kind) << ", " << dataSize << ", " << dataHandle << ") -->" << endl;
	}
}

static pascal short svgTxMeas(short byteCount, const void *textAddr, Point *numer, Point *denom, FontInfo *info)
{
	if (comment) {
        *svgo << "<!-- TxMeas(" << byteCount << ", " << ((char *)textAddr) << ", " <<
        numer << ", " << denom << ", " << info << ") -->" << endl;
	}
	return StdTxMeas(byteCount, textAddr, numer, denom, info);
}

#if 0
static pascal void svgGetPic(Ptr dataPtr, short byteCount)
{
}

static pascal void svgPutPic(Ptr dataPtr, short byteCount)
{
}

static pascal void *svgopcode(Rect *fromRect, Rect *toRect, short opcode, short version)
{
}

static OSStatus svgStdGlyphs(void *dataStream, ByteCount size)
{
}

static pascal void svgJShieldCursor(short left, short top, short right, short bottom)
{
}
#endif



void Pict2SVG(ConstStr255Param Name, PicHandle p, ostream *o);
void Pict2SVG(ConstStr255Param Name, PicHandle p, ostream *o)
{
	svgo = o;
	Rect r = {0,0,500,500};
	CQDProcs procs;
	CQDProcs *savedprocs;
    QDTextUPP 						svgTextUPP = NewQDTextUPP(svgText);
    QDLineUPP 						svgLineUPP = NewQDLineProc(svgLine);
    QDRectUPP 						svgRectUPP = NewQDRectProc(svgRect);
    QDRRectUPP 						svgRRectUPP = NewQDRRectProc(svgRRect);
    QDOvalUPP 						svgOvalUPP = NewQDOvalProc(svgOval);
    QDArcUPP 						svgArcUPP = NewQDArcProc(svgArc);
    QDPolyUPP 						svgPolyUPP = NewQDPolyProc(svgPoly);
    QDRgnUPP 						svgRgnUPP = NewQDRgnProc(svgRgn);
    QDBitsUPP 						svgBitsUPP = NewQDBitsProc(svgBits);
    QDCommentUPP 					svgCommentUPP = NewQDCommentProc(svgComment);
    QDTxMeasUPP 					svgTxMeasUPP = NewQDTxMeasProc(svgTxMeas);
#if 0
    QDGetPicUPP 					svgGetPicUPP;
    QDPutPicUPP 					svgPutPicUPP;
    QDOpcodeUPP 					svgOpcodeUPP;
    UniversalProcPtr 				svgNewUPP;					/* this is the StdPix bottleneck -- see ImageCompression.h */
    QDStdGlyphsUPP 					svgGlyphsUPP;					/* was newProc2; now used in Unicode text drawing */
    QDPrinterStatusUPP 				svgPrinterStatusUPP;			/* was newProc3;  now used to communicate status between Printing code and System imaging code */
#endif
    
    PictInfo info;
    
    
    *svgo
    << "<?xml version=\"1.0\" standalone=\"no\"?>" << endl
    << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 20000303 Stylable//EN\"" << endl
    << "  \"http://www.w3.org/TR/2000/03/WD-SVG-20000303/DTD/svg-20000303-stylable.dtd\">" << endl;
    
    
    GetPictInfo(p, &info, 0, 0, 0, 0);
    *svgo
    << "<svg width=\"" << (info.sourceRect.right-info.sourceRect.left)/Fix2X(info.hRes)
    << "in\" height=\"" << (info.sourceRect.bottom-info.sourceRect.top)/Fix2X(info.vRes)
    << "in\" viewBox=\"" << info.sourceRect.left << " " << info.sourceRect.top << " "
    << info.sourceRect.right << " " << info.sourceRect.bottom << "\">" << endl; 
    
    char cName[256];
    strncpy(cName, (const char *)(Name+1), Name[0]);
    cName[Name[0]] = 0;
    
    *svgo
    << "  <desc>" << endl
    << cName << endl
    << "  </desc>" << endl
    << "  <g>" << endl;
    
	myport = CreateNewPort();
	SetPort(myport);
	SetPort(GetWindowPort(FrontWindow()));
#if 0
	Rect rr = {0, 0, 0, 0};
	RgnHandle rrr = NewRgn();
	RectRgn(rrr, &rr);
	MacSetRectRgn(rrr, 0, 0, 0, 0);
	SetPortVisibleRegion(myport, rrr);
	SetPortClipRegion(myport, rrr);
	SetPortBounds(myport, &rr);
#endif
	SetStdCProcs(&procs);
	procs.textProc = svgTextUPP;
	procs.lineProc = svgLineUPP;
	procs.rectProc = svgRectUPP;
	procs.rRectProc = svgRRectUPP;
	procs.ovalProc = svgOvalUPP;
	procs.arcProc = svgArcUPP;
	procs.polyProc = svgPolyUPP;
	procs.rgnProc = svgRgnUPP;
	procs.bitsProc = svgBitsUPP;
	procs.commentProc = svgCommentUPP;
    //	procs.TxMeasProc = svgTxMeasUPP;
	
	savedprocs = GetPortGrafProcs(myport);
	SetPortGrafProcs(myport, &procs);
	
	DrawPicture(p, &info.sourceRect);
    
	SetPortGrafProcs(myport, savedprocs);
    
    *svgo
    << "  </g>" << endl
    << "</svg>" << endl;
    
}

@end
