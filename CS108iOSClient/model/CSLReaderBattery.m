//
//  CSLReaderBattery.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 1/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderBattery.h"

@implementation CSLReaderBattery

static double _voltageFirstOffset;
static double _voltagestep;
static NSArray* _voltageTable;
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
@end
