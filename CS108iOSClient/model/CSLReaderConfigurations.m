//
//  CSLReaderConfigurations.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-10-28.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderConfigurations.h"

@implementation CSLReaderConfigurations

+ (void) setAntennaPortsAndPowerForTags:(BOOL)isInitial {
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        if([CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel == 0) {
            //use global settings
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
            
            if (isInitial) {
                //disable all other ports
                for (int i=1;i<16;i++) {
                    [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                                  InventoryMode:0
                                                                  InventoryAlgo:0
                                                                         StartQ:0
                                                                    ProfileMode:0
                                                                        Profile:0
                                                                  FrequencyMode:0
                                                               FrequencyChannel:0
                                                                   isEASEnabled:0];
                }
            }
        }
        else {
            //iterate through all the power level
            for (int i=0;i<16;i++) {
                int dwell=[[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[i] intValue];
                //enforcing dwell time != 0 when tag focus is enabled
                if ([CSLRfidAppEngine sharedAppEngine].settings.tagFocus) {
                    dwell=2000;
                }
                [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                NSLog(@"Power level %d: %@", i, (i >= [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel) ? @"OFF" : @"ON");
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:((i >= [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel) ? FALSE : TRUE)
                                                              InventoryMode:0
                                                              InventoryAlgo:0
                                                                     StartQ:0
                                                                ProfileMode:0
                                                                    Profile:0
                                                              FrequencyMode:0
                                                           FrequencyChannel:0
                                                               isEASEnabled:0];
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:[[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[i] intValue] / 10];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:dwell];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:dwell == 0 ? 65535 : 0];
            }
        }
    }
    else {
        //iterate through all the power level
        for (int i=0;i<4;i++) {
            int dwell=[[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[i] intValue];
            //enforcing dwell time != 0 when tag focus is enabled
            if ([CSLRfidAppEngine sharedAppEngine].settings.tagFocus) {
                dwell=2000;
            }
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            NSLog(@"Antenna %d: %@", i, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue] ? @"ON" : @"OFF");
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue]
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[i] intValue] / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:dwell];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:dwell == 0 ? 65535 : 0];
        }
    }

}

+ (void) setAntennaPortsAndPowerForTagAccess:(BOOL)isInitial {
    
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        //disable power level ramping
        [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                      InventoryMode:0
                                                      InventoryAlgo:0
                                                             StartQ:0
                                                        ProfileMode:0
                                                            Profile:0
                                                      FrequencyMode:0
                                                   FrequencyChannel:0
                                                       isEASEnabled:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        //disable all other ports
        if (isInitial) {
            for (int i=1;i<16;i++) {
                [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                              InventoryMode:0
                                                              InventoryAlgo:0
                                                                     StartQ:0
                                                                ProfileMode:0
                                                                    Profile:0
                                                              FrequencyMode:0
                                                           FrequencyChannel:0
                                                               isEASEnabled:0];
            }
        }
    }
    else {
        //enable power output on selected port
        for (int i=0;i<4;i++) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            NSLog(@"Antenna %d: %@", i, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue] ? @"ON" : @"OFF");
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:[CSLRfidAppEngine sharedAppEngine].settings.tagAccessPort == i ? true : false
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        }
    }

}

+ (void) setAntennaPortsAndPowerForTagSearch:(BOOL)isInitial {
    
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        //disable power level ramping
        [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                      InventoryMode:0
                                                      InventoryAlgo:0
                                                             StartQ:0
                                                        ProfileMode:0
                                                            Profile:0
                                                      FrequencyMode:0
                                                   FrequencyChannel:0
                                                       isEASEnabled:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        //disable all other ports
        if (isInitial) {
            for (int i=1;i<16;i++) {
                [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                              InventoryMode:0
                                                              InventoryAlgo:0
                                                                     StartQ:0
                                                                ProfileMode:0
                                                                    Profile:0
                                                              FrequencyMode:0
                                                           FrequencyChannel:0
                                                               isEASEnabled:0];
            }
        }
    }
    else {
        //enable power output on selected port
        for (int i=0;i<4;i++) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            NSLog(@"Antenna %d: %@", i, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue] ? @"ON" : @"OFF");
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue]
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        }
    }

}

