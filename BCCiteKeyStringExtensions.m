//
//  BCCiteKeyStringExtensions.m
//  Caravan
//
//  Created by Tom Houpt on 15/4/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "BCCiteKeyStringExtensions.h"
#import "BCStringExtensions.h"

#import "BCColorUtilities.h"
#import "BCCiteKey.h"


@interface NSString  (Private)
- (NSFileWrapper *)fileWrapperWithIdentifier:(NSString *)identifier andImage:(NSImage *)theImage;

@end
@implementation NSString  (CiteKeyExtensions)

-(NSAttributedString *)stringAsTokenAttachment; {
    
   // NSFont *myFont = [self font];
    NSImage * tokenImage = [self tokenImage];
        //withHeight:[myFont ascender]];
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:tokenImage];
    attachmentCell.identifier = [self  copy];
    NSFileWrapper * citeKeyWrapper = [self fileWrapperWithImage:nil];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:citeKeyWrapper];
    
    [attachment setAttachmentCell: attachmentCell ];
    
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment: attachment];
    
    return attributedString;
    
}


/** image can be nil, then  fileWrapper gets name @"<identifier>"
 if image is not nil, then fileWrapper gets name @"<identifier>"
 
 */
- (NSFileWrapper *)fileWrapperWithImage:(NSImage *)theImage;
{
    
    NSString *wrapName;
    NSData *data;
    if (nil != theImage) {
       // wrapName = [self stringByAppendingPathExtension:@"tiff"];
        wrapName = [self copy];

        data = [theImage TIFFRepresentation];
    }
    else {
        wrapName = [self copy];
        data = nil;
    }
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
    
    [wrapper setFilename:wrapName];
    [wrapper setPreferredFilename:wrapName];
    
    return wrapper;
}




-(NSImage *)tokenImage; {
    
    // NOTE: add parameters for setting font, color and fontsize
    
// withHeight:(CGFloat)fontHeight; {
    
    // figure out width of citekey
    
//    CGFloat citeKeyFontSize = 0.75 * fontHeight;
//    if ( citeKeyFontSize > 12) { citeKeyFontSize = 12; }
//    if ( citeKeyFontSize < 6) { citeKeyFontSize = 6; }

    CGFloat    citeKeyFontSize = 12;
    
    NSFont *myFont = [NSFont fontWithName:@"Helvetica" size:citeKeyFontSize];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                myFont, NSFontAttributeName,
                                [NSColor blackColor],NSForegroundColorAttributeName,
                                nil];
    
    
    NSSize tokenSize = [self sizeWithAttributes:attributes];
    // adjust tokenSize to give a buffer
    //   tokenSize.height = fontHeight ;
    
//    tokenSize.height = 0.8 * fontHeight;
//    if ( tokenSize.height > 16) { tokenSize.height = 16; }
//    else if (tokenSize.height < 9) { tokenSize.height = 9; }
    
    tokenSize.height = 14;
    
    tokenSize.width += 6;
    
    NSImage *token = [[NSImage alloc]  initWithSize: tokenSize];
    [token lockFocus];
    [NSColorFromHexValuesString(@"d2e7fb") setFill];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0,0,tokenSize.width, tokenSize.height) xRadius:3.0 yRadius:3.0];
    [path fill];
    [self drawAtPoint:NSMakePoint(3,1) withAttributes:attributes];
    [token unlockFocus];
    
    return token;
}


