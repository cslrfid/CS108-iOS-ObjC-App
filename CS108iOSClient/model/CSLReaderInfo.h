//
//  CSLReaderInfo.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 21/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSLReaderInfo : NSObject
{
    NSString* appVersion;
    NSString* BtFirmwareVersion;
    NSString* RfidFirmwareVersion;
    NSString* SiLabICFirmwareVersion;
    NSString* deviceSerialNumber;
    NSString* pcbBoardVersion;
    int batteryPercentage;
}

@property NSString* appVersion;
@property NSString* BtFirmwareVersion;
@property NSString* RfidFirmwareVersion;
@property NSString* SiLabICFirmwareVersion;
@property NSString* deviceSerialNumber;
@property NSString* pcbBoardVersion;
@property (assign) int batteryPercentage;
@end
