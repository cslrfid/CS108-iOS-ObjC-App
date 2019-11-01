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
        self.isMultibank1Enabled=false;
        self.multibank1=TID;
        self.multibank1Offset=0;
        self.multibank1Length=2;
        self.isMultibank2Enabled=false;
        self.multibank2=USER;
        self.multibank2Offset=0;
        self.multibank2Length=2;
        self.numberOfPowerLevel=16;
        self.powerLevel = [NSMutableArray array];
        //150, 160, 170....
        for (int n = 0; n < 16; n++)
            [self.powerLevel addObject:@(150+n*10)];
        self.dwellTime = [NSMutableArray array];
        for (int n = 0; n < 16; n++)
            [self.dwellTime addObject:@(200)];
    }
    return self;
}


@end
