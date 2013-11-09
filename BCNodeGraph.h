//
//  BCVertexGraph.h
//  Xynk
//
//  Created by Tom Houpt on 13/11/8.
//
//

#import <Foundation/Foundation.h>

@interface BCVertex: NSNumber {
    
}

/** determine if value of vertex is equal to given vertex
 
 a base BCVertex is identified as an integer NSNumber
 but could override this  method in a subclass if vertex is identified
 by something more complicated than just a number
 (i.e. by some other type of key)

 */
-(BOOL)isEqualToVertex:(BCVertex *)otherVertex;

@end

/** a base edge is a pair of NSVertices
 currently edges are undirected
 */
@interface BCEdge : NSObject {
    
}


@property BCVertex *node1;
@property BCVertex *node2;

-(id)initWithStartVertex:(BCVertex *)s andEndVertex:(BCVertex *)e;

/** test if the given edge has the same start/end vertices as the edge
 (because edges are undirected, edge can match in either direction)
 this method could be subclassed to accomodate directed edges
 */
-(BOOL)isEqualToEdge:(BCEdge *)otherEdge;

/** test if the given vertex is either the start or end vertex of the edge
 */
-(BOOL)containsVertex:(BCVertex *)v;

/** text representation of the edge
 e.g. @"[1,2]
 relies of [BCVertex stringValue] method for representation of the vertices in the edge
 
 @return NSString with text representation of edge
 */
-(NSString *)stringValue;

@end

/** BCVertexGraph is a collection of BCVertexs and undirected NSEdges between the vertices

    a vertex can be represented only once in the graph
    an edge can be represented only once in the graph (no multiple edges)
    all vertices that are part of edges are part of the graph
    a vertex can be in the graph and yet not be part of any graph (i.e., unconnected vertices are permitted)
    loops are allowed if specified by an edge joining the same vertex at each end
 
 
 */
@interface BCVertexGraph : NSObject {
    
}



@property NSMutableSet *vertices;
/** an array of tuples [node_i,node_j] representing edges between 2 vertices
*/
@property NSMutableSet *edges;

///---------------------------------------------------------------------------------------
/// @name Initializing,
///---------------------------------------------------------------------------------------


/** a new empty BCVertexGraph
*/
-(id)init;

///---------------------------------------------------------------------------------------
/// @name setting Vertices & Edges
///---------------------------------------------------------------------------------------

-(void)addVertex:(BCVertex *)v;
-(void)addVertices:(NSSet *)newVertices;

/** removing a vertex automatically removes all edges attached to that vertex
 */

-(void)removeVertex:(BCVertex *)v;
-(void)removeVertices:(NSSet *)subVertices;

/** adding an edge automatically adds the vertices of the edge to the graph
 */
-(void)addEdge:(BCEdge *)e;
-(void)addEdges:(NSSet *)newEdges;

/** removing an edge does NOT remove the vertices of the edge
 */
-(void)removeEdge:(BCEdge *)e;
-(void)removeEdges:(NSSet *)subsetEdges;


/** create and add a bunch of vertices labeled 0...n
 (deletes and replaces any pre-existing vertices, and deletes any edges)
 
 */
-(void)makeVerticesOfCount:(NSInteger)count;

/** add all possible edges between the current vertices to the graph
 e.g., if we have vertices { 1, 2, 3}
 then add edges {[1,2], [1,3], [2,3] }
 (deletes and replaces any pre-existing edges)
 */
-(void)makeCompleteEdges;

/** remove all vertices that are not start or end points of edges in the graph
 (i.e. isolated vertices without connections to other vertices)
 NB: self-connected vertices will NOT be removed, because they are part of an edge
 
 */
-(void)removeUnconnectedVertices;


///---------------------------------------------------------------------------------------
/// @name Graph Manipulations
///---------------------------------------------------------------------------------------

/** return the size of the graph (i.e. the number of edges)
 
 @return NSUInteger size of the graph
 */
-(NSUInteger)size;



/** get the complement of the current graph
 
    the complement of a graph has the same vertex set but every edge in the original graph is NOT in the complement, and every edge NOT in the original graph IS in the complement
 
 */


/** add all edges & vertices from other graph (if not already in self)
 
 */
-(BCVertexGraph *)unionWithGraph:(BCVertexGraph *)otherGraph;

/** remove edges that from self that are present in otherGraph
 
 @return a new BCVertexGraph with vertices & edges that appear in self but not otherGraph
 
 */
-(BCVertexGraph *)removeGraph:(BCVertexGraph *)otherGraph;

/** find edges and vertices that appear in both self and otherGraph
 
 @return a new BCVertexGraph with vertices & edges that appeared in both self and other graph
 
 */
-(BCVertexGraph *)intersectWithGraph:(BCVertexGraph *)otherGraph;

/** find the open neighborhood of the given vertex
 
    the set of vertices that are connected by an edge with v (set does not include v itself)
 
 */
-(NSSet *)neighborsOfVertex:(BCVertex *)v;




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
-(NSArray *)maximalCliques;


/** text representation of vertices of the graph
 e.g. @"1,2,3"
 uses [BCVertex stringValue] of individual vertices,
 so can override [BCVertex stringValue] method to get different format
 
 @return an NSString listing the vertices
 */
-(NSString *)verticesString;

/** text representation of edges of the graph
 e.g. @"[1,2], [1,3], [2,3]"
 uses [BCEdge stringValue] of individual edges,
 so can override [BCEdge stringValue] method to get different format
 
 @return an NSString listing the edges
 */
-(NSString *)edgesString;

@end