+ (void) setConfigurationsForTags {

    //set inventory configurations
    //for multiplebank inventory
    Byte tagRead=0;
    if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled && [CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled)
        tagRead=2;
    else if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled)
        tagRead=1;
    else
        tagRead=0;
    
    Byte tagDelay=0;
    if (![CSLRfidAppEngine sharedAppEngine].settings.tagFocus && tagRead) {
        tagDelay=30;
    }

    
    [[CSLRfidAppEngine sharedAppEngine].reader setQueryConfigurations:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? A : [CSLRfidAppEngine sharedAppEngine].settings.target) querySession:[CSLRfidAppEngine sharedAppEngine].settings.session querySelect:ALL];
    [[CSLRfidAppEngine sharedAppEngine].reader selectAlgorithmParameter:[CSLRfidAppEngine sharedAppEngine].settings.algorithm];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters0:[CSLRfidAppEngine sharedAppEngine].settings.QValue maximumQ:15 minimumQ:0 ThresholdMultiplier:4];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters1:0];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters2:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? true : false) RunTillZero:false];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:tagRead crcErrorRead:(tagRead ? 0 : 1) QTMode:0 tagDelay:tagDelay inventoryMode:(tagRead ? 0 : 1)];
    [[CSLRfidAppEngine sharedAppEngine].reader setLinkProfile:[CSLRfidAppEngine sharedAppEngine].settings.linkProfile];
    
    //prefilter
    if ([CSLRfidAppEngine sharedAppEngine].settings.prefilterIsEnabled) {
        
        int maskOffset=0;
        if ([CSLRfidAppEngine sharedAppEngine].settings.prefilterBank == EPC)
            maskOffset=32;
        [[CSLRfidAppEngine sharedAppEngine].reader setQueryConfigurations:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? A : [CSLRfidAppEngine sharedAppEngine].settings.target) querySession:[CSLRfidAppEngine sharedAppEngine].settings.session querySelect:SL];
        [[CSLRfidAppEngine sharedAppEngine].reader clearAllTagSelect];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:0];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:[CSLRfidAppEngine sharedAppEngine].settings.prefilterBank
                                                             maskPointer:[CSLRfidAppEngine sharedAppEngine].settings.prefilterOffset + maskOffset
                                                              maskLength:((UInt32)([[CSLRfidAppEngine sharedAppEngine].settings.prefilterMask length] * 4))
                                                                maskData:(NSData*)[CSLBleReader convertHexStringToData:[CSLRfidAppEngine sharedAppEngine].settings.prefilterMask]
                                                              sel_action:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:1 /* force tag_select */ disableInventory:0 tagRead:tagRead crcErrorRead:true QTMode:0 tagDelay:(tagRead ? 30 : 0) inventoryMode:(tagRead ? 0 : 1)];
    }
    else {
        [[CSLRfidAppEngine sharedAppEngine].reader clearAllTagSelect];
    }
    
    //postfilter
    if ([CSLRfidAppEngine sharedAppEngine].settings.postfilterIsEnabled) {
        
        //Pad one hex digit if mask length is odd
        NSString* maskString = [CSLRfidAppEngine sharedAppEngine].settings.postfilterMask;
        if ([[CSLRfidAppEngine sharedAppEngine].settings.postfilterMask length] % 2 != 0) {
            maskString = [NSString stringWithFormat:@"%@%@", [CSLRfidAppEngine sharedAppEngine].settings.postfilterMask, @"0"];
        }
        
        [[CSLRfidAppEngine sharedAppEngine].reader setEpcMatchSelect:0x00];
        [[CSLRfidAppEngine sharedAppEngine].reader setEpcMatchConfiguration:true
                                                                    matchOn:[CSLRfidAppEngine sharedAppEngine].settings.postfilterIsNotMatchMaskEnabled
                                                                matchLength:[[CSLRfidAppEngine sharedAppEngine].settings.postfilterMask length] * 4
                                                                matchOffset:[CSLRfidAppEngine sharedAppEngine].settings.postfilterOffset];
        [[CSLRfidAppEngine sharedAppEngine].reader setEpcMatchMask:((UInt32)([[CSLRfidAppEngine sharedAppEngine].settings.postfilterMask length] * 4))
                                                          maskData:(NSData*)[CSLBleReader convertHexStringToData:maskString]];
        
    }
    else {
        [[CSLRfidAppEngine sharedAppEngine].reader setEpcMatchSelect:0x00];
        [[CSLRfidAppEngine sharedAppEngine].reader setEpcMatchConfiguration:false
                                                                    matchOn:false
                                                                matchLength:0x0000
                                                                matchOffset:0x0000];
    }
    
    
    if ([CSLRfidAppEngine sharedAppEngine].settings.FastId) {
        [[CSLRfidAppEngine sharedAppEngine].reader setQueryConfigurations:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? A : [CSLRfidAppEngine sharedAppEngine].settings.target) querySession:[CSLRfidAppEngine sharedAppEngine].settings.session querySelect:SL];
        [[CSLRfidAppEngine sharedAppEngine].reader clearAllTagSelect];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:0];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:TID maskPointer:0 maskLength:24 maskData:[CSLBleReader convertHexStringToData:@"E2801100"] sel_action:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:1 /* force tag_select */ disableInventory:0 tagRead:tagRead crcErrorRead:true QTMode:0 tagDelay:(tagRead ? 30 : 0) inventoryMode:(tagRead ? 0 : 1)];
    }
    
    
    //frequency configurations
