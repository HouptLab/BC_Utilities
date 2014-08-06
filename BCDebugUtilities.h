//
//  BCDebugUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 14/8/4.
//
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (DebuggingExtensions)

- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender;

- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo;
@end

