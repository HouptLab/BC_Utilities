//
//  BCSearchController.m
//  Caravan
//
//  Created by Tom Houpt on 15/9/27.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCSearchController.h"

// User Defaults
#define USERDEFAULT(x) ([[NSUserDefaults standardUserDefaults] objectForKey:(x)])

#define SETUSERDEFAULT(obj,key) ([[NSUserDefaults standardUserDefaults] setObject:(obj) forKey:(key)])


@implementation BCSearchController

@synthesize dialog;

-(id)init; {
    
    self = [super init];
    
    if (self) {
                
        if (!dialog) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [NSBundle  loadNibNamed:@"BCSearchDialog" owner:self];
#pragma clang diagnostic pop

 
            
        }

    }
    
    return self;
    
}



-(NSArray *)dialogForWindow:(NSWindow *)ownerWindow; 
{
    
    // NOTE: run last used keywords, select last selected journal 
    [self.ignoreCase setState:[USERDEFAULT(kBCSearchIgnoreCaseKey) integerValue]];
    [self.position selectCellAtRow:[USERDEFAULT(kBCSearchTermPositionKey)integerValue] column:0];
    [self.regex setState:[USERDEFAULT(kBCSearchUsingRegexKey)integerValue]];
    [self regexPressed:self];

    
    [self.resultsTable setDoubleAction:@selector(handleDoubleClick:)];
    
    [NSApp beginSheet: dialog
       modalForWindow: ownerWindow
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp runModalForWindow: dialog];
    
    // See NSApplication Class Reference/runModalSession
    
    [NSApp endSheet:  dialog];
    [dialog orderOut: self];

    
    // save current settings  in preferences
    
    SETUSERDEFAULT([NSNumber numberWithInteger:[self.ignoreCase state]], kBCSearchIgnoreCaseKey);

    SETUSERDEFAULT([NSNumber numberWithInteger:[self.position selectedRow]], kBCSearchTermPositionKey);
  
    SETUSERDEFAULT([NSNumber numberWithInteger:[self.regex state]], kBCSearchUsingRegexKey);  
    
    return nil;
    
}

-(IBAction)handleDoubleClick:(id*)sender; {


}

-(void)handleRowDoubleClick:(BCSearchTableView*)table; {

    [self OKButtonPressed:self];

}

-(IBAction)OKButtonPressed:(id)sender;{

       
      
   [NSApp stopModal];

}

-(IBAction)cancelButtonPressed:(id)sender; {

    [NSApp stopModal];

}

-(IBAction)regexPressed:(id)sender; {

    [self.ignoreCase setEnabled:![self.regex state]];
    [self.position setEnabled:![self.regex state]];

}

-(IBAction)findStringEntered:(id)sender; {

}

-(IBAction)deleteFindPressed:(id)sender; {
    [self.findString setStringValue:@""];
}
-(IBAction)deleteReplacePressed:(id)sender; {
    [self.replaceString setStringValue:@""];
}

-(IBAction)insertFindPressed:(id)sender; {
}
-(IBAction)insertReplacePressed:(id)sender;{
}

@end