-(NSAttributedString *)stringByReplacingCiteKeyStringsWithTokens; {
    
    /*
     1. get the ranges of every citekeyText by regex matching with citeKeyRegexString
     2. for each citekey, make a new NSAttributedString tokenString which contains an NSTextAttachement with attached fileWrapper with the filename citekey and associated token image
     3.  add each tokenString to an array of replacementStrings
     4. replace all occurences of the citeKeyText with the attributed tokenStrings in replacementStrings
     
     */
    
    
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithString:self attributes:nil];
    
    NSArray *oldRanges = [[newString string]rangesOfRegex:citeKeyRegexString];
    
    
    if (nil != oldRanges) {
        
        NSMutableArray *replacementStrings = [NSMutableArray array];
        
        for (NSInteger i = 0; i< [oldRanges count]; i++) {
            NSRange range = [[oldRanges objectAtIndex:i] rangeValue];
            
            NSString *citeKeyText =  [[newString string] substringWithRange:range];
            NSAttributedString *tokenString = [citeKeyText  stringAsTokenAttachment];
            
            [replacementStrings addObject:tokenString];
        }
        
        
            for (NSInteger i = [oldRanges count]-1; i>=0; i--) {
                NSRange range = [[oldRanges objectAtIndex:i] rangeValue];
                // replace the range shifted by locationShift with our replaceString
                [newString replaceCharactersInRange:range withAttributedString:[replacementStrings objectAtIndex:i ]];
            }
    }
    
    return newString;
    
}


@end

@implementation NSAttributedString  (CiteKeyExtensions)

-(NSString *)stringByReplacingCiteKeyTokensWithStrings; {
    
    /*
     1. find all attachments by looking for occurence of NSAttachmentCharacter
     2. for each attachment, get the citeKeyText from the filename of attached fileWrapper
     3. add the citeKeyText to an array of replacementStrings
     4. replace all occurences of attachments with the replacementStrings
     
     */
    
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:self];

    
    NSString *attachmentString = [[NSString alloc]
                                  initWithFormat:@"%C", (unichar)NSAttachmentCharacter];
    NSArray *oldRanges = [[newString string ]rangesOfString: attachmentString];
    
    if (nil != oldRanges) {
        
        NSMutableArray *replacementStrings = [NSMutableArray array];
        
        for (NSInteger i = 0; i< [oldRanges count]; i++) {
            NSRange eR;
            NSInteger index = [[oldRanges objectAtIndex:i] rangeValue].location;
            NSTextAttachment *attachment = [[self attributesAtIndex:index effectiveRange:&eR] objectForKey:NSAttachmentAttributeName];
            NSString *citeKeyText = [[attachment fileWrapper] filename];
            [replacementStrings addObject:citeKeyText];
        }
        

            for (NSInteger i = [oldRanges count]-1; i>=0; i--) {
                NSRange range = [[oldRanges objectAtIndex:i] rangeValue];
                // replace the range shifted by locationShift with our replaceString
                [newString  replaceCharactersInRange:range withString:[replacementStrings objectAtIndex:i ]];
            }
        
    }
    
    return [newString string];
    
}

-(NSArray *)rangesOfTokensWithName:(NSString *)tokenName;
{
    
    /*
     1. find all attachments by looking for occurence of NSAttachmentCharacter
     2. for each attachment, get the citeKeyText from the filename of attached fileWrapper
     3. add the citeKeyText to an array of replacementStrings
     4. replace all occurences of attachments with the replacementStrings
     
     */
    
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    
    NSMutableArray *matchingRanges = [NSMutableArray array];

    
    NSString *attachmentString = [[NSString alloc]
                                  initWithFormat:@"%C", (unichar)NSAttachmentCharacter];
    NSArray *oldRanges = [[newString string ] rangesOfString: attachmentString];
    
    if (nil != oldRanges) {
        
        
        for (NSInteger i = 0; i< [oldRanges count]; i++) {
            NSRange eR;
            NSInteger index = [[oldRanges objectAtIndex:i] rangeValue].location;
            NSTextAttachment *attachment = [[self attributesAtIndex:index effectiveRange:&eR] objectForKey:NSAttachmentAttributeName];
            
            NSString *citeKeyText = [[attachment fileWrapper] filename];

            if ([citeKeyText isEqualToString:tokenName]) {
                [matchingRanges addObject: [oldRanges objectAtIndex:i]];
            }
        }
        
        
    }
    
    return matchingRanges;
    
}

@end


