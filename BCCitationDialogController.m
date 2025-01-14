//
//  BCCitationDialogController.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/16.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCCitationDialogController.h"
#import "BCCitation.h"
#import "BCCitationAuthor.h"

@interface BCCitationDialogController (Private)

-(void)populateDialog;
-(void)retrieveFromDialog;
-(IBAction)cancelPressed:(id)sender;
-(IBAction)okPressed:(id)sender;

@end

@implementation BCCitationDialogController

@synthesize theCitation;


@synthesize dialog;
@synthesize returnFlag;


@synthesize tabView;

@synthesize authors; /// array of BCCitationAuthors...
@synthesize title;
@synthesize databaseIDs;
@synthesize citeKey;


// journal article fields

@synthesize journal;
@synthesize journalAbbreviation;
@synthesize volume;
@synthesize number;
@synthesize pages;
@synthesize year;


// book chapter fields
@synthesize bookTitleChapter;
@synthesize bookLengthChapter;
@synthesize editorsChapter; // array of BCCitationAuthors
@synthesize publisherChapter;
@synthesize publicationPlaceChapter;
@synthesize volumeChapter;
@synthesize numberChapter;
@synthesize pagesChapter;
@synthesize yearChapter;



// book fields

@synthesize bookTitle;
@synthesize bookLength;
@synthesize editors; // array of BCCitationAuthors
@synthesize publisher;
@synthesize publicationPlace;
@synthesize volumeBook;
@synthesize numberBook;
@synthesize yearBook;




-(id)initWithCitation:(BCCitation *)c; {
    
    self = [super init];
    if (self) {
        
        theCitation = c;
        
        if (!dialog) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [NSBundle  loadNibNamed:@"CitationDialog" owner:self];
  
#pragma clang diagnostic pop
            
        }
        

        
    }
    
    return self;
    
}


-(BOOL)dialogForWindow:(NSWindow *)ownerWindow; {
    
    [self populateDialog];
    
    [NSApp beginSheet: dialog
       modalForWindow: ownerWindow
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp runModalForWindow: dialog];
    
    // See NSApplication Class Reference/runModalSession
    
    [NSApp endSheet:  dialog];
    [dialog orderOut: self];
    
    return returnFlag;
    
}


