//
//  CSLReaderBattery.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 1/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

///Select the battery level curve based on the reader status
typedef NS_ENUM(Byte, BATTERYMODE)
{
    ///Select battery level curve for inventory mode
    INVENTORY = 0,
    ///Select battery level curve for idle mode
    IDLE = 1
    
};
///Define the battery level status
typedef NS_ENUM(Byte, BATTERYLEVELSTATUS)
{
    ///Battery level in good health
    NORMAL = 0,
    ///Battery low indicator
    LOW = 1,
    ///Battery level below 17%
    LOW_17 = 2
    
};
///Reader battery level monitoring
@interface CSLReaderBattery : NSObject

- (id) init;
/**As battery level curve selected is depended on PCB version, initialize the instance with current PCB version
@param pcbVersion Version of reader PCB
@return Reference to the allocated instance
 */
- (id) initWithPcBVersion:(double)pcbVersion;

/**Report the PCB version of the connected reader
 @param pcbVersion Version of reader PCB
 */
- (void) setPcbVersion:(double)pcbVersion;
/**Set battery mode (idle/inventory)
 @param bm Current battery mode
 */
- (void) setBatteryMode: (BATTERYMODE) bm;
/**Get the battery level in percentage by voltage
 @param voltage voltage level in volts
 @return Percentage of the battery level
 */
- (int) getBatteryPercentageByVoltage: (double) voltage;

@end
