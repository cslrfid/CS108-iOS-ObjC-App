//
//  CSLReaderBattery.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 1/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum _BATTERYMODE : Byte
{
    INVENTORY = 0,
    IDLE = 1
    
} BATTERYMODE;

typedef enum _BATTERYLEVELSTATUS : Byte
{
    NORMAL = 0,
    LOW = 1,
    LOW_17 = 2
    
} BATTERYLEVELSTATUS;

@interface CSLReaderBattery : NSObject

- (id) init;
- (id) initWithPcBVersion:(double)pdbVersion;
- (void) setPcbVersion:(double)pcbVersion;
- (void) setBatteryMode: (BATTERYMODE) bm;
- (int) getBatteryPercentageByVoltage: (double) voltage;

@end