//    if ([CSLRfidAppEngine sharedAppEngine].readerRegionFrequency.isFixed) {
//        [[CSLRfidAppEngine sharedAppEngine].reader SetFixedChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
//                                                        RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region
//                                                      channelIndex:[[CSLRfidAppEngine sharedAppEngine].settings.channel intValue]];
//    }
//    else {
//        [[CSLRfidAppEngine sharedAppEngine].reader SetHoppingChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
//                                                          RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region];
//    }
    
    // if multibank read is enabled
    if (tagRead) {
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_BANK:[CSLRfidAppEngine sharedAppEngine].settings.multibank1 acc_bank2:[CSLRfidAppEngine sharedAppEngine].settings.multibank2];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_PTR:([CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset << 16) + [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_CNT:(tagRead ? [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length : 0) secondBank:(tagRead==2 ? [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length : 0)];
    }
    
    NSLog(@"Tag focus value: %d", [CSLRfidAppEngine sharedAppEngine].settings.tagFocus);
    //Impinj Extension
    [[CSLRfidAppEngine sharedAppEngine].reader setImpinjExtension:[CSLRfidAppEngine sharedAppEngine].settings.tagFocus
                                                           fastId:[CSLRfidAppEngine sharedAppEngine].settings.FastId
                                                   blockWriteMode:0];
    //LNA settings
    [[CSLRfidAppEngine sharedAppEngine].reader setLNAParameters:[CSLRfidAppEngine sharedAppEngine].reader
                                                  rflnaHighComp:[CSLRfidAppEngine sharedAppEngine].settings.rfLnaHighComp
                                                      rflnaGain:[CSLRfidAppEngine sharedAppEngine].settings.rfLna
                                                      iflnaGain:[CSLRfidAppEngine sharedAppEngine].settings.ifLna
                                                      ifagcGain:[CSLRfidAppEngine sharedAppEngine].settings.ifAgc];
    
}

+ (void) setAntennaPortsAndPowerForTemperatureTags:(BOOL)isInitial {

    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];    //0x0700
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==HIGHPOWER)
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:30];
    else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==LOWPOWER)
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:16];
    else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==MEDIUMPOWER)
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:23];
    else
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
    

    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel!=SYSTEMSETTING) {
            //use pre-defined three level settings
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==HIGHPOWER)
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:30];
            else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==LOWPOWER)
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:16];
            else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==MEDIUMPOWER)
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:23];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
            
            //disable all other channels
            if (isInitial) {
                for (int i=1;i<16;i++) {
                    [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                                  InventoryMode:0
                                                                  InventoryAlgo:0
                                                                         StartQ:0
                                                                    ProfileMode:0
                                                                        Profile:0
                                                                  FrequencyMode:0
                                                               FrequencyChannel:0
                                                                   isEASEnabled:0];
                }
            }
        }
        else {
            if([CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel == 0) {
                //use global settings
                [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                              InventoryMode:0
                                                              InventoryAlgo:0
                                                                     StartQ:0
                                                                ProfileMode:0
                                                                    Profile:0
                                                              FrequencyMode:0
                                                           FrequencyChannel:0
                                                               isEASEnabled:0];
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
                //disable all other ports
                for (int i=1;i<16;i++) {
                    [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                                  InventoryMode:0
                                                                  InventoryAlgo:0
                                                                         StartQ:0
                                                                    ProfileMode:0
                                                                        Profile:0
                                                                  FrequencyMode:0
                                                               FrequencyChannel:0
                                                                   isEASEnabled:0];
                }
            }
            else {
                //iterate through all the power level
                for (int i=0;i<16;i++) {
                    int dwell=[[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[i] intValue];
                    [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                    NSLog(@"Power level %d: %@", i, (i >= [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel) ? @"OFF" : @"ON");
                    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:((i >= [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel) ? FALSE : TRUE)
                                                                  InventoryMode:0
                                                                  InventoryAlgo:0
                                                                         StartQ:0
                                                                    ProfileMode:0
                                                                        Profile:0
                                                                  FrequencyMode:0
                                                               FrequencyChannel:0
                                                                   isEASEnabled:0];
                    [[CSLRfidAppEngine sharedAppEngine].reader setPower:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[i] intValue] / 10];
                    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:dwell];
                    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:dwell == 0 ? 65535 : 0];
                }
            }
        }
    }
    else {  //CS463
        //iterate through all the power level
        for (int i=0;i<4;i++) {
            int dwell=[[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[i] intValue];
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            NSLog(@"Antenna %d: %@", i, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue] ? @"ON" : @"OFF");
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue]
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==HIGHPOWER)
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:30];
            else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==LOWPOWER)
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:16];
            else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==MEDIUMPOWER)
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:23];
            else
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[i] intValue] / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:dwell];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:dwell == 0 ? 65535 : 0];
        }
    }
}

