//
//  CSLRfidAppEngine.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLRfidAppEngine.h"

CSLRfidAppEngine * appEngine;

@interface CSLRfidAppEngine()
{
    CSLBleReader* reader;

}
@end

@implementation CSLRfidAppEngine

@synthesize reader;

+ (CSLRfidAppEngine *) sharedAppEngine
{
    @synchronized([CSLRfidAppEngine class])
    {
        if (appEngine == nil)
        {
            [[self alloc] init];
        }
        
        return appEngine;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([appEngine class])
    {
        NSAssert(appEngine == nil, @"Attempted to allocate a second instance of a singleton.");
        appEngine = [super alloc];
        return appEngine;
    }
    return nil;
}

+(void)destroy
{
    @synchronized([appEngine class])
    {
        if (appEngine != nil)
        {
            appEngine = nil;
        }
    }
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        NSLog(@"----------------------------------------------------------------------");
        NSLog(@"Initialize the CSLBleReader object instance...");
        NSLog(@"----------------------------------------------------------------------");
        reader = [[CSLBleReader alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    
}


@end
