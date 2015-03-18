//
//  BCCitationDialogController.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/16.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCCitationDialogController.h"
#import "BCCitation.h"

@implementation BCCitationDialogController



-(id)initWithCitation:(BCCitation *)c; {
    
    self = [super init];
    if (self) {
        
        _theCitation = c;
        
    }
    
    return self;
    
}

-(void)awakeFromNib; {
    
    [self populateDialog];
}
-(void)populateDialog; {
    
    // common fields
    
    ///@property IBOutlet NSTokenField *authors setStringValue:_theCitation.];
    [_title setStringValue:_theCitation.title];
    //@property IBOutlet NSTokenField *databaseIDs setStringValue:_theCitation.];
    [_citeKey setStringValue:_theCitation.citeKey ];
    
    
    // journal article fields
    
    [_journal setStringValue:_theCitation.journal];
    [_journalAbbreviation setStringValue:_theCitation.journalAbbreviation];
    [_volume setStringValue:_theCitation.volume];
    [_number setStringValue:_theCitation.number];
    [_pages setStringValue:_theCitation.pages];
    [_year setStringValue:[NSString stringWithFormat:@"%ld",_theCitation.publicationYear] ];
    
    
    // book chapter fields
    
    [_bookTitleChapter setStringValue:_theCitation.bookTitle];
    [_bookLengthChapter setStringValue:_theCitation.bookLength];
    // @property IBOutlet NSTokenField  *editorsChapter setStringValue:_theCitation.];
    [_publisherChapter setStringValue:_theCitation.publisher];
    [_publicationPlaceChapter setStringValue:_theCitation.publicationPlace];
    [_volumeChapter setStringValue:_theCitation.volume];
    [_numberChapter setStringValue:_theCitation.number];
    [_pagesChapter setStringValue:_theCitation.pages];
    [_yearChapter setStringValue:[NSString stringWithFormat:@"%ld",_theCitation.publicationYear]];
    
    
    
    // book fields
    
    [_bookTitle setStringValue:_theCitation.bookTitle];
    [_bookLength setStringValue:_theCitation.bookLength];
    //@property IBOutlet NSTokenField  *editors setStringValue:_theCitation.]; // array of BCCitationAuthors
    [_publisher setStringValue:_theCitation.publisher];
    [_publicationPlace setStringValue:_theCitation.publicationPlace];
    [_volumeBook setStringValue:_theCitation.volume];
    [_numberBook setStringValue:_theCitation.number];
    [_yearBook setStringValue:[NSString stringWithFormat:@"%ld",_theCitation.publicationYear]];
    
    [_tabView selectTabViewItemAtIndex:_theCitation.citationType];
    
}

-(void)retrieveFromDialog; {
    
    // common fields

    ///@property IBOutlet NSTokenField *authors stringValue];  _theCitation. =
    _theCitation.title = [_title stringValue];
    //@property IBOutlet NSTokenField *databaseIDs stringValue];  _theCitation. =
    // citekey is read only
    
    _theCitation.citationType = [_tabView indexOfTabViewItem:[_tabView selectedTabViewItem]];
    
    if ( kJournalArticle == _theCitation.citationType) {
        
        // journal article fields
        
        _theCitation.journal = [_journal stringValue];  _theCitation.journal =
        _theCitation.journalAbbreviation = [_journalAbbreviation stringValue];
        _theCitation.volume = [_volume stringValue];
        _theCitation.number = [_number stringValue];
        _theCitation.pages = [_pages stringValue];
        _theCitation.publicationYear  = [_year integerValue];
        
    }
    else if (kBookChapter == _theCitation.citationType) {
        
        _theCitation.bookTitle = [_bookTitleChapter stringValue];
        _theCitation.bookLength = [_bookLengthChapter stringValue];
        // @property IBOutlet NSTokenField  *editorsChapter stringValue];  _theCitation. =
        _theCitation.publisher = [_publisherChapter stringValue];
        _theCitation.publicationPlace = [_publicationPlaceChapter stringValue];
        _theCitation.volume =[_volumeChapter stringValue];
        _theCitation.number = [_numberChapter stringValue];
        _theCitation.pages = [_pagesChapter stringValue];
        _theCitation.publicationYear  = [_yearChapter integerValue];
        
    }
    else if (kBook == _theCitation.citationType) {
    
        _theCitation.bookTitle = [_bookTitle stringValue];
        _theCitation.bookLength = [_bookLength stringValue];
        //@property IBOutlet NSTokenField  *editors stringValue];  _theCitation. =  // array of BCCitationAuthors
        _theCitation.publisher = [_publisher stringValue];
        _theCitation.publicationPlace = [_publicationPlace stringValue];
        _theCitation.volume = [_volumeBook stringValue];
        _theCitation.number = [_numberBook stringValue];
        _theCitation.publicationYear  = [_yearBook integerValue];
        
    }
    
    
}

-(IBAction)cancelPressed:(id)sender; {
    // return canceled
    [_theCitation finishedEditing:NO];

}

-(IBAction)okPressed:(id)sender; {
    
    [self retrieveFromDialog];
    [_theCitation finishedEditing:YES];
    // return OK
    
}


@end
