//
//  CSLRfidAppEngine.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CSLBleReader.h"
#import "CSLBleTag.h"
#import "CSLBlePacket.h"
#import "CSLReaderSettings.h"
#import "CSLReaderInfo.h"

/**
 Singleton class that handles all activities on the reader.  It provides a centralize point and allows data to be moved across different controllers

 */
@interface CSLRfidAppEngine : NSObject


///CSLBleReader instance of the connected reader
@property CSLBleReader* reader;
///Reader settings being stored in User Defaults
@property CSLReaderSettings* settings;
///Technical details of the connected reader
@property CSLReaderInfo* readerInfo;
///Tag selected for tag read/write/search
@property NSString* tagSelected;
///Defines the current reader mode (RFID/Barcode)
@property (assign) BOOL isBarcodeMode;

///Initialize the app engine
///@return Reference to the singleton class CSLRfidAppEngine
+ (CSLRfidAppEngine *) sharedAppEngine;
///Memory allocation of the singleton class
/// @return Reference to the allocated instance
+ (id)alloc;
///Release the singleton class
+ (void)destroy;
///Initializing instances for: (1) CSLBleReader (2) CSLReaderSettings (3) CSLReaderInfo
/// @return Reference to the allocated instance
- (id)init;
///dealloc (not in use)
- (void)dealloc;
///Load settings from User Defaults
-(void)reloadSettingsFromUserDefaults;
///Save current settings to User Defaults
-(void)saveSettingsToUserDefaults;
///Play iOS default sound alerts
-(void)soundAlert:(SystemSoundID) soundId;

@end
