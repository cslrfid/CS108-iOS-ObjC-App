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
}

@property (retain) NSString* appVersion;
@property (retain) NSString* BtFirmwareVersion;
@property (retain) NSString* RfidFirmwareVersion;
@property (retain) NSString* SiLabICFirmwareVersion;
@property (retain) NSString* deviceSerialNumber;

@end
