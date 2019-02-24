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


@end
