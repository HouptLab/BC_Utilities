//
//  BCDebugUtilities.m
//  Xynk
//
//  Created by Tom Houpt on 14/8/4.
//
//

#import "BCDebugUtilities.h"

@implementation NSNotificationCenter (DebuggingExtensions)



- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender; {
    
    NSLog(@"notification: %@", notificationName);
    
    [self postNotificationName:notificationName object:notificationSender];
    
}

- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo; {
    
        NSLog(@"notification: %@", notificationName);
    
    [self postNotificationName:notificationName object:notificationSender userInfo:userInfo];
    
    
}

@end



#ifdef DEBUG
#	define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DebugLog(...)
#endif