-(void)populateDialog; {
    
    
    // common fields
    
    // set author tokens
    NSMutableString *authorList = [NSMutableString string];
    for (BCCitationAuthor *anAuthor in theCitation.authors) {
        [authorList appendString:anAuthor.indexName];
        [authorList appendString:@", "];
        [authorList appendString:anAuthor.initials];
        [authorList appendString:@";"];
    }
    [authors setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
    [authors setStringValue:authorList];
    
    [title setStringValue:theCitation.title];
    
    // set databaseIDs
    //@property IBOutlet NSTokenField *databaseIDs setStringValue:theCitation.];
    NSMutableString *databaseList = [NSMutableString string];
    for (NSString *aKey in theCitation.databaseIDs) {
        [databaseList appendString:aKey];
        [databaseList appendString:@": "];
        [databaseList appendString:[theCitation.databaseIDs objectForKey:aKey]];
        [databaseList appendString:@","];
    }
    
    [databaseIDs setStringValue:databaseList];
    
    [citeKey setStringValue:theCitation.citeKey ];
    
    
    // journal article fields
    
    [journal setStringValue:theCitation.journal];
    [journalAbbreviation setStringValue:theCitation.journalAbbreviation];
    [volume setStringValue:theCitation.volume];
    [number setStringValue:theCitation.number];
    [pages setStringValue:theCitation.pages];
    [year setStringValue:[NSString stringWithFormat:@"%ld",theCitation.publicationYear] ];
    
    
    // book chapter fields
    
    [bookTitleChapter setStringValue:theCitation.booktitle];
    [bookLengthChapter setStringValue:theCitation.bookLength];
    // @property IBOutlet NSTokenField  *editorsChapter setStringValue:theCitation.];
    [publisherChapter setStringValue:theCitation.publisher];
    [publicationPlaceChapter setStringValue:theCitation.publicationPlace];
    [volumeChapter setStringValue:theCitation.volume];
    [numberChapter setStringValue:theCitation.number];
    [pagesChapter setStringValue:theCitation.pages];
    [yearChapter setStringValue:[NSString stringWithFormat:@"%ld",theCitation.publicationYear]];
    
    
    
    // book fields
    
    [bookTitle setStringValue:theCitation.booktitle];
    [bookLength setStringValue:theCitation.bookLength];
    //@property IBOutlet NSTokenField  *editors setStringValue:theCitation.]; // array of BCCitationAuthors
    [publisher setStringValue:theCitation.publisher];
    [publicationPlace setStringValue:theCitation.publicationPlace];
    [volumeBook setStringValue:theCitation.volume];
    [numberBook setStringValue:theCitation.number];
    [yearBook setStringValue:[NSString stringWithFormat:@"%ld",theCitation.publicationYear]];
    
    [tabView selectTabViewItemAtIndex:theCitation.citationType];
    
}

-(void)retrieveFromDialog; {
    

    
    // common fields
  
    // clear pre-existing authors
    NSMutableArray *newAuthors = [NSMutableArray array];
    NSArray *enteredAuthors = [authors objectValue];
    for (NSString *authorName in enteredAuthors) {
            BCCitationAuthor *theAuthor = [[BCCitationAuthor alloc] initWithLastNameAndInitialsString:authorName];
        [newAuthors addObject:theAuthor];
    }
    [theCitation setAuthors:newAuthors];

    theCitation.title = [title stringValue];
    
    // clear pre-existing database values
    [theCitation setDatabaseIDs: [NSMutableDictionary dictionary]];
    NSArray *enteredIDs = [databaseIDs objectValue];

    for (NSString *anID in enteredIDs) {

        NSArray *parts = [anID componentsSeparatedByString:@":"];
        
        NSString *ascension = [[parts firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];        

        
        NSString *database = [[parts lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];        
        [theCitation setAscension:ascension forDatabase:database]; 

    }
    
    
    // citekey is read only
    
    theCitation.citationType = [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
    
    if ( kArticle == theCitation.citationType) {
        
        // journal article fields
        
        theCitation.journal = [journal stringValue];  theCitation.journal =
        theCitation.journalAbbreviation = [journalAbbreviation stringValue];
        theCitation.volume = [volume stringValue];
        theCitation.number = [number stringValue];
        theCitation.pages = [pages stringValue];
        theCitation.publicationYear  = [year integerValue];
        
        [theCitation setFirstAuthor:[[[theCitation authors] firstObject] indexName]];
    }
    else if (kInBook == theCitation.citationType) {
        
        theCitation.booktitle = [bookTitleChapter stringValue];
        theCitation.bookLength = [bookLengthChapter stringValue];
        
        NSMutableArray *newEditors = [NSMutableArray array];
        NSArray *enteredEditors = [editorsChapter objectValue];
        for (NSString *authorName in enteredEditors) {
                BCCitationAuthor *theAuthor = [[BCCitationAuthor alloc] initWithLastNameAndInitialsString:authorName];
            [newEditors addObject:theAuthor];
        }
        [theCitation setEditors:newEditors];

        theCitation.publisher = [publisherChapter stringValue];
        theCitation.publicationPlace = [publicationPlaceChapter stringValue];
        theCitation.volume =[volumeChapter stringValue];
        theCitation.number = [numberChapter stringValue];
        theCitation.pages = [pagesChapter stringValue];
        theCitation.publicationYear  = [yearChapter integerValue];
        
        [theCitation setFirstAuthor:[[[theCitation authors] firstObject] indexName]];
            
    }
    else if (kBook == theCitation.citationType) {
    
        theCitation.booktitle = [bookTitle stringValue];
        theCitation.bookLength = [bookLength stringValue];
          NSMutableArray *newEditors = [NSMutableArray array];
        NSArray *enteredEditors = [editors objectValue];
        for (NSString *authorName in enteredEditors) {
                BCCitationAuthor *theAuthor = [[BCCitationAuthor alloc] initWithLastNameAndInitialsString:authorName];
            [newEditors addObject:theAuthor];
        }
        [theCitation setEditors:newEditors];      
                
        theCitation.publisher = [publisher stringValue];
        theCitation.publicationPlace = [publicationPlace stringValue];
        theCitation.volume = [volumeBook stringValue];
        theCitation.number = [numberBook stringValue];
        theCitation.publicationYear  = [yearBook integerValue];
        
        if ([[theCitation authors] count] > 0) {
            [theCitation setFirstAuthor:[[[theCitation authors] firstObject] indexName]];
        }
        else if ([[theCitation editors] count] > 0) {
            [theCitation setFirstAuthor:[[[theCitation editors] firstObject] indexName]];
        } 
    }
    
}

-(IBAction)cancelPressed:(id)sender; {
    
    [NSApp stopModal];

    // return canceled
    self.returnFlag = NO;

}

-(IBAction)okPressed:(id)sender; {
    
    [NSApp stopModal];

    // return OK
    [self retrieveFromDialog];
    self.returnFlag = YES;
    
}


@end
