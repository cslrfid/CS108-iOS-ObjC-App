//
//  CSLCircularQueue.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 12/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Circular queue for storing tag response data
 */
@interface CSLCircularQueue : NSObject <NSFastEnumeration>

///Define the maximum number of elements that the instance can hold
@property (nonatomic, assign, readonly) NSUInteger capacity;
///Number of element that the instance is holding
@property (nonatomic, assign, readonly) NSUInteger count;

///Initializing the instance with a defined capacity
- (id)initWithCapacity:(NSUInteger)capacity;

///Enqueu object into the queue
- (void)enqObject:(id)obj; // Enqueue
/**Dnqueu object from the queue
 @return id Reference to the returned object
 */
- (id)deqObject;           // Dequeue
/**Return reference to a specific object in the queue
  @return id Reference to the returned object
 */
- (id)objectAtIndex:(NSUInteger)index;
/**Remove all objects in queue
 */
- (void)removeAllObjects;

@end


