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

@end

@implementation BCAuthorDialogController

-(id)initWithAuthor:(BCAuthor *)a; {
    
    self = [super init];
    if (self) {
        
        _theAuthor = a;
        
        if (!_dialog) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [NSBundle  loadNibNamed:@"AuthorDialog" owner:self];
#pragma clang diagnostic pop
            
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
    
}

-(BOOL)dialogForWindow:(NSWindow *)ownerWindow; {
    
    [self populateDialog];
    
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

-(IBAction)optionFieldsPressed:(id)sender; {
    
    // NOTE: need to implement show/hide of optional fields
}



@end
