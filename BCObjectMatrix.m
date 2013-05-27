//
//  BCObjectMatrix.m
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import "BCObjectMatrix.h"
#include "BCArrayUtilities.h"

@implementation BCObjectMatrix

// parallel implementation of BCMatrix but using objects in an NSMutableArray instead of elements in void *buffer

// [myMatrix elementAtIndices:i,j,k]
// matrix object [i][j][k] is at bufferArray [ c[0] * i + c[1] * j + c[3] * k]
// internally: matrix object [i][j][k] is at bufferArray [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2])  ]


@synthesize dimension;
@synthesize buffer;
@synthesize c;
@synthesize index;


-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes; {
    
    
    assert( d == [sizes count]);
    // must have specificed a maximum size for each dimension of the matrix
    
    self = [super init];
    
    if (self) {
        
        dimension = d;
        
        c = malloc(sizeof(NSInteger) * dimension);
        // copy the maximum size for each dimension into the coeffecient array
        NSInteger i;
        for (i=0;i<[sizes count];i++) {
            c[i] = [[sizes objectAtIndex:i] intValue];
        }
        
        NSUInteger buffer_size = [self count];
        buffer = [NSMutableArray arrayWithCapacity:buffer_size];
        
        // make an array to hold the indices when dereferencing an element
        index = malloc(sizeof(NSInteger) * dimension);
        
        
    }
    
    return self;
    
}

-(void)dealloc; {
    // free the malloc'd buffers
    
    if (NULL != c) {  free(c); }
    if (NULL != index) {  free(index); }
    
}

-(NSInteger)count; {
     // total number of elements in matrix
    return (productOfIntArray(c, dimension));
    
}

-(id)objectAtIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // returns object at matrix[firstIndex,...]
    // note that this returns object reference, not a copy of the object    
    
    va_list argumentList;
    
    index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;
    
    while (NULL != argumentList) {
        // As many times as we can get an argument of type "NSInteger"
        // that isn't nil, add it to self's contents.
        index[currentIndex] = va_arg(argumentList, NSInteger);
        currentIndex++;
    }
    va_end(argumentList);
    
    NSUInteger offset_into_buffer = 0;
    NSInteger i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
        
    }
    
    return [buffer objectAtIndex:offset_into_buffer];
    
    
}

-(void)setObject:(id)object atIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // sets object into matrix[firstIndex,...]
    // of course, # indices should == dimension
    // but we can't check this ourselves
    
    
    va_list argumentList;
    
    index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;
    
    while (NULL != argumentList) {
        // As many times as we can get an argument of type "NSInteger"
        // that isn't nil, add it to self's contents.
        index[currentIndex] = va_arg(argumentList, NSInteger);
        currentIndex++;
    }
    va_end(argumentList);
    
    NSUInteger offset_into_buffer = 0;
    NSInteger i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
        
    }
    
    [buffer setObject:object atIndexedSubscript:offset_into_buffer];
    
    
}

@end