+ (void) setConfigurationsForTemperatureTags {
    
    //pre-configure inventory
    //hardcode multibank inventory parameter for RFMicron tag reading (EPC+OCRSSI+TEMPERATURE)
    [CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled = true;
    [CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled = true;
    
    //check if Xerxes or Magnus tag
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==XERXES) {
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1=USER;
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset=0x12;    //word address 0xC in the RESERVE bank
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length=0x04;
        [CSLRfidAppEngine sharedAppEngine].settings.multibank2=RESERVED;
        [CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset=0x0A;
        [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length=0x05;
    }
    else {
        //check and see if this is S2 or S3 chip for capturing sensor code
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1=RESERVED;
        if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==MAGNUSS3) {
            [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset=12;    //word address 0xC in the RESERVE bank
            [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length=3;
        }
        else {
            [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset=11;    //word address 0xB in the RESERVE bank
            [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length=1;
        }
        
        if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==MAGNUSS3) {
            [CSLRfidAppEngine sharedAppEngine].settings.multibank2=USER;
            [CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset=8;
            [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length=4;
        }
        else {
            [CSLRfidAppEngine sharedAppEngine].settings.multibank2=RESERVED;
            [CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset=13;
            [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length=1;
        }
    }
    //for multiplebank inventory
    Byte tagRead=0;
    if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled && [CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled)
        tagRead=2;
    else if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled)
        tagRead=1;
    else
        tagRead=0;
    
    [[CSLRfidAppEngine sharedAppEngine].reader selectAlgorithmParameter:DYNAMICQ];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters0:[CSLRfidAppEngine sharedAppEngine].settings.QValue maximumQ:15 minimumQ:0 ThresholdMultiplier:4];   //0x0903
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters1:5];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters2:true /*hardcoding toggle A/B*/ RunTillZero:false];     //x0905
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:DYNAMICQ MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:0 crcErrorRead:0 QTMode:0 tagDelay:0 inventoryMode:0]; //0x0901
    
    [[CSLRfidAppEngine sharedAppEngine].reader selectAlgorithmParameter:FIXEDQ];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters0:[CSLRfidAppEngine sharedAppEngine].settings.QValue maximumQ:0 minimumQ:0 ThresholdMultiplier:0];   //0x0903
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters1:5];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters2:true /*hardcoding toggle A/B*/ RunTillZero:false];     //x0905
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:FIXEDQ MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:0 crcErrorRead:0 QTMode:0 tagDelay:0 inventoryMode:0]; //0x0901
    
    [[CSLRfidAppEngine sharedAppEngine].reader setQueryConfigurations:A querySession:S1 querySelect:SL];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:DYNAMICQ MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:0 crcErrorRead:0 QTMode:0 tagDelay:0 inventoryMode:0]; //0x0901
    [[CSLRfidAppEngine sharedAppEngine].reader setLinkProfile:RANGE_DRM];
    
    //multiple bank select
    unsigned char emptyByte[] = {0x00};
    unsigned char OCRSSI[] = {0x20};
    
    //select the TID for either S2 or S3 chip
    [[CSLRfidAppEngine sharedAppEngine].reader clearAllTagSelect];
    
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==XERXES) {
        
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:0];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:TID maskPointer:0 maskLength:32 maskData:[CSLBleReader convertHexStringToData:[NSString stringWithFormat:@"%8X", XERXES]] sel_action:0];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:1];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:USER maskPointer:0x03B0 maskLength:8 maskData:[NSData dataWithBytes:emptyByte length:sizeof(emptyByte)] sel_action:5 delayTime:15];
    
    }
    else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==MAGNUSS3) {
        
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:0];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:TID maskPointer:0 maskLength:28 maskData:[CSLBleReader convertHexStringToData:[NSString stringWithFormat:@"%8X", MAGNUSS3]] sel_action:0];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:1];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:USER maskPointer:0xE0 maskLength:0 maskData:[NSData dataWithBytes:emptyByte length:sizeof(emptyByte)] sel_action:2];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:2];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:USER maskPointer:0xD0 maskLength:8 maskData:[NSData dataWithBytes:OCRSSI length:sizeof(OCRSSI)] sel_action:2];
        
    }
    else {
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:0];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:TID maskPointer:0 maskLength:28 maskData:[CSLBleReader convertHexStringToData:[NSString stringWithFormat:@"%8X", MAGNUSS2]] sel_action:0];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:1];
        [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:USER maskPointer:0xA0 maskLength:8 maskData:[NSData dataWithBytes:OCRSSI length:sizeof(OCRSSI)] sel_action:2];
    }
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryCycleDelay:0];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:tagRead crcErrorRead:true QTMode:0 tagDelay:(tagRead ? 30 : 0) inventoryMode:(tagRead ? 0 : 1)];
    
    //frequency configurations
