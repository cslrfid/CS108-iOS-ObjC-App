//
//  CSLReaderInfo.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 21/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

///Information of the connected reader
@interface CSLReaderInfo : NSObject
///Applicatino version
@property NSString* appVersion;
///Bluetooth IC firmware version
@property NSString* BtFirmwareVersion;
///RFID firmware version
@property NSString* RfidFirmwareVersion;
///Silicon Lab IC firmware version
@property NSString* SiLabICFirmwareVersion;
///Reader 13-character serial number
@property NSString* deviceSerialNumber;
///PCB board version
@property NSString* pcbBoardVersion;
///Reader current battery level percentage
@property (assign) int batteryPercentage;
///OEM data: Country Code
@property (assign) UInt32 countryCode;
///OEM data: Special Country Verison
@property (assign) UInt32 specialCountryVerison;
///OEM data: Frequency Modication Flag
@property (assign) UInt32 freqModFlag;
///OEM data: Model Code
@property (assign) UInt32 modelCode;
///OEM data: Hopping/Fixed Frequency
@property (assign) UInt32 isFxied;
@end
