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

/*
- (void) setBatteryMode: (BATTERYMODE) bm {
    
    int cnt;
    _currentInventoryMode = bm;
   
    // battery table for PCB version below 1.8
    if (_pcbVersion < 1.8)
    {
        _voltageFirstOffset = 100.0 / 90 * 5;
        _voltageTable=[NSArray arrayWithObjects:@3.4f, @3.457f, @3.468f, @3.489f, @3.494f, @3.515f, @3.541f, @3.566f, @3.578f, @3.610f, @3.615f, @3.668f, @3.7f, @3.731f, @3.753f, @3.790f, @3.842f, @3.879f, @4.0f, nil];
        _voltagestep=(100.0 - _voltageFirstOffset) / ([_voltageTable count] - 2);
        _voltageSlope=[[NSMutableArray alloc] init];
        for (cnt = 0; cnt < [_voltageTable count] - 1; cnt++) {
            [_voltageSlope addObject:@(_voltagestep / ([[_voltageTable objectAtIndex:(cnt + 1)] doubleValue] - [[_voltageTable objectAtIndex:cnt] doubleValue]))];
        }
    }
    else
    {
        // battery table for PCB version 1.8 or above and inventory mode
        if (bm == INVENTORY)
        {
            _voltageFirstOffset = 100.0 / 134 * 4;
            _voltageTable=[NSArray arrayWithObjects:@2.789f, @3.304f, @3.452f, @3.489f, @3.515f, @3.534f, @3.554f, @3.563f, @3.578f, @3.584f, @3.594f, @3.61f, @3.625f, @3.652f, @3.652f, @3.673f, @3.7f, @3.725f, @3.747f, @3.769f, @3.8f, @3.826f, @3.858f, @3.89f, @3.972f, @3.964f, @4.001f, @4.069f, nil];
            _voltagestep=(100.0 - _voltageFirstOffset) / ([_voltageTable count] - 2);
            _voltageSlope=[[NSMutableArray alloc] init];
            for (cnt = 0; cnt < [_voltageTable count] - 1; cnt++) {
                [_voltageSlope addObject:@(_voltagestep / ([[_voltageTable objectAtIndex:(cnt + 1)] doubleValue] - [[_voltageTable objectAtIndex:cnt] doubleValue]))];
            }
        }
        // battery table for PCB version 1.8 or above and idle mode
        else
        {
            _voltageFirstOffset = 100.0 / 534 * 4;
            _voltageTable=[NSArray arrayWithObjects:@2.322f, @3.156f, @3.452f, @3.563f, @3.605f, @3.626f, @3.631f, @3.642f, @3.652f, @3.668f, @3.679f, @3.689f, @3.700f, @3.705f, @3.710f, @3.716f, @3.721f, @3.724f, @3.726f, @3.731f, @3.737f, @3.742f, @3.747f, @3.753f, @3.758f, @3.763f, @3.774f, @3.779f, @3.784f, @3.798f, @3.805f, @3.816f, @3.826f, @3.842f, @3.853f, @3.863f, @3.879f, @3.895f, @3.906f, @3.921f, @3.937f, @3.948f, @3.964f, @3.980f, @4.001f, @4.018f, @4.032f, @4.048f, @4.064f, @4.085f, @4.097f, @4.117f, @4.138f, @4.185f, @4.190f, nil];
            _voltagestep=(100.0 - _voltageFirstOffset) / ([_voltageTable count] - 2);
            _voltageSlope=[[NSMutableArray alloc] init];
            for (cnt = 0; cnt < [_voltageTable count] - 1; cnt++) {
                [_voltageSlope addObject:@(_voltagestep / ([[_voltageTable objectAtIndex:(cnt + 1)] doubleValue] - [[_voltageTable objectAtIndex:cnt] doubleValue]))];
            }
        }
    }
}
*/