//    if ([CSLRfidAppEngine sharedAppEngine].readerRegionFrequency.isFixed) {
//        [[CSLRfidAppEngine sharedAppEngine].reader SetFixedChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
//                                                        RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region
//                                                      channelIndex:[[CSLRfidAppEngine sharedAppEngine].settings.channel intValue]];
//    }
//    else {
//        [[CSLRfidAppEngine sharedAppEngine].reader SetHoppingChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
//                                                          RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region];
//    }
    
    // if multibank read is enabled
    if (tagRead) {
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_BANK:[CSLRfidAppEngine sharedAppEngine].settings.multibank1 acc_bank2:[CSLRfidAppEngine sharedAppEngine].settings.multibank2];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_PTR:([CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset << 16) + [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_CNT:(tagRead ? [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length : 0) secondBank:(tagRead==2 ? [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length : 0)];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_ACCPWD:0x00000000];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:1 disableInventory:0 tagRead:tagRead crcErrorRead:true QTMode:0 tagDelay:(tagRead ? 30 : 0) inventoryMode:(tagRead ? 0 : 1)];
        [[CSLRfidAppEngine sharedAppEngine].reader setEpcMatchConfiguration:false matchOn:false matchLength:0x00000 matchOffset:0x00000];
    }
    
}

+ (void) setReaderRegionAndFrequencies
{
    //frequency configurations
    if ([CSLRfidAppEngine sharedAppEngine].readerRegionFrequency.isFixed) {
        [[CSLRfidAppEngine sharedAppEngine].reader SetFixedChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
                                                        RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region
                                                      channelIndex:[[CSLRfidAppEngine sharedAppEngine].settings.channel intValue]];
    }
    else {
        [[CSLRfidAppEngine sharedAppEngine].reader SetHoppingChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
                                                          RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region];
    }
}

@end
