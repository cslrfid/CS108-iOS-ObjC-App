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
#import "CSLBleReader+AccessControl.h"
#import "CSLBleTag.h"
#import "CSLBlePacket.h"
#import "CSLReaderSettings.h"
#import "CSLReaderInfo.h"
#import "CSLMQTTSettings.h"
#import "CSLTemperatureTagSettings.h"
#import "CSLReaderFrequency.h"
#import "CSLReaderConfigurations.h"
#import <MQTTClient/MQTTClient.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

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
///Tag selected for tag read/write/search
@property CSLBleTag* CSLBleTagSelected;
///Defines the current reader mode (RFID/Barcode)
@property (assign) BOOL isBarcodeMode;
///Reader settings on MQTT broker
@property CSLMQTTSettings* MQTTSettings;
///Reader settings for temperature tags
@property CSLTemperatureTagSettings* temperatureSettings;
///Class that generates the supported regions and frequency list of the device hardware
@property CSLReaderFrequency* readerRegionFrequency;

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
///Load MQTT settings from User Defaults
-(void)reloadMQTTSettingsFromUserDefaults;
///Save current MQTT settings to User Defaults
-(void)saveMQTTSettingsToUserDefaults;
///Load temperature tag settings from User Defaults
-(void)reloadTemperatureTagSettingsFromUserDefaults;
///Save current temperature tag settings to User Defaults
-(void)saveTemperatureTagSettingsToUserDefaults;
///Play iOS default sound alerts
-(void)soundAlert:(SystemSoundID) soundId;

@end
