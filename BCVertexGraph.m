//
//  BCVertexGraph.m
//  Xynk
//
//  Created by Tom Houpt on 13/11/8.
//
//

#import "BCVertexGraph.h"


@implementation BCVertex


-(BOOL)isEqualToVertex:(BCVertex *)otherVertex; {
    

    // NOTE: to make this really flexible,
    // should we check if otherVertex is same class as self?

    return [self isEqualToNumber:otherVertex];
}

@end

@implementation BCEdge

@synthesize vertex1;
@synthesize vertex2;

-(id)initWithStartVertex:(BCVertex *)s andEndVertex:(BCVertex *)e; {
    
    self = [super init];
    if (self) {
        vertex1 = s;
        vertex2 = e;
    }
    
    return self;
}


-(BOOL)isEqualToEdge:(BCEdge *)otherEdge; {
    return
    (
     [self containsVertex:[otherEdge vertex1]] && [self containsVertex:[otherEdge vertex2]]
     );
}


-(BOOL)containsVertex:(BCVertex *)v; {
    
    if ([[self vertex1] isEqualToVertex:v] || [[self vertex2] isEqualToVertex:v]) { return YES; }
    
    return NO;
}


-(NSString *)stringValue; {
    
    return [NSString stringWithFormat:@"[%@,%@]", [vertex1 stringValue], [vertex2 stringValue]];
    
}

@end


@implementation BCVertexGraph

/** to get clusters of non-different groups
 
 1. add vertices to graph
 2. make graph complete
 3. remove significant edges
 4. get completeSubGraphs
 5. assign same letter to each vertex in each subgraph
 
 */
@synthesize vertices;
@synthesize edges;

