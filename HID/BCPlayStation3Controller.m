//
//  BKPlayStation3Controller.m
//  Blink
//
//  Created by Tom Houpt on 4/25/14.
//  Copyright (c) 2014 Tom Houpt. All rights reserved.
//

#import "BCPlayStation3Controller.h"

static void Handle_IOHIDValueCallback(void *inContext,
                                      IOReturn inResult,
                                      void *inSender,
                                      IOHIDValueRef inIOHIDValueRef);

@interface BCPlayStation3Controller () {
    
//@private
//    IOHIDDeviceRef _IOHIDDeviceRef;
    
}

-(void)handleUpdateOfHIDValueRef:
(IOHIDValueRef) updatedValueRef withHIDElementRef:(IOHIDElementRef)updatedElementRef;

@end

@implementation BCPlayStation3Controller



// when InputValueCallback is called,
// then call appropriate BKPriorStageController
// processKeyDown or processKeyUp method with appropriate "keystroke"


@synthesize _IOHIDDeviceRef;
//@synthesize _IOHIDElementModels;
//@synthesize name;


//
// initialization method
//
- (id) initWithIOHIDDeviceRef:(IOHIDDeviceRef)inIOHIDDeviceRef {
	NSLog(@"(IOHIDDeviceRef) %@", inIOHIDDeviceRef);
	self = [super init];
	if (self) {
        
		self._IOHIDDeviceRef = inIOHIDDeviceRef;
        
	}
    
	return (self);
}                                                                               // init

//
//
//
- (void) dealloc {

    _IOHIDDeviceRef = nil;

    
}
// dealloc

//
//
//
- (void) set_IOHIDDeviceRef:(IOHIDDeviceRef)inIOHIDDeviceRef {
    
	NSLog(@"(IOHIDDeviceRef: %p)", inIOHIDDeviceRef);
    
	if (_IOHIDDeviceRef != inIOHIDDeviceRef) {
        
		_IOHIDDeviceRef = inIOHIDDeviceRef;
        
		if (inIOHIDDeviceRef) {
       
			IOHIDDeviceRegisterInputValueCallback(inIOHIDDeviceRef,
			                                      Handle_IOHIDValueCallback,
			                                      (__bridge void *)(self));
		}
	}
}                                                                               // set_IOHIDDeviceRef



-(void)handleUpdateOfHIDValueRef:(IOHIDValueRef) updatedValueRef withHIDElementRef:(IOHIDElementRef)updatedElementRef; {
    
    IOHIDElementCookie cookie = IOHIDElementGetCookie(updatedElementRef);
    
    
    double physicalValue = IOHIDValueGetScaledValue(updatedValueRef,
                               kIOHIDValueScaleTypePhysical);
    

    [self handleUpdateOfCookie:cookie  withNewValue:physicalValue];
    
}



-(void)handleUpdateOfCookie:(IOHIDElementCookie)cookie  withNewValue:(double)newValue; {
    
    
    NSLog(@"BCPlayStation3Controller handleUpdateOfCookie:withNewValue: should be overridden by subclass");
    
     
}

@end

//
//
//
static void Handle_IOHIDValueCallback(void *		inContext,
                                      IOReturn		inResult,
                                      void *		inSender,
                                      IOHIDValueRef inIOHIDValueRef) {
#pragma unused( inContext, inResult, inSender )
	BCPlayStation3Controller *tPS3Controller = (__bridge BCPlayStation3Controller *) inContext;
    // IOHIDDeviceRef tIOHIDDeviceRef = (IOHIDDeviceRef) inSender;
    
    // NSLog(@"(context: %p, result: %u, sender: %p, valueRef: %p", inContext, inResult, inSender, inIOHIDValueRef);
    
	do {
        // is our device still valid?
		if (!tPS3Controller._IOHIDDeviceRef) {
			NSLog(@"tIOHIDDeviceWindowCtrl._IOHIDDeviceRef == NULL");
			break;                                                              // (no)
		}
        
#if false
        // is this value for this device?
		if (tIOHIDDeviceRef != tPS3Controller._IOHIDDeviceRef) {
			NSLog(@"tIOHIDDeviceRef (%p) != _IOHIDDeviceRef (%p)",
			           tIOHIDDeviceRef,
			           tPS3Controller._IOHIDDeviceRef);
			break;                                                              // (no)
		}
        
#endif                                                                          // if false
        // is this value's element valid?
		IOHIDElementRef tIOHIDElementRef = IOHIDValueGetElement(inIOHIDValueRef);
		if (!tIOHIDElementRef) {
			NSLog(@"tIOHIDElementRef == NULL");
			break;                                                              // (no)
		}
        
        // length ok?
		CFIndex length = IOHIDValueGetLength(inIOHIDValueRef);
		if (length > sizeof(double_t)) {
			break;                                                              // (no)
		}
        
        [tPS3Controller handleUpdateOfHIDValueRef:inIOHIDValueRef withHIDElementRef:tIOHIDElementRef];

	} while (false);
}                                                                               // Handle_IOHIDValueCallback

