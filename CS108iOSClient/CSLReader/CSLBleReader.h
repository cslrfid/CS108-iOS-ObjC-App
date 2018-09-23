//
//  CSLBleReader.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 28/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSLBleInterface.h"
#import "CSLBleTag.h"

#define COMMAND_TIMEOUT_1S 10
#define COMMAND_TIMEOUT_2S 20
#define COMMAND_TIMEOUT_3S 30
#define COMMAND_TIMEOUT_4S 40
#define COMMAND_TIMEOUT_5S 50

#define COMMAND_ANTCYCLE_CONTINUOUS 0xFFFF

typedef enum _SESSION : Byte
{
    S0 = 0,
    S1,
    S2,
    S3
    
} SESSION;

typedef enum _TARGET : Byte
{
    A = 0x00,
    B,
    ToggleAB
} TARGET;

typedef enum _QUERYALGORITHM : Byte
{
    FIXEDQ = 0x00,
    DYNAMICQ = 0x03
} QUERYALGORITHM;

typedef enum _LINKPROFILE : Byte
{
    MULTIPATH_INTERFERENCE_RESISTANCE = 0x00,
    RANGE_DRM,
    RANGE_THROUGHPUT_DRM,
    MAX_THROUGHPUT
} LINKPROFILE;

typedef enum _QUERYSELECT : Byte
{
    ALL = 0x00,
    SL = 0x03
} QUERYSELECT;



@class CSLBleReader;             //define class, so protocol can see CSLBleReader class
@protocol CSLBleReaderDelegate <NSObject>   //define delegate protocol
- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag;  //define delegate method to be implemented within another class
- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state;  //define delegate method to be implemented within another class
@end //end protocol

@interface CSLBleReader : CSLBleInterface
{
    NSMutableArray * filteredBuffer;   //after duplicate eliminations durinng async inventory
    NSInteger rangingTagCount;          //counter for tag rate calculation
}

@property NSMutableArray * filteredBuffer;
@property NSInteger rangingTagCount;
@property (nonatomic, weak) id <CSLBleReaderDelegate> readerDelegate; //define CSLBleReaderDelegate as delegate


- (id)init;
- (void)dealloc;
- (BOOL)readOEMData:(CSLBleInterface*)intf atAddr:(unsigned short)addr forData:(NSData*)data;
- (BOOL)barcodeReader:(BOOL)enable;
- (BOOL)powerOnRfid:(BOOL)enable;
- (BOOL)getBtFirmwareVersion:(NSString **)versionNumber;
- (BOOL)getConnectedDeviceName:(NSString **) deviceName;
- (BOOL)getSilLabIcVersion:(NSString **) slVersion;
- (BOOL)getRfidBrdSerialNumber:(NSString**) serialNumber;
- (BOOL)sendAbortCommand;
- (BOOL)getRfidFwVersionNumber:(NSString**) versionInfo;
- (BOOL)setPower:(double) powerInDbm;
- (BOOL)setAntennaCycle:(NSUInteger) cycles;
- (BOOL)setAntennaDwell:(NSUInteger) timeInMilliseconds;
- (BOOL)setLinkProfile:(LINKPROFILE) profile;
- (BOOL)selectAlgorithmParameter:(QUERYALGORITHM) algorithm;
- (BOOL)setInventoryAlgorithmParameters0:(Byte) startQ maximumQ:(Byte)maxQ minimumQ:(Byte)minQ ThresholdMultiplier:(Byte)tmult;
- (BOOL)setInventoryAlgorithmParameters1:(Byte) retry;
- (BOOL)setInventoryAlgorithmParameters2:(BOOL) toggle RunTillZero:(BOOL)rtz;
- (BOOL)setInventoryConfigurations:(QUERYALGORITHM) inventoryAlgorithm MatchRepeats:(Byte)match_rep tagSelect:(Byte)tag_sel disableInventory:(Byte)disable_inventory tagRead:(Byte)tag_read crcErrorRead:(Byte) crc_err_read QTMode:(Byte) QT_mode tagDelay:(Byte) tag_delay inventoryMode:(Byte)inv_mode;
- (BOOL)setQueryConfigurations:(TARGET) queryTarget querySession:(SESSION)query_session querySelect:(QUERYSELECT)query_sel;
- (BOOL)startInventory;
- (BOOL)stopInventory;


- (void)decodePacketsInBufferAsync;



@end
