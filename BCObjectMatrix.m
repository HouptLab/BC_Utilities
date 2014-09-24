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
@synthesize dimensionSizes;

-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes; {
    
    assert( d == [sizes count]);
    // must have specificed a maximum size for each dimension of the matrix
    
    self = [super init];
    
    if (self) {
        
        c= NULL;
        dimensionSizes = NULL;
        index = NULL;
        
        dimension = d;
        
        dimensionSizes = calloc(dimension, sizeof(NSInteger));

        // copy the maximum size for each dimension into the coeffecient array
        for (int i=0;i<[sizes count];i++) {
            dimensionSizes[i] = [[sizes objectAtIndex:i] intValue];
        }
        
        // generate the coeffecient array as a product of the lower dimensions
        c = calloc(dimension, sizeof(NSInteger) );
        c[0] = 1;
        for (int i=1;i<dimension;i++) {
            c[i] = dimensionSizes[i-1] * c[i-1];
        }

        NSUInteger buffer_size = [self count];
        buffer = [NSMutableArray arrayWithCapacity:buffer_size];
        // initialize the content of the matrix with [NSNumber numberWithInteger:0]
        // this will make sure the buffer actually has all array elements allocated and available for replacement
        
        NSNumber *zeroNumber = [NSNumber numberWithInteger:0];
        for (int i=0; i< buffer_size; i++) {
            [buffer addObject:zeroNumber];
        }
        
        // make an array to hold the indices when dereferencing an element
        index = calloc(dimension, sizeof(NSInteger));
        
    }
    
    return self;
    
}

-(void)dealloc; {
    // free the malloc'd buffers
    
    if (NULL != dimensionSizes ) {  free(dimensionSizes); }
    if (NULL != c) {  free(c); }
    if (NULL != index) {  free(index); }
    
}

-(NSInteger)count; {
     // total number of elements in matrix
    return (productOfIntArray(dimensionSizes, dimension));
    
}

-(id)objectAtIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // returns object at matrix[firstIndex,...]
    // note that this returns object reference, not a copy of the object    
    
    va_list argumentList;
    
    index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;
    
    while (currentIndex < dimension) {
        // As many times as we can get an argument of type "NSInteger"
        // that isn't nil, add it to self's contents.
        index[currentIndex] = va_arg(argumentList, NSInteger);
        if (index[currentIndex] >= dimensionSizes[currentIndex]){
            NSLog(@"BCObjectMatrix currentIndex:%ld index[] = %ld dimensionSizes[] = %ld", (long)currentIndex,  (long)index[currentIndex], (long)dimensionSizes[currentIndex]);
        }
        assert( index[currentIndex] < dimensionSizes[currentIndex]);
        if (index[currentIndex] >= dimensionSizes[currentIndex]) {
            NSLog(@"BCObjectMatrix objectAtIndices out of bounds index: %zd", (long)currentIndex);
            return NULL;
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    NSUInteger offset_into_buffer = 0;
    NSInteger i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
        
    }
    
    
    assert(offset_into_buffer < [self count]);

// NSInteger myCount = [self count];
//    NSLog(@"dimension = %zd",dimension);
//    NSLog(@"dimensionSizes[0] = %zd",dimensionSizes[0]);
//    NSLog(@"dimensionSizes[1] = %zd",dimensionSizes[0]);
//    NSLog(@"count = %zd",myCount);
//    NSLog(@"offset_into_buffer = %zd",offset_into_buffer);
//    NSLog(@"BCObjectMatrix  objectAtIndices [%zd,%zd] offset: %zd",(long)index[0],(long)index[1],offset_into_buffer);

    
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
    
    while (currentIndex < dimension) {
        // As many times as we can get an argument of type "NSInteger"
        // that isn't nil, add it to self's contents.
        index[currentIndex] = va_arg(argumentList, NSInteger);
        assert( index[currentIndex] < dimensionSizes[currentIndex]);
        if (index[currentIndex] >= dimensionSizes[currentIndex]) {
            NSLog(@"BCObjectMatrix setObject:AtIndices out of bounds index: %zd", (long)currentIndex);
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    NSUInteger offset_into_buffer = 0;
    NSInteger i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
        
    }
    
    
    assert(offset_into_buffer < [self count]);
//     NSInteger myCount = [self count];
//    NSLog(@"dimension = %zd",dimension);
//    NSLog(@"dimensionSizes[0] = %zd",dimensionSizes[0]);
//    NSLog(@"dimensionSizes[1] = %zd",dimensionSizes[0]);
//    NSLog(@"count = %zd",myCount);
//    NSLog(@"offset_into_buffer = %zd",offset_into_buffer);
//    NSLog(@"BCObjectMatrix  setObject:atIndices: [%zd,%zd] offset: %zd",(long)index[0],(long)index[1],offset_into_buffer);

    
    [buffer replaceObjectAtIndex:offset_into_buffer withObject:object];
    
    
}

@end
