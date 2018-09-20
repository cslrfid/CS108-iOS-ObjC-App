//
//  CSLRfidAppEngine.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSLBleReader.h"
#import "CSLBleTag.h"
#import "CSLBlePacket.h"

@interface CSLRfidAppEngine : NSObject
{
    
    
}
@property CSLBleReader* reader;

+ (CSLRfidAppEngine *) sharedAppEngine;
+ (id)alloc;
+ (void)destroy;
- (id)init;
- (void)dealloc;

@end
