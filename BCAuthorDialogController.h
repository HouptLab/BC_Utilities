//
//  BCAuthorDialogController.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/16.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class BCAuthor;

@interface BCAuthorDialogController : NSObject

@property BCAuthor *theAuthor;

@property IBOutlet NSWindow *dialog;
@property  BOOL returnFlag;

// required for citations
@property IBOutlet NSTextField *indexName;// last or family name in Europe
@property IBOutlet NSTextField *initials; // "J.C." or "JC" or "J C". note that a hypen, e.g. "J-LP", is not a separator, so "J-LP" would be parsed as "J.-L. P"

@property IBOutlet NSTextField * orcid; // 16 digit number with hyphen every 4 digits
// @property IBOutlet NSTextField *clusterID;
// @property IBOutlet NSTextField *authorType;

// requird for title page or contact info...
// probably overdetermined
// can be matched more directly to vcard?

@property IBOutlet NSTextField *contribution;
@property IBOutlet NSComboBox *position; /// e.g. "Research Associate, Professor, Chair" can be multiple can be multiple

@property IBOutlet NSComboBox *prefix; /// "Professor" or "Professor Dr.
@property IBOutlet NSTextField *fullName; /// as used on title page "James C. Smith"
@property IBOutlet NSComboBox *degrees; // e.g. "PhD, MD"
@property IBOutlet NSTextField *informal; // e.g. Jim


@property IBOutlet NSTextField *affiliation;// bind to fancy affliation structure...[define like an URL..., can be multiple
@property IBOutlet NSTextField *address;
@property IBOutlet NSTextField *phone;
@property IBOutlet NSTextField *fax;
@property IBOutlet NSTextField *email;
@property IBOutlet NSTextField *website;

@property IBOutlet NSButton *optionFieldsButton;
@property IBOutlet NSTextField *optionFieldsLabel;

-(id)initWithAuthor:(BCAuthor *)a;

/** return YES if OK pressed and author edited
 return NO if Cancel pressed and author not touched
 */
-(BOOL)dialogForWindow:(NSWindow *)ownerWindow;
@end
