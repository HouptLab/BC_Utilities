//
//  SerialPortNameController.h
//  Bartender
//
//  Created by Tom Houpt on 22/12/18.
//


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SerialPortNameController : NSObject

@property IBOutlet NSWindow *dialog;
@property IBOutlet NSTextField *serialnameField;
@property (copy) NSString *serialname;

-(id)initWithName:(NSString *)n;
-(NSString *)dialogForWindow:(NSWindow *)ownerWindow; 
-(IBAction)cancelButtonPressed:(id)sender;
-(IBAction)OKButtonPressed:(id)sender;


@end
