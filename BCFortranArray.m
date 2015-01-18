//
//  BCFortranArray.m
//  MindsEye
//
//  Created by Tom Houpt on 5/9/13.
//  Copyright (c) 2013 BehavioralCybernetics LLC. All rights reserved.
//

#import "BCFortranArray.h"

@implementation BCFortranArray

@synthesize dimension;
@synthesize max_x;
@synthesize max_y;
@synthesize arrayType;
@synthesize buffer;

-(id)init1DWithMaxX:(NSUInteger)x; {
    
    return ( [self initWithDimension:1 andMaxX:x andMaxY:1]);
    
}

-(id)init2DWithMaxX:(NSUInteger)x andMaxY:(NSUInteger)y; {
    
    return ( [self initWithDimension:2 andMaxX:x andMaxY:y]);
    
}
-(id)initWithDimension:(NSUInteger)d andMaxX:(NSUInteger)x andMaxY:(NSUInteger)y; {
    
    
    assert (d == 1 || d == 2);
    assert (max_x > 0);
    assert (max_y > 0);
    
    self = [super init];
    
    if (self){
        
        dimension = d;
        max_x = x;
        max_y = y;
        
        [self initType];
        
        buffer = malloc([self sizeOfElements]* max_x * max_y);
        
        if (NULL == buffer) { return nil; }
       
    }
    
    return self;
    
}

-(void)dealloc; {
    
    free(buffer);
    
}


-(NSUInteger)sizeOfElements; { return sizeof(NSInteger); }

-(void)initType; { self.arrayType = kIntegerArray; }

@end

@implementation BCFortranIntegerArray

-(NSUInteger)sizeOfElements; { return sizeof(NSInteger); }
-(void)initType; { self.arrayType = kIntegerArray; }


-(NSInteger)valueAtX:(NSUInteger)x; {
    
    assert( 1 <= x && x <= self.max_x); // FORTRAN arrays are 1 indexed
    assert(1 == self.dimension);
    
    return ((NSInteger *)self.buffer)[(x-1)];
    
} 
-(NSInteger)valueAtX:(NSUInteger)x andY:(NSUInteger)y; {
    
    // FORTRAN arrays are 1 indexed
    assert (1 <= x && x <= self.max_x);
    assert (1 <= y && y <= self.max_y);
    assert(2 == self.dimension);

    
    return ((NSInteger *)self.buffer)[(x-1) + ((y-1) * self.max_x)];

}

-(void)setX:(NSUInteger)x toValue:(NSInteger)v; {
    
    // FORTRAN arrays are 1 indexed
    assert( 1 <= x && x <= self.max_x);
    assert(1 == self.dimension);

    ((NSInteger *)self.buffer)[(x-1)] = v;
    
    
}
-(void)setX:(NSUInteger)x andY:(NSUInteger)y toValue:(NSInteger)v; {
    
    // FORTRAN arrays are 1 indexed
    assert (1 <= x && x <= self.max_x);
    assert (1 <= y && y <= self.max_y);
    assert(2 == self.dimension);


    ((NSInteger *)self.buffer)[(x-1) + ((y-1) * self.max_x)] = v;
    
}


@end

@implementation BCFortranDoubleArray

-(NSUInteger)sizeOfElements; { return sizeof(double); }
-(void)initType; { self.arrayType = kDoubleArray; }


-(double)valueAtX:(NSUInteger)x; {
    
    // FORTRAN arrays are 1 indexed
    assert( 1 <= x && x <= self.max_x); 
    assert(1 == self.dimension);
    
    return ((double *)self.buffer)[(x-1)];
    
}
-(double)valueAtX:(NSUInteger)x andY:(NSUInteger)y; {
    
    // FORTRAN arrays are 1 indexed
    assert (1 <= x && x <= self.max_x);
    assert (1 <= y && y <= self.max_y);
    assert(2 == self.dimension);
    
    return ((double *)self.buffer)[(x-1) + ((y-1) * self.max_x)];
    
}

-(void)setX:(NSUInteger)x toValue:(double)v; {
    
    // FORTRAN arrays are 1 indexed
    assert( 1 <= x && x <= self.max_x);
    assert(1 == self.dimension);
    
    ((double *)self.buffer)[(x-1)] = v;
    
    
}
-(void)setX:(NSUInteger)x andY:(NSUInteger)y toValue:(double)v; {
    
    // FORTRAN arrays are 1 indexed
    assert (1 <= x && x <= self.max_x);
    assert (1 <= y && y <= self.max_y);
    assert(2 == self.dimension);
    
    ((double *)self.buffer)[(x-1) + ((y-1) * self.max_x)] = v;
    
}

@end