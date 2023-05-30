//
//  SerialPortNameController.m
//  Bartender
//
//  Created by Tom Houpt on 22/12/18.
//

#import "SerialPortNameController.h"

@implementation SerialPortNameController


@synthesize dialog;
@synthesize serialnameField;
@synthesize serialname;

-(id)initWithName:(NSString *)n; {
    
    self = [super init];
    if (self) {
        
        serialname = n;

        if (!dialog) {
            
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [NSBundle  loadNibNamed:@"SerialPortNameController" owner:self];
    #pragma clang diagnostic pop
    
        }
        
    }
    return self;
    
}


-(NSString *)dialogForWindow:(NSWindow *)ownerWindow; {
    

    
    [serialnameField setStringValue:serialname];

    [NSApp beginSheet: dialog
       modalForWindow: ownerWindow
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp runModalForWindow: dialog];
    
    // See NSApplication Class Reference/runModalSession
    
    [NSApp endSheet:  dialog];
    [dialog orderOut: dialog];
    
    return serialname;
    
}


-(IBAction)cancelButtonPressed:(id)sender; {
    
    [NSApp stopModal];
    serialname = nil;

}

-(IBAction)OKButtonPressed:(id)sender; {
    
    [NSApp stopModal];
    serialname = [serialnameField stringValue];

}


@end