- (void) setBatteryMode: (BATTERYMODE) bm {
    
    int cnt;
    _currentInventoryMode = bm;

    if (bm == INVENTORY)
    {
        _voltageTable=[NSArray arrayWithObjects:@3.921f, @3.890f, @3.863f, @3.826f, @3.795f, @3.768f, @3.742f, @3.721f, @3.700f, @3.679f, @3.652f, @3.642f, @3.621f, @3.605f, @3.589f, @3.573f, @3.563f, @3.557f, @3.552f, @3.536f, @3.526f, @3.520f, @3.499f, @3.478f, @3.457f, @3.415f, @3.241f, @2.612f, nil];
        _capacityTable=[NSArray arrayWithObjects:@100.0f, @99.0f, @98.0f, @97.0f, @96.0f, @94.0f, @92.0f, @89.0f, @85.0f, @80.0f, @75.0f, @70.0f, @65.0f, @60.0f, @55.0f, @50.0f, @45.0f, @40.0f, @35.0f, @30.0f, @24.0f, @20.0f, @16.0f, @13.0f, @9.0f, @6.0f, @2.0f, @0.0f, nil];
        
        _voltageSlope=[[NSMutableArray alloc] init];
        for (cnt = 0; cnt <= [_voltageTable count] - 2; cnt++) {
            [_voltageSlope addObject:@(([[_capacityTable objectAtIndex:cnt] doubleValue] - [[_capacityTable objectAtIndex:cnt + 1] doubleValue]) / ([[_voltageTable objectAtIndex:cnt] doubleValue] - [[_voltageTable objectAtIndex:cnt + 1] doubleValue]))];
        }
    }
    else    //idle
    {
        _voltageTable=[NSArray arrayWithObjects:@4.048f, @4.032f, @4.011f, @3.995f, @3.974f, @3.964f, @3.948f, @3.932f, @3.911f, @3.895f, @3.879f, @3.863f, @3.853f, @3.842f, @3.826f, @3.811f, @3.800f, @3.784f, @3.774f, @3.758f, @3.747f, @3.737f, @3.726f, @3.721f, @3.710f, @3.705f, @3.695f, @3.689f, @3.684f, @3.679f, @3.673f, @3.668f, @3.663f, @3.658f, @3.658f, @3.652f, @3.647f, @3.642f, @3.636f, @3.631f, @3.626f, @3.615f, @3.605f, @3.594f, @3.578f, @3.573f, @3.563f, @3.552f, @3.504f, @3.394f, @3.124f, @2.517f, nil];
        _capacityTable=[NSArray arrayWithObjects:@100.0f, @99.0f, @98.0f, @97.0f, @95.0f, @93.0f, @90.0f, @87.0f, @84.0f, @81.0f, @78.0f, @75.0f, @73.0f, @71.0f, @69.0f, @68.0f, @66.0f, @64.0f, @62.0f, @60.0f, @58.0f, @56.0f, @54.0f, @52.0f, @50.0f, @48.0f, @47.0f, @45.0f, @43.0f, @41.0f, @39.0f, @37.0f, @35.0f, @33.0f, @31.0f, @29.0f, @27.0f, @26.0f, @24.0f, @22.0f, @20.0f, @18.0f, @16.0f, @14.0f, @12.0f, @10.0f, @8.0f, @6.0f, @5.0f, @3.0f, @1.0f, @0.0f, nil];

        _voltageSlope=[[NSMutableArray alloc] init];
        for (cnt = 0; cnt <= [_voltageTable count] - 2; cnt++) {
            [_voltageSlope addObject:@(([[_capacityTable objectAtIndex:cnt] doubleValue] - [[_capacityTable objectAtIndex:cnt + 1] doubleValue]) / ([[_voltageTable objectAtIndex:cnt] doubleValue] - [[_voltageTable objectAtIndex:cnt + 1] doubleValue]))];
        }
    }
    
}

/*
- (int) getBatteryPercentageByVoltage: (double) voltage {
    
    int cnt;
    
    if (voltage > [[_voltageTable objectAtIndex:0] doubleValue])
    {
        if (voltage > [[_voltageTable objectAtIndex:1] doubleValue])
        {
            for (cnt = ((int)[_voltageTable count] - 1); cnt >= 0; cnt--)
            {
                if (voltage > [[_voltageTable objectAtIndex:cnt] doubleValue])
                {
                    if (cnt == [_voltageTable count] - 1)
                        return 100;
                    
                    double percent = 0;
                    
                    percent = (_voltagestep * (cnt - 1) + _voltageFirstOffset) + ((voltage - [[_voltageTable objectAtIndex:cnt] doubleValue]) * [[_voltageSlope objectAtIndex:cnt] doubleValue]);
                    
                    return percent;
                }
            }
        }
        else
        {
            double percent = ((voltage - [[_voltageTable objectAtIndex:0] doubleValue]) * [[_voltageSlope objectAtIndex:0] doubleValue]);
            return ((int)percent);
        }
    }

    return -1;
}
 */

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
