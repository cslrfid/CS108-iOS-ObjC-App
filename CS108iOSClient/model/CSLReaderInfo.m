//
//  CSLReaderInfo.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 21/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderInfo.h"

@implementation CSLReaderInfo

@synthesize BtFirmwareVersion;
@synthesize RfidFirmwareVersion;
@synthesize SiLabICFirmwareVersion;
@synthesize deviceSerialNumber;
@synthesize pcbBoardVersion;
@synthesize appVersion;
@synthesize batteryPercentage;

-(id)init {
    if (self = [super init])  {
        //set default values
        appVersion = [[NSString alloc] init];
        BtFirmwareVersion = [[NSString alloc] init];
        RfidFirmwareVersion = [[NSString alloc] init];
        SiLabICFirmwareVersion = [[NSString alloc] init];
        deviceSerialNumber = [[NSString alloc] init];
        pcbBoardVersion = [[NSString alloc] init];
        batteryPercentage=-1;
    }
    return self;
}

@end