-(id)init; {
    
    self = [super init];
    if (self) {
        vertices = [[NSMutableSet alloc] init];
        edges = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)addVertex:(BCVertex *)v; {
    
    for (BCVertex *vertex in vertices) {
        if ([vertex isEqualToNumber:v]) {
            return;
        }
    }
    [vertices addObject:v];
}


-(void)addVertices:(NSSet *)newVertices; {
    
    for (BCVertex *v in newVertices) {
        [self addVertex:v];
    }
}


-(void)removeVertex:(BCVertex *)v; {
    
    for (BCVertex *vertex in vertices) {
        if ([vertex isEqualToVertex:v]) {
            
            [vertices removeObject:vertex];
            
            for (BCEdge *edge in edges) {
                if ([edge containsVertex:vertex]) {
                    [edges removeObject:edge];
                }
            }
        }
    }
}

-(void)removeVertices:(NSSet *)subVertices; {
    
    for (BCVertex *v in subVertices) {
        [self removeVertex:v];
    }
}



-(void)addEdge:(BCEdge *)e; {
    
    for (BCEdge *edge in edges) {
        if ([edge isEqualToEdge:e]) {
            return;
        }
    }
    [edges addObject:e];
    [vertices addObject: [e vertex1]];
    [vertices addObject: [e vertex2]];

}

-(void)addEdges:(NSSet *)newEdges;   {
    for (BCEdge *e in newEdges) {
        [self addEdge:e];
    }
}


-(void)removeEdge:(BCEdge *)e; {
    for (BCEdge *edge in edges) {
        if ([edge isEqualToEdge:e]) {
            [edges removeObject:edge];
        }
    }
}

-(void)removeEdges:(NSSet *)subsetEdges;   {
    for (BCEdge *e in subsetEdges) {
        [self removeEdge:e];
    }
}


-(void)makeVerticesOfCount:(NSInteger)count; {
    
   // discard any current vertices
    vertices = nil;
    vertices = [[NSMutableSet alloc] init];
    
    // discard any current edges
    edges = nil;
    edges = [[NSMutableSet alloc] init];
    
    for (NSInteger i=0; i<count;i++) {
        
        BCVertex *v = [[BCVertex alloc ] initWithInteger:i];
        
        [self addVertex:v];
    }
    
}


// add all possible edges between the current vertices to the graph
// (deletes and replaces any pre-existing edges)
-(void)makeCompleteEdges; {
    
    // discard any current edges
    edges = nil;
    edges = [[NSMutableSet alloc] init];
    
    // iterate through all the vertices, connecting them all
    // we're lazy, so we'll create redundant edges [a,b] and [b,a]
    // the addEdge: method will prevent multiple edges from being added
    for (BCVertex *v1 in vertices) {
        for (BCVertex *v2 in vertices) {
           BCEdge *e = [[BCEdge alloc] initWithStartVertex:v1 andEndVertex:v2];
            [self addEdge:e];
        }
    }
    
    
}



-(void)removeUnconnectedVertices; {
    
    // remove all vertices that are not start or end points of edges in the graph

    for (BCVertex *v in vertices) {
        
        BOOL vertexUsedByEdge = NO;
        for (BCEdge *e in edges) {
            
            if ( [e containsVertex:v] ) {
                vertexUsedByEdge = YES;
                break;
            }
        }
        
        if (!vertexUsedByEdge) {
            [vertices removeObject:v]; // removeVertex will also check
        }
        
    }
}


-(NSUInteger)size; {
    return [edges count];
}

#if 0
#error Unimplmented Methods ifdef-ed out to quiet warnings
// add all edges & vertices from other graph (if not already in self)
-(BCVertexGraph *)unionWithGraph:(BCVertexGraph *)otherGraph; {
    
}

// remove edges from self that are present in otherGraph
-(BCVertexGraph *)removeGraph:(BCVertexGraph *)otherGraph; {
    
}

// find edges and vertices that appear in both self and otherGraph
-(BCVertexGraph *)intersectWithGraph:(BCVertexGraph *)otherGraph; {
    
}

-(NSSet *)neighborsOfVertex:(BCVertex *)v; {
    
    NSMutableSet *neighborhood = [[NSMutableSet alloc] init];
    
    for (BCEdge *e in edges) {
        
        if ([e containsVertex:v]){
            
            BCVertex *neighbor;

            if (![v isEqualToVertex:[e vertex1]]) {
                neighbor = [e vertex1];
            }
            else {
                neighbor = [e vertex1];
            }
            
            BOOL vertexInSet = NO;
            for (BCVertex *n in neighborhood) {
                if ([neighbor isEqualToVertex:n]) {
                    vertexInSet = YES;
                }
            }
            if (!vertexInSet) {
                [neighborhood addObject:neighbor];
            }
        }
    }
    
    return neighborhood;
}

/** given the current edges, return an array of BCVertexGraphs
    which is the set of cliques or subgraphs, each of which is maximally complete
    (i.e. each vertex in the subgraph is connected to all other vertices in the subgraph)
    note that isolated vertices should be returned as a completeGraph
 
    This is the problem of listing all maximal cliques:
 
    http://en.wikipedia.org/wiki/Clique_problem#Listing_all_maximal_cliques
 
    Sounds like the Bron-Kerbosch algorithm is the best choice, especially when dealing with a small number of vertices
 
    http://en.wikipedia.org/wiki/Bron–Kerbosch_algorithm
 
    I think this would be easier to code in lisp...
 */
-(NSArray *)maximalCliques; {
    
/* setting R and X to be the empty set and P to be the vertex set of the graph.
    
    BronKerbosch1(R,P,X):
    if P and X are both empty:
        report R as a maximal clique
        for each vertex v in P:
            BronKerbosch1(R ⋃ {v}, P ⋂ N(v), X ⋂ N(v))
            P := P \ {v}
    X := X ⋃ {v}
*/
    
}
#endif





-(NSString *)verticesString; {
    
    NSString *stringValue = @"{ ";
    
    if (0 == [vertices count]) {
        
        stringValue = [stringValue stringByAppendingString:@"∅ "];
    }

    else {
        for (BCVertex *v in vertices) {
            
            stringValue = [stringValue stringByAppendingString:[v stringValue] ];
            
            stringValue = [stringValue stringByAppendingString:@", "];
        }
        
        // NOTE: truncate final string by 2 characters (@", ")
    }
    
    stringValue = [stringValue stringByAppendingString:@"}"];

    return stringValue;
}


-(NSString *)edgesString;  {
    
    NSString *stringValue = @"{ ";
    
    if (0 == [edges count]) {
        
        stringValue = [stringValue stringByAppendingString:@"∅ "];
    }
    
    else {

        for (BCEdge *e in edges) {
            
            stringValue = [stringValue stringByAppendingString:[e stringValue] ];
            
            stringValue = [stringValue stringByAppendingString:@", "];
        }

        // NOTE: truncate final string by 2 characters (@", ")
    }
    
    stringValue = [stringValue stringByAppendingString:@"}"];

    return stringValue;
}


@end
