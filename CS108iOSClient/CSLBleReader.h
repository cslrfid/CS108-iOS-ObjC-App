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

@class CSLBleReader;             //define class, so protocol can see CSLBleReader class
@protocol CSLBleReaderDelegate <NSObject>   //define delegate protocol
- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag;  //define delegate method to be implemented within another class
- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state;  //define delegate method to be implemented within another class
@end //end protocol

@interface CSLBleReader : CSLBleInterface
{
    NSMutableArray * filteredBuffer;   //after duplicate eliminations durinng async inventory
    CSLCircularQueue * cmdRespQueue;     //Buffer for storing response packet(s) after issuing a command synchronously
    
    NSInteger * rangingTagCount;
}

@property NSMutableArray * filteredBuffer;
@property CSLCircularQueue * cmdRespQueue;
@property (nonatomic, weak) id <CSLBleReaderDelegate> readerDelegate; //define CSLBleReaderDelegate as delegate
@property NSInteger * rangingTagCount;

- (id)init;
- (void)dealloc;
- (BOOL)readOEMData:(CSLBleInterface*)intf atAddr:(unsigned short)addr forData:(NSData*)data;
- (BOOL)barcodeReader:(BOOL)enable;
- (BOOL)powerOnRfid:(BOOL)enable;
- (BOOL)getBtFirmwareVersion:(NSString *)versionNumber;
- (BOOL)getConnectedDeviceName:(NSString *) deviceName;
- (BOOL)getSilLabIcVersion:(NSString *) slVersion;
- (BOOL)getRfidBrdSerialNumber:(NSString*) serialNumber;
- (BOOL)sendAbortCommand;
- (BOOL)getRfidFwVersionNumber:(NSString*) versionInfo;
- (BOOL)setPower:(double) powerInDbm;
- (BOOL)setAntennaCycle:(NSUInteger) cycles;
- (BOOL)setAntennaDwell:(NSUInteger) timeInMilliseconds;
- (BOOL)setLinkProfile:(Byte) profile;
- (BOOL)selectAlgorithmParameter:(NSUInteger) descriptorIndex;
- (BOOL)setInventoryAlgorithmParameters0:(Byte) startQ maximumQ:(Byte)maxQ minimumQ:(Byte)minQ ThresholdMultiplier:(Byte)tmult;
- (BOOL)setInventoryAlgorithmParameters1:(Byte) retry;
- (BOOL)setInventoryAlgorithmParameters2:(BOOL) toggle RunTillZero:(BOOL)rtz;
- (BOOL)setInventoryConfigurations:(Byte) inventoryAlgorithm MatchRepeats:(Byte)match_rep tagSelect:(Byte)tag_sel disableInventory:(Byte)disable_inventory tagRead:(Byte)tag_read crcErrorRead:(Byte) crc_err_read QTMode:(Byte) QT_mode tagDelay:(Byte) tag_delay inventoryMode:(Byte)inv_mode;
- (BOOL)setQueryConfigurations:(Byte) queryTarget querySession:(Byte)query_session querySelect:(Byte)query_sel;
- (BOOL)startInventory;
- (BOOL)stopInventory;


- (void)decodePacketsInBufferAsync;



@end
