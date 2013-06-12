//
//  BCMenuUtilities.m
//  Xynk
//
//  Created by Tom Houpt on 13/6/12.
//
//

#import "BCMenuUtilities.h"

void SetMenuTargetAndAction(NSMenu *theMenu, id theTarget, SEL aSelector) {
    
    // set the target and action of all menu items in the menu, including submenu items by recursion

    for (NSMenuItem *theMenuItem in [theMenu itemArray]) {
    
        [theMenuItem setTarget:theTarget];
        [theMenuItem setAction:aSelector];
        
        if ([theMenuItem hasSubmenu]) {
            SetMenuTargetAndAction([theMenuItem submenu], theTarget, aSelector);
            
        }
    }
    
}


