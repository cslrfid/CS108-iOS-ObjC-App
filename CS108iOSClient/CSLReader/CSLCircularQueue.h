//
//  CSLCircularQueue.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 12/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSLCircularQueue : NSObject <NSFastEnumeration>

@property (nonatomic, assign, readonly) NSUInteger capacity;
@property (nonatomic, assign, readonly) NSUInteger count;

- (id)initWithCapacity:(NSUInteger)capacity;

- (void)enqObject:(id)obj; // Enqueue
- (id)deqObject;           // Dequeue

- (id)objectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;

@end


