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
        //I150, 160, 170....
        for (int n = 0; n < 16; n++)
            [self.powerLevel addObject:[NSString stringWithFormat:@"%d", 150+n*10]];
        self.dwellTime = [NSMutableArray array];
        //Set dwell time to 200ms for all ports
        for (int n = 0; n < 16; n++)
            [self.dwellTime addObject:@"200"];
        //For CS463, disable all ports except port 0
        [self.isPortEnabled addObject:[[NSNumber alloc] initWithBool:TRUE]];
        for (int n = 1 ; n < 4; n++)
            [self.isPortEnabled addObject:[[NSNumber alloc] initWithBool:FALSE]];
    }
    return self;
}


@end
