//
//  BKPlayStation3Controller.h
//  Blink
//
//  Created by Tom Houpt on 4/25/14.
//  Copyright (c) 2014 Tom Houpt. All rights reserved.
//

// uses a lot of code from Apple's HID Calibrator sample code

#import <Foundation/Foundation.h>

/**  cookies (IOHIDElementCookie) for getting elements of PS3Controller

 */

/** center buttons
*/
#define kPS3SelectButtonCookie 7
#define kPS3StartButtonCookie 10
#define kPS3PSButtonCookie 23


/** joy sticks
*/
#define kPS3LeftStickXAxisCookie 26
#define kPS3LeftStickYAxisCookie 27
#define kPS3L3ButtonCookie 8

#define kPS3RightStickXAxisCookie 28
#define kPS3RightStickYAxisCookie 29
#define kPS3R3ButtonCookie 9

/** bumpers (L1 & L2) triggers (L2 & R2)
*/
#define kPS3L1ButtonCookie 17
#define kPS3L2ButtonCookie 15
#define kPS3L1PressureCookie 41
#define kPS3L2PressureCookie 39

#define kPS3R1ButtonCookie 18
#define kPS3R2ButtonCookie 16
#define kPS3R1PressureCookie 42
#define kPS3R2PressureCookie 40

/** left arrow pad
*/
#define kPS3UpButtonCookie 11
#define kPS3RightButtonCookie 12
#define kPS3DownButtonCookie 13
#define kPS3LeftButtonCookie 14
#define kPS3UpPressureCookie 35
#define kPS3RightPressureCookie 36
#define kPS3DownPressureCookie 37
#define kPS3LeftPressureCookie 38

/** right button pad
*/
#define kPS3TriangleButtonCookie 19
#define kPS3CircleButtonCookie 20
#define kPS3XButtonCookie 21
#define kPS3SquareButtonCookie 22
#define kPS3TrianglePressureCookie 43
#define kPS3CirclePressureCookie 44
#define kPS3XPressureCookie 45
#define kPS3SquarePressureCookie 46


/** Accelerometers
    (need to figure this out more)
*/
//Description
//62 Right-Left boolean left up = 0, right up = 255
//63 Right-Left angle (positive is left)
//64 Forward-Backward back up =  0, front up = 255
//65 Forward-Backward (positive is forward)
//
//67 Up-Down (positive is up)
//
//??? Yaw axis (positive is clockwise)

#import "IOHIDElementModel.h"
#include "HID_Utilities_External.h"

/** AppDelegate should call Initialize_HID at applicationDidFinishLaunching and Terminate_HID at applicationWillTerminate
 
    Initialize_HD sets up call backs for handling device connecting and disconnecting, which will provide a (IOHIDDeviceRef)inIOHIDDeviceRef pointer that is used to initialize the controller when it is connected
 
    To handle controller events, subclass should override
    handleUpdateOfCookie:(IOHIDElementCookie)cookie  withNewValue:(double)newValue
 
 
*/

@interface BCPlayStation3Controller : NSObject  {
    
    
}

@property (assign, nonatomic, readwrite) IOHIDDeviceRef _IOHIDDeviceRef;

-(id)initWithIOHIDDeviceRef:(IOHIDDeviceRef)inIOHIDDeviceRef;



/** the controller element with the given cookie has a newValue
 
 (cookie is of type uint32_t)

 this should be overridden by subclass
 
 e.g. 
        switch (cookie) {
                
                // center buttons
            case  kPS3SelectButtonCookie:
                break;
            case  kPS3StartButtonCookie:
                break;
            case  kPS3PSButtonCookie:
                break;
                
                // joy sticks
            case  kPS3LeftStickXAxisCookie:
                break;
            case  kPS3LeftStickYAxisCookie:
                break;
            case  kPS3L3ButtonCookie:
                break;
            case  kPS3RightStickXAxisCookie:
                break;
            case  kPS3RightStickYAxisCookie:
                break;
            case  kPS3R3ButtonCookie:
                break;
                
                // bumpers (L1 & R1) triggers (L2 & R2)
            case  kPS3L1ButtonCookie:
                break;
            case  kPS3L2ButtonCookie:
                break;
            case  kPS3L1PressureCookie:
                break;
            case  kPS3L2PressureCookie:
                break;
                
                
            case  kPS3R1ButtonCookie:
                break;
            case  kPS3R2ButtonCookie:
                break;
            case  kPS3R1PressureCookie:
                break;
            case  kPS3R2PressureCookie:
                break;
                
                // left arrow pad
            case  kPS3UpButtonCookie:
                break;
            case  kPS3RightButtonCookie:
                break;
            case  kPS3DownButtonCookie:
                break;
            case  kPS3LeftButtonCookie:
                break;
            case  kPS3UpPressureCookie:
                break;
            case  kPS3RightPressureCookie:
                break;
            case  kPS3DownPressureCookie:
                break;
            case  kPS3LeftPressureCookie:
                
                // right button pad
                break;
            case  kPS3TriangleButtonCookie:
                break;
            case  kPS3CircleButtonCookie:
                break;
            case  kPS3XButtonCookie:
                break;
            case  kPS3SquareButtonCookie:
                break;
            case  kPS3TrianglePressureCookie:
                break;
            case  kPS3CirclePressureCookie:
                break;
            case  kPS3XPressureCookie:
                break;
            case  kPS3SquarePressureCookie:
                break;
                
        }

*/
-(void)handleUpdateOfCookie:(IOHIDElementCookie)cookie  withNewValue:(double)newValue;


@end
