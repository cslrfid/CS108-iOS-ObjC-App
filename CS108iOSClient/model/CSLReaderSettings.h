//
//  CSLReaderSettings.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 20/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSLBleReader.h"



@interface CSLReaderSettings : NSObject
{
    int power;
    int tagPopulation;
    BOOL isQOverride;
    int QValue;
    SESSION session;
    TARGET target;
    QUERYALGORITHM algorithm;
    LINKPROFILE linkProfile;
    BOOL enableSound;
    
}

@property (assign) int power;
@property (assign) int tagPopulation;
@property (assign) BOOL isQOverride;
@property (assign) int QValue;
@property (assign) SESSION session;
@property (assign) TARGET target;
@property (assign) QUERYALGORITHM algorithm;
@property (assign) LINKPROFILE linkProfile;
@property (assign) BOOL enableSound;

@end
