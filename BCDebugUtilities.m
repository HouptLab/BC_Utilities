//
//  BCDebugUtilities.m
//  Xynk
//
//  Created by Tom Houpt on 14/8/4.
//
//

#import "BCDebugUtilities.h"

@implementation NotificationObject  


 
 -(id)initWithName:(NSString *)n andSender:(id)s; {
 
 self = [super init];
 if (self) {
    _name = n;
    _sender = s;
 
 }
 
 return self;
 }

@end

@implementation NSNotificationCenter (DebuggingExtensions)

-(NSMutableArray *)notificationStack; { return notificationStack; }

-(void)setNotificationStack:(NSMutableArray *)ns; { 

    // ignore

}

NSMutableArray *notificationStack; 
 // keep a stack of how deep out notifications have gotten when debugging...
 
- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender; {


#ifdef DEBUG    

    assert(false);
    
    if (nil == notificationStack) {
        notificationStack = [NSMutableArray array];    
    }
    
    [notificationStack addObject: [[NotificationObject alloc] initWithName:notificationName andSender:notificationSender]];

    NSLog(@"level: %ld notification: %@", [notificationStack count], notificationName);
#endif
    [self postNotificationName:notificationName object:notificationSender];
    
#ifdef DEBUG
     [notificationStack removeObject: [notificationStack  lastObject]];
#endif
}

- (void)debugPostNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo; {


    
#ifdef DEBUG

assert(nil != userInfo);
assert(nil != [userInfo objectForKey:@"sender"]);

if (nil == notificationStack) {
        notificationStack = [NSMutableArray array];    
    }
    

    
    [notificationStack addObject: [[NotificationObject alloc] initWithName:notificationName andSender:notificationSender]];
    
       NSLog(@"level: %ld notification: %@", [notificationStack count], notificationName);
#endif

BOOL different_objects = true;
for (NotificationObject *note in notificationStack) {
    different_objects  = ([note sender] != [[notificationStack firstObject] sender]);
}
assert(1 >= [notificationStack count] || different_objects);

    
    [self postNotificationName:notificationName object:notificationSender userInfo:userInfo];
    
#ifdef DEBUG
     [notificationStack removeObject: [notificationStack  lastObject]];
#endif
    
    
}

@end



#ifdef DEBUG
#	define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DebugLog(...)
#endif
