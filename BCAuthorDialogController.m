//
//  BCAuthorDialogController.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/16.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCAuthorDialogController.h"
#import "BCAuthor.h"


@interface BCAuthorDialogController (Private)


-(void)populateDialog;
-(void)retrieveFromDialog;

-(IBAction)okPressed:(id)sender;
-(IBAction)cancelPressed:(id)sender;
-(IBAction)optionFieldsPressed:(id)sender;
-(void)collapseOptions;
-(void)expandOptions;

@end

@implementation BCAuthorDialogController

-(id)initWithAuthor:(BCAuthor *)a; {
    
    self = [super init];
    if (self) {
        
        _theAuthor = a;
        
       if (!_dialog) {
  
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [NSBundle  loadNibNamed:@"VerticalAuthorDialog" owner:self];
#pragma clang diagnostic pop

            _firstRun = YES;

            
        }
        
        
        
    }
    
    return self;

    
}

-(void)populateDialog; {
    
    [_indexName setStringValue:_theAuthor.indexName];
    [_initials setStringValue:_theAuthor.initials];
    [_orcid setStringValue:_theAuthor.orcid];
    [_contribution setStringValue:_theAuthor.contribution];
    [_position setStringValue:_theAuthor.position];
    [_prefix setStringValue:_theAuthor.prefix];
    [_fullName setStringValue:_theAuthor.fullName];
    [_degrees setStringValue:_theAuthor.degrees];
    [_informal setStringValue:_theAuthor.informal];
    [_affiliation setStringValue:_theAuthor.affiliation];
    [_address setStringValue:_theAuthor.address];
    [_phone setStringValue:_theAuthor.phone];
    [_fax setStringValue:_theAuthor.fax];
    [_email setStringValue:_theAuthor.email];
    [_website setStringValue:_theAuthor.website];
    
    
   [self setupRecentAffiliations];
}

-(void)retrieveFromDialog; {
    _theAuthor.indexName = [_indexName stringValue];
    _theAuthor.initials = [_initials stringValue];
    _theAuthor.orcid = [_orcid stringValue];
    _theAuthor.contribution = [_contribution stringValue];
    _theAuthor.position = [_position stringValue];
    _theAuthor.prefix = [_prefix stringValue];
    _theAuthor.fullName = [_fullName stringValue];
    _theAuthor.degrees = [_degrees stringValue];
    _theAuthor.informal = [_informal stringValue];
    _theAuthor.affiliation = [_affiliation stringValue];
    _theAuthor.address = [_address stringValue];
    _theAuthor.phone = [_phone stringValue];
    _theAuthor.fax = [_fax stringValue];
    _theAuthor.email = [_email stringValue];
    _theAuthor.website = [_website stringValue];
    
    
    [self addAffiliationToRecentAffiliations];

    
}

-(BOOL)dialogForWindow:(NSWindow *)ownerWindow; {
    
    [self populateDialog];
    
    if ( _firstRun && [[ NSUserDefaults standardUserDefaults] boolForKey:kAuthorOptionFieldsAreExpandedKey]) {
    
        
        [self expandOptions]; 
        
        _firstRun = NO;
        
    }
    
    [NSApp beginSheet: _dialog
       modalForWindow: ownerWindow
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
          
          
    
    [NSApp runModalForWindow: _dialog];
    
    // See NSApplication Class Reference/runModalSession
    
    [NSApp endSheet:  _dialog];
    [_dialog orderOut: self];
    
    return _returnFlag;
    
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



// User Defaults
#define USERDEFAULT(x) ([[NSUserDefaults standardUserDefaults] objectForKey:(x)])

#define SETUSERDEFAULT(obj,key) ([[NSUserDefaults standardUserDefaults] setObject:(obj) forKey:(key)])


-(void)setupRecentAffiliations; {

    
    _affilArray = [NSMutableArray arrayWithArray:USERDEFAULT(kAuthorRecentAffiliationsKey)];

    for (NSString *a in _affilArray) {
    
        NSString *spaced_affliation = [a stringByReplacingOccurrencesOfString:@"," withString:@", "];
        [_recentAffiliations addItemWithTitle:spaced_affliation];
    }
}



-(void)addAffiliationToRecentAffiliations; {

        
    if ([ _theAuthor.affiliation length] == 0) { 
        return; 
    }
    
    BOOL alreadyInArray = NO;
    
    for (NSString *a in _affilArray) {
        if ( [a isEqualToString:_theAuthor.affiliation]) {
            alreadyInArray = YES;
        }
    }
    
    if (!alreadyInArray) {
    
        if ([_affilArray count] >= 10) {
            [_affilArray removeObjectAtIndex:0];      
        }
        [_affilArray addObject:_theAuthor.affiliation];
        SETUSERDEFAULT(_affilArray,kAuthorRecentAffiliationsKey);
    }

}

-(IBAction)recentAffifiationSelected:(id)sender; {

   [_affiliation setStringValue: [[_recentAffiliations selectedItem] title]];

}


-(IBAction)optionFieldsPressed:(id)sender; {
    
    // NOTE: need to implement show/hide of optional fields
    
   ;
//    
//   

     if ( [[ NSUserDefaults standardUserDefaults] boolForKey:kAuthorOptionFieldsAreExpandedKey]) {
        [self collapseOptions];
    }
    else {
        [self  expandOptions];
    }
    
    
}


-(void)collapseOptions; {

    
	[_optionsView removeFromSuperview];
	
    // resize the dialog
    NSRect newFrame = _dialog.frame;
    newFrame.origin.y += _optionsView.frame.size.height;
    newFrame.size.height -= _optionsView.bounds.size.height;
    [_dialog setFrame:newFrame display:YES animate:YES];
    
    
    newFrame = _optionsView.frame;
    newFrame.origin.y -= 48;
    [_optionsView setFrame:newFrame];

    
    [_dialog setMinSize:_dialog.frame.size];
    [_dialog setMaxSize:_dialog.frame.size];
    
    [_optionFieldsButton setState:NSOffState];
    [_optionFieldsLabelButton setTitle:@"Show Additional Fields"];

    
     [[ NSUserDefaults standardUserDefaults] setBool:  NO forKey:kAuthorOptionFieldsAreExpandedKey];
    
}

-(void)expandOptions; {
    
    //  enlarge the dialog
    //  make sure the top left of window doesn't move
    
    NSRect newFrame = _dialog.frame;
    newFrame.origin.y -= _optionsView.frame.size.height;
    newFrame.size.height += _optionsView.frame.size.height;
	[_dialog setFrame:newFrame display:YES animate:YES];
    
    newFrame = _optionsView.frame;
    newFrame.origin.y += 48;
    [_optionsView setFrame:newFrame];

    [_dialog setMinSize:_dialog.frame.size];
    [_dialog setMaxSize:_dialog.frame.size];
    
    // Add the details view, containing the release notes webview and the showReleaseNotes checkbox
	[[_dialog contentView] addSubview:_optionsView];

    [_optionFieldsButton setState:NSOnState];
    [_optionFieldsLabelButton setTitle:@"Hide Additional Fields"];

    [[ NSUserDefaults standardUserDefaults] setBool:  YES forKey:kAuthorOptionFieldsAreExpandedKey];
    
}



@end
