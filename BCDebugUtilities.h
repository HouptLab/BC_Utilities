//
//  BCDebugUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 14/8/4.
//
//

#import <Foundation/Foundation.h>

@interface NotificationObject : NSObject 

 @property NSString *name;
 @property  id  sender;
 
 -(id)initWithName:(NSString *)n andSender:(id)s;

@end

@interface NSNotificationCenter (DebuggingExtensions)

- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender;

- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo;
@end

