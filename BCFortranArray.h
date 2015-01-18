//
//  BCFortranArray.h
//  MindsEye
//
//  Created by Tom Houpt on 5/9/13.
//  Copyright (c) 2013 BehavioralCybernetics LLC. All rights reserved.
//


#import <Foundation/Foundation.h>

enum {kIntegerArray, kDoubleArray};

@interface BCFortranArray : NSObject

/* utility classes for managing 1 or 2 dimensional double/integer arrays
 
  data stored in malloc'd unsigned char *buffer, with 2D array stored like pixels in an image (i.e. y sequential rows of x size each)
 
 For compatiblity with ported FORTRAN code, array elements are accessed using 1-indexing (not 0-indexing)
 e.g. [NSFortranArray valueAtX:1] returns buffer[0]
 e.g. [NSFortranArray valueAtX:max_x] returns buffer[max_x-1]
 
*/


@property (assign) NSUInteger dimension;
@property (assign) NSUInteger max_x;
@property (assign) NSUInteger max_y;
@property (assign) NSInteger arrayType;
@property (assign) unsigned char *buffer;

-(id)init1DWithMaxX:(NSUInteger)x;
-(id)init2DWithMaxX:(NSUInteger)x andMaxY:(NSUInteger)y;
-(id)initWithDimension:(NSUInteger)d andMaxX:(NSUInteger)x andMaxY:(NSUInteger)y;
-(void)dealloc;

-(NSUInteger)sizeOfElements; 

@end


@interface BCFortranIntegerArray : BCFortranArray 
    
-(NSUInteger)sizeOfElements;
-(void)initType; 

-(NSInteger)valueAtX:(NSUInteger)x;
-(NSInteger)valueAtX:(NSUInteger)x andY:(NSUInteger)y;

-(void)setX:(NSUInteger)x toValue:(NSInteger)v;
-(void)setX:(NSUInteger)x andY:(NSUInteger)y toValue:(NSInteger)v;


@end

@interface BCFortranDoubleArray : BCFortranArray


-(NSUInteger)sizeOfElements;
-(void)initType; 

-(double)valueAtX:(NSUInteger)x;
-(double)valueAtX:(NSUInteger)x andY:(NSUInteger)y;

-(void)setX:(NSUInteger)x toValue:(double)v;
-(void)setX:(NSUInteger)x andY:(NSUInteger)y toValue:(double)v;


@end