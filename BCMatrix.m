//
//  BCMatrix.m
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import "BCMatrix.h"
#include "BCArrayUtilities.h"


@implementation BCMatrix

// [myMatrix elementAtIndices:i,j,k]
// matrix element [i][j][k] is at buffer [ c[0] * i + c[1] * j + c[3] * k]
// internally: matrix element [i][j][k] is at buffer [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2]) * elementSize ]


@synthesize dimension;
@synthesize elementSize;
@synthesize buffer;
@synthesize c;
@synthesize dimensionSizes;
@synthesize index;


-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes forElementSize:(size_t)iS; {
    
    
    assert( d == [sizes count]);
    // must have specificed a maximum size for each dimension of the matrix
    
    self = [super init];
    
    if (self) {
        
        buffer = NULL;
        c = NULL;
        index = NULL;
        dimensionSizes = NULL;
        
        dimension = d;
        
        c = malloc(sizeof(NSInteger) * dimension);
        dimensionSizes = malloc(sizeof(NSInteger) * dimension);
        // copy the maximum size for each dimension into the dimensionSizes array
        int i;
        for (i=0;i<[sizes count];i++) {
            dimensionSizes[i] = [[sizes objectAtIndex:i] intValue];
        }

        // generate the coeffecient array as a product of the lower dimensions

        c[0] = 1;
        for (i=1;i<dimension;i++) {
            c[i] = dimensionSizes[i-1] * c[i-1];
        }
              
        elementSize = iS;
        size_t buffer_size = [self count];
        buffer = malloc(elementSize * buffer_size);
        
        // make an array to hold the indices when dereferencing an element
        index = malloc(sizeof(NSInteger) * dimension);
        
        
    }
    
    return self;
    
}

-(void)dealloc; {
    // free the malloc'd buffers

    if (NULL != buffer) {  free(buffer); }
    if (NULL != dimensionSizes) {  free(dimensionSizes); }
    if (NULL != c) {  free(c); }
    if (NULL != index) {  free(index); }
    
}

-(NSInteger)count; {
    // total number of elements in matrix

    return (productOfIntArray(dimensionSizes, dimension));
    
}

-(void *)copyOfElementAtIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // returns ptr to new malloc'd block of data with copy ofelement at matrix[firstIndex,...]
    // caller is responsible for free'ing this block
    

    va_list argumentList;
    
    index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;
    
    while (currentIndex < dimension) {
        // As many times as we can get an argument of type "NSInteger"
        // that isn't nil, add it to self's contents.
        index[currentIndex] = va_arg(argumentList, NSInteger);
        if (index[currentIndex] >= dimensionSizes[currentIndex]){
            NSLog(@"BCMatrix currentIndex:%ld index[] = %ld dimensionSizes[] = %ld", (long)currentIndex,  (long)index[currentIndex], (long)dimensionSizes[currentIndex]);
        }
        assert( index[currentIndex] < dimensionSizes[currentIndex]);
        if (index[currentIndex] >= dimensionSizes[currentIndex]) {
            NSLog(@"BCMatrix copyElement:Out of bounds index: %zd", (long)currentIndex);
            return NULL;
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    size_t offset_into_buffer = 0;
    int i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
        
    }
    
    assert(offset_into_buffer < [self count]);
//    NSLog(@"BCMatrix copyElement [%zd,%zd] offset: %zd",(long)index[0],(long)index[1],offset_into_buffer);

    offset_into_buffer *= elementSize;
    
    void *elementCopy = malloc(elementSize);
    
    memcpy(elementCopy,&(buffer[offset_into_buffer]),elementSize );
    
    return (elementCopy);
    
    
}

-(void)setElement:(void *)element atIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // copies element at address *element into matrix[firstIndex,...]
    // of course, # indices should == dimension
    // element should be same size as elementSize
    // but we can't check this ourselves

    
    va_list argumentList;
    
    index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;

    while (currentIndex < dimension) {
        // get as many arguments of type "NSInteger"
        // as we have dimensions
        index[currentIndex] = va_arg(argumentList, NSInteger);
        assert( index[currentIndex] < dimensionSizes[currentIndex]);
        if (index[currentIndex] >= dimensionSizes[currentIndex]) {
            NSLog(@"BCMatrix setElement Out of bounds index: %zd", (long)currentIndex);
            return;
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    size_t offset_into_buffer = 0;
    int i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
    }
    
    
    assert(offset_into_buffer < [self count]);

// NSInteger myCount = [self count];
//    NSLog(@"dimension = %zd",dimension);
//    NSLog(@"dimensionSizes[0] = %zd",dimensionSizes[0]);
//    NSLog(@"dimensionSizes[1] = %zd",dimensionSizes[0]);
//    NSLog(@"count = %zd",myCount);
//     NSLog(@"offset_into_buffer = %zd",offset_into_buffer);
//   NSLog(@"BCMatrix setElement [%zd,%zd] offset: %zd",(long)index[0],(long)index[1],offset_into_buffer);

    
    offset_into_buffer *= elementSize;
    
    memcpy(&(buffer[offset_into_buffer]),element,elementSize);

}

-(NSInteger)sumIntegerMatrix; {
    
    assert(elementSize == sizeof(NSInteger));
    
    NSInteger sum = 0;
    NSInteger numberOfElements = [self count];
    NSInteger i;
    NSInteger *intBuffer = (NSInteger *)buffer;
    for (i=0;i<numberOfElements;i++) {
        
        sum+= intBuffer[i];
    }
    
    return sum;
}
-(double)sumDoubleMatrix; {
    
    assert(elementSize == sizeof(double));

    double sum = 0.0;
    NSInteger numberOfElements = [self count];
    NSInteger i;
    double *doubleBuffer = (double *)buffer;
    for (i=0;i<numberOfElements;i++) {
        
        sum+= doubleBuffer[i];
    }
    
    return sum;
}


@end