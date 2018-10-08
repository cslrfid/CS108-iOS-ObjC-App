//
//  CSLReaderSettings.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 20/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderSettings.h"

@implementation CSLReaderSettings

@synthesize power;
@synthesize session;
@synthesize target;
@synthesize algorithm;
@synthesize linkProfile;
@synthesize tagPopulation;
@synthesize QValue;
@synthesize isQOverride;
@synthesize enableSound;

-(id)init {
    if (self = [super init])  {
        //set default values
        self.tagPopulation=30;
        self.isQOverride=false;
        self.QValue=6;
        self.power = 300;
        self.session = S1;
        self.target = ToggleAB;
        self.algorithm = DYNAMICQ;
        self.linkProfile=RANGE_DRM;
        self.enableSound=true;
    }
    return self;
}


@end
