//
//  BCXMLElement.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCXMLElement.h"

@implementation BCXMLElement

-(id)init; {
    
    return [self initWithName:nil andAttributes:nil];
}

-(id)initWithName:(NSString *)n andAttributes:(NSDictionary *)a; {
    
    self = [super init];
    if (self) {
        if (nil == n) {
            self.name = [NSString string];
        }
        else {
            self.name = n;
        }
        if (nil != a) {
            self.attributes = [NSMutableDictionary dictionaryWithDictionary:a];
        }
    }

    return self;
}

-(BOOL)hasAttributes; {
    if (nil == self.attributes || 0 == [self.attributes count]) {
        return NO;
    }
    return YES;
}

-(NSString *)attributeForKey:(NSString *)k; {

    if (!self.hasAttributes) {
        return nil;
    }
    return (NSString *)[self.attributes objectForKey:k];
    
}

-(BOOL)hasValue; {


    if (nil == self.value) {
        return NO;
    }
    if (kBCXMLElementArray == self.type) {

       return (0 < [(NSMutableArray *)(self.value) count]);

    }
    else if (kBCXMLElementDictionary == self.type) {

        return (0 < [(NSMutableDictionary *)(self.value) count]);

    }
    else if (kBCXMLElementString == self.type) {

        return (0 < [(NSString *)(self.value) length]);

    }
    
    return NO;
}


-(BCXMLElementType) type; {
    
    BCXMLElementType type = kBCXMLElementOther;
    
    if ([_value isKindOfClass:[NSArray class]]) {
        type = kBCXMLElementArray;
    }
    else     if ([_value isKindOfClass:[NSDictionary class]]) {
        type = kBCXMLElementDictionary;
    }
    else     if ([_value isKindOfClass:[NSString class]]) {
        type = kBCXMLElementString;
    }
    
    return type;
}

-(void)setElementType:(BCXMLElementType)type; {
    
    if (kBCXMLElementArray == type) {
        self.value = [NSMutableArray array];
    }
    else if (kBCXMLElementDictionary == type) {
        self.value = [NSMutableDictionary dictionary];
        
    }
    else if (kBCXMLElementString == type) {
        self.value = [NSString string];
    }
    else {
        self.value = nil;
    }
    
}

-(NSArray *)array; {
    if (kBCXMLElementArray == self.type) {
        return (NSArray *)(self.value);
    }
    return nil;
}

-(NSDictionary *)dictionary; {
    if (kBCXMLElementDictionary == self.type) {
        return (NSDictionary *)(self.value);
    }
    return nil;
}
-(NSString *)string; {
    if (kBCXMLElementString == self.type) {
        return (NSString *)(self.value);
    }
    return nil;
}

-(BOOL)isEmpty; {
    

    return (![self hasValue] && ![self hasAttributes] );

}

-(void)addSubElement:(BCXMLElement *)e; {
    
    if (kBCXMLElementArray == self.type) {
        [(NSMutableArray *)(self.value) addObject:e];
    }
    else if (kBCXMLElementDictionary == self.type) {
        [(NSMutableDictionary *)(self.value) setObject:e forKey:e.name];
    }
}
-(BCXMLElement *)elementForKey:(NSString *)n; {
    
    if (nil == self.value) { return nil; }

    if (kBCXMLElementDictionary != self.type) {
        return nil;
    }
    
    return [(NSMutableDictionary *)(self.value) objectForKey:n];
    
}
-(BCXMLElement *)elementAtIndex:(NSUInteger)i; {
    
    if (nil == self.value) { return nil; }
    
    if (kBCXMLElementArray != self.type) {
        return nil;
    }
    
    if ([(NSMutableArray *)(self.value) count] <= i) {
        return nil;
    }
    return [(NSMutableArray *)(self.value) objectAtIndex:i];
    
}


-(NSInteger)count; {
    
    if (nil == self.value) {
        return -1;
    }
    if (kBCXMLElementArray == self.type) {
        return ([(NSMutableArray *)(self.value) count]);
    }
    else if (kBCXMLElementDictionary == self.type) {
        return ([(NSMutableDictionary *)(self.value) count]);
        
    }
    else if (kBCXMLElementString == self.type) {
        return (1);
    }
    
    return NO;
    
}
-(NSInteger)length; {
    return [self count];
}

-(BCXMLElement *) elementAtKeyPath:(NSString *)path;{
    
    BCXMLElement *currentDictionaryElement = self;
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]];
    
    if ([(NSString *)[keys firstObject] isEqualToString:self.name]) {
        //skip first key
        [keys removeObject:[keys firstObject]];
    }
    
    for (NSString *eachKey in keys) {
        
        BCXMLElement *nextElement = [currentDictionaryElement elementForKey:eachKey];
        
        if (eachKey == [keys lastObject]) {
            return nextElement;
        }
        
        if (nextElement == nil) {
            
            return nextElement;
        }
        
        else if (kBCXMLElementDictionary != [nextElement type] ) {
            return nil;
        }
        
        currentDictionaryElement = nextElement;
    }
    
    return nil;
    
}

@end
