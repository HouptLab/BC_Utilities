//
//  BCCitationDialogController.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/16.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class BCCitation;

@interface BCCitationDialogController : NSObject

@property BCCitation *theCitation;

@property IBOutlet NSTabView *tabView;

@property IBOutlet NSTokenField *authors; /// array of BCCitationAuthors...
@property IBOutlet NSTextField *title;
@property IBOutlet NSTokenField *databaseIDs;
@property IBOutlet NSTextField *citeKey;


// journal article fields

@property IBOutlet NSTextField *journal;
@property IBOutlet NSTextField *journalAbbreviation;
@property IBOutlet NSTextField *volume;
@property IBOutlet NSTextField *number;
@property IBOutlet NSTextField *pages;
@property IBOutlet NSTextField *year;


// book chapter fields
@property IBOutlet NSTextField *bookTitleChapter;
@property IBOutlet NSTextField *bookLengthChapter;
@property IBOutlet NSTokenField  *editorsChapter; // array of BCCitationAuthors
@property IBOutlet NSTextField *publisherChapter;
@property IBOutlet NSTextField *publicationPlaceChapter;
@property IBOutlet NSTextField *volumeChapter;
@property IBOutlet NSTextField *numberChapter;
@property IBOutlet NSTextField *pagesChapter;
@property IBOutlet NSTextField *yearChapter;



// book fields

@property IBOutlet NSTextField *bookTitle;
@property IBOutlet NSTextField *bookLength;
@property IBOutlet NSTokenField  *editors; // array of BCCitationAuthors
@property IBOutlet NSTextField *publisher;
@property IBOutlet NSTextField *publicationPlace;
@property IBOutlet NSTextField *volumeBook;
@property IBOutlet NSTextField *numberBook;
@property IBOutlet NSTextField *yearBook;



@end
