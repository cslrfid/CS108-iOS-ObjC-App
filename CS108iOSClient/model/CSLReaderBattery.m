//
//  CSLReaderBattery.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 1/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderBattery.h"

@implementation CSLReaderBattery

//static double _voltageFirstOffset;
//static double _voltagestep;
static NSArray* _voltageTable;
static NSArray* _capacityTable;
static NSMutableArray* _voltageSlope;
static BATTERYMODE _currentInventoryMode;
static double _pcbVersion;

- (id)init
{
    return [self initWithPcBVersion:1.8];
}

- (id) initWithPcBVersion:(double)pcbVersion {
    if (self = [super init]) {
        _pcbVersion=_pcbVersion;

        [self setBatteryMode:IDLE];
    }
    return self;
}

- (void) setPcbVersion:(double)pcbVersion {
    _pcbVersion=pcbVersion;
}


- (void) setBatteryMode: (BATTERYMODE) bm {
    
    int cnt;
    _currentInventoryMode = bm;

    if (bm == INVENTORY)
    {
        _voltageTable=[NSArray arrayWithObjects:@4.106f, @4.017f, @3.980f, @3.937f, @3.895f, @3.853f, @3.816f, @3.779f, @3.742f, @3.711f, @3.679f, @3.658f, @3.637f, @3.626f, @3.610f, @3.584f, @3.547f, @3.515f, @3.484f, @3.457f, @3.431f, @3.399f, @3.362f, @3.320f, @3.251f, @3.135f, nil];
        _capacityTable=[NSArray arrayWithObjects:@100.0f, @96.0f, @92.0f, @88.0f, @84.0f, @80.0f, @76.0f, @72.0f, @67.0f, @63.0f, @59.0f, @55.0f, @51.0f, @47.0f, @43.0f, @39.0f, @35.0f, @31.0f, @27.0f, @23.0f, @19.0f, @15.0f, @11.0f, @7.0f, @2.0f, @0.0f, nil];
        
        _voltageSlope=[[NSMutableArray alloc] init];
        for (cnt = 0; cnt <= [_voltageTable count] - 2; cnt++) {
            [_voltageSlope addObject:@(([[_capacityTable objectAtIndex:cnt] doubleValue] - [[_capacityTable objectAtIndex:cnt + 1] doubleValue]) / ([[_voltageTable objectAtIndex:cnt] doubleValue] - [[_voltageTable objectAtIndex:cnt + 1] doubleValue]))];
        }
    }
    else    //idle
    {
        _voltageTable=[NSArray arrayWithObjects:@4.212f, @4.175f, @4.154f, @4.133f, @4.112f, @4.085f, @4.069f, @4.054f, @4.032f, @4.011f, @3.990f, @3.969f, @3.953f, @3.937f, @3.922f, @3.901f, @3.885f, @3.869f, @3.853f, @3.837f, @3.821f, @3.806f, @3.790f, @3.774f, @3.769f, @3.763f, @3.758f, @3.753f, @3.747f, @3.742f, @3.732f, @3.721f, @3.705f, @3.684f, @3.668f, @3.652f, @3.642f, @3.626f, @3.615f, @3.605f, @3.594f, @3.584f, @3.568f, @3.557f, @3.542f, @3.531f, @3.510f, @3.494f, @3.473f, @3.457f, @3.436f, @3.410f, @3.362f, @3.235f, @2.987f, @2.982f, nil];
        _capacityTable=[NSArray arrayWithObjects:@100.0f, @98.0f, @96.0f, @95.0f, @93.0f, @91.0f, @89.0f, @87.0f, @85.0f, @84.0f, @82.0f, @80.0f, @78.0f, @76.0f, @75.0f, @73.0f, @71.0f, @69.0f, @67.0f, @65.0f, @64.0f, @62.0f, @60.0f, @58.0f, @56.0f, @55.0f, @53.0f, @51.0f, @49.0f, @47.0f, @45.0f, @44.0f, @42.0f, @40.0f, @38.0f, @36.0f, @35.0f, @33.0f, @31.0f, @29.0f, @27.0f, @25.0f, @24.0f, @22.0f, @20.0f, @18.0f, @16.0f, @15.0f, @13.0f, @11.0f, @9.0f, @7.0f, @5.0f, @4.0f, @2.0f, @0.0f, nil];

        _voltageSlope=[[NSMutableArray alloc] init];
        for (cnt = 0; cnt <= [_voltageTable count] - 2; cnt++) {
            [_voltageSlope addObject:@(([[_capacityTable objectAtIndex:cnt] doubleValue] - [[_capacityTable objectAtIndex:cnt + 1] doubleValue]) / ([[_voltageTable objectAtIndex:cnt] doubleValue] - [[_voltageTable objectAtIndex:cnt + 1] doubleValue]))];
        }
    }
    
}

- (int) getBatteryPercentageByVoltage: (double) voltage {
    
    int cnt;
    
    if (voltage > [[_voltageTable objectAtIndex:0] doubleValue])
        return 100;
    
    if (voltage <= [[_voltageTable objectAtIndex:[_voltageTable count]-1] doubleValue])
        return 0;
    
    for (cnt = (int)([_voltageTable count] - 2); cnt >= 0; cnt--) {
        if (voltage > [[_voltageTable objectAtIndex:cnt] doubleValue])
            continue;

        if (voltage == [[_voltageTable objectAtIndex:cnt] doubleValue])
            return [[_capacityTable objectAtIndex:cnt] intValue];

        double percent = 0;

        percent = (voltage - [[_voltageTable objectAtIndex:cnt+1] doubleValue]) * [[_voltageSlope objectAtIndex:cnt] doubleValue] + [[_capacityTable objectAtIndex:cnt+1] doubleValue];

        return percent;
    }
    
    return 0;
}

@end
