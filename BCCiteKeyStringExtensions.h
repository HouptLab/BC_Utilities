//
//  BCCiteKeyStringExtensions.h
//  Caravan
//
//  Created by Tom Houpt on 15/4/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AppKit/AppKit.h>





@interface NSString  (CiteKeyExtensions)

/** return an attributed string of length 1 consisting of an NSAttachmentChararacter with a NSTextAttachment. The NSTextAttachment has name <self> and with a token image
*/
-(NSAttributedString *)stringAsTokenAttachment;

/** return an NSImage of the string drawn in a rounded token rectangle.
    current implementation is font size 12 in 16 tall token, with light blue color d2e7fb
*/
-(NSImage *)tokenImage;

/** scan the string for every universal citekey @"{<author>:YYYYaa}" and replace with token attachements
 */

-(NSAttributedString *)stringByReplacingCiteKeyStringsWithTokens;

/** scan the string for every universal citekey @"{<author>:YYYYaa}" and replace with bibTeX citation @"[@<author>:YYYYaa]"
 */

-(NSMutableString *)stringByReplacingCiteKeyStringsWithBibTeXCitation;

/** scan the string and return space-separated initials
 
    examples:
 
    @"TA" -> @"T A"
    @"Thomas" -> @"T"
    @"T.A." -> @"T.A."
    @"Thomas A." ->@"T A"
    @"Thomas Albro" ->@"T A"
    @"Louie-Phillipe" @"L-P"
    @"L.-P." @"L-P"
*/
-(NSString *)stringByGettingInitials;

@end

@interface NSAttributedString  (CiteKeyExtensions)


/** scan the string for every token attachements and replace with universal citekeys @"{<author>:YYYYaa}" in a new string
 */
-(NSString *)stringByReplacingCiteKeyTokensWithStrings;

-(NSArray *)rangesOfTokensWithName:(NSString *)tokenName;

@end
