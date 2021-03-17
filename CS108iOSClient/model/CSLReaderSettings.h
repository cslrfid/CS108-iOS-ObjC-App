//
//  CSLReaderSettings.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 20/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSLBleReader.h"
#import "CSLBleReader+AccessControl.h"


///Reader Settings
@interface CSLReaderSettings : NSObject

///Reader output power
@property (assign) int power;
///Reader port being used during  tag read/write
@property (assign) int tagAccessPort;
///Estimated tag population in the reading environment
@property (assign) int tagPopulation;
///Enable/disable Q overriding, where Q should be defined manually or calcuated based on the estimated tag population
@property (assign) BOOL isQOverride;
///User defined, or calculated Q value
@property (assign) int QValue;
///Query session
@property (assign) SESSION session;
///Query target
@property (assign) TARGET target;
///Query algorithm
@property (assign) QUERYALGORITHM algorithm;
///Link profile selected
@property (assign) LINKPROFILE linkProfile;
///Define whether sound alert is enabled/disabled
@property (assign) BOOL enableSound;
///Impinj Extension - Tag Focus
@property (assign) Byte tagFocus;
///Impinj Extension - Fast ID
@property (assign) Byte FastId;
///LNA Settings: RF-LNA High Compression Mode
@property (assign) Byte rfLnaHighComp;
///LNA Settings: RF-LNA
@property (assign) Byte rfLna;
///LNA Settings: IF-LNA
@property (assign) Byte ifLna;
///LNA Settings: IF-LNA AGC
@property (assign) Byte ifAgc;
///Frequency Settings: Region
@property NSString* region;
///Frequency Settings: Channel
@property NSString* channel;
///Enable/disable multibank bank 1
@property (assign) BOOL isMultibank1Enabled;
///Define multibank bank1
@property (assign) MEMORYBANK multibank1;
///Multibank bank1 Offset
@property (assign) Byte multibank1Offset;
///Multibank bank1 Length
@property (assign) Byte multibank1Length;
///Enable/disable multibank bank 2
@property (assign) BOOL isMultibank2Enabled;
///Define multibank bank 2
@property (assign) MEMORYBANK multibank2;
///Multibank bank1 Offset
@property (assign) Byte multibank2Offset;
///Multibank bank1 Length
@property (assign) Byte multibank2Length;
///Number of Power Level
@property (assign) int numberOfPowerLevel;
///Power Level (up to 16 stages)
@property NSMutableArray* powerLevel;
///Dwell time
@property NSMutableArray* dwellTime;
///Antenna port enable/disable (for CS463 only)
@property NSMutableArray* isPortEnabled;

///Pre-filter - mask
@property NSString* prefilterMask;
///Pre-filter - bank
@property (assign) MEMORYBANK prefilterBank;
///Pre-filter - offset
@property (assign) int prefilterOffset;
///Pre-filter - enabled
@property (assign) BOOL prefilterIsEnabled;

///Post-filter - mask
@property NSString* postfilterMask;
///Post-filter - bank
@property (assign) BOOL postfilterIsNotMatchMaskEnabled;
///Post-filter - offset
@property (assign) int postfilterOffset;
///Post-filter - enabled
@property (assign) BOOL postfilterIsEnabled;

@end
