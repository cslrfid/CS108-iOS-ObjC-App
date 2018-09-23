//
//  CSLBleInterface.h
//  CS108Playground
//
//  Created by Lam Ka Shun on 2/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CSLBlePacket.h"
#import "CSLCircularQueue.h"

typedef enum _STATUS : Byte
{
    CONNECTED,
    NOT_CONNECTED,
    SCANNING,
    BUSY,   //at this state, reader is busy and not able to receive any downlink command
    TAG_OPERATIONS,  //at this state, reader is performing actions on the tags (inventory/read/write/etc) in the background but still able to receive specific downlink commands
    ERROR
} STATUS;

@class CSLBleInterface;             //define class, so protocol can see CSLBleInterface class
@protocol CSLBleInterfaceDelegate <NSObject>   //define delegate protocol
- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender;     //triggered when reader state chagnes
@end //end protocol

@interface CSLBleInterface : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSString * deviceName;
    CBPeripheral* bleDevice;        //connected BLE device
    NSMutableArray * bleDeviceList; //array of CBPeripheral object after device discovery
    NSException* LastException;
    CSLCircularQueue * recvQueue;
    STATUS connectStatus;
}

@property NSString * deviceName;
@property NSException* LastException;
@property NSMutableArray * bleDeviceList;
@property CBPeripheral* bleDevice;
@property CSLCircularQueue* recvQueue;
@property (readonly) STATUS connectStatus;
@property (nonatomic, weak) id <CSLBleInterfaceDelegate> delegate; //define CSLBleReaderDelegate as delegate

- (id) init;
- (void) dealloc;
- (void) startScanDevice;
- (void) stopScanDevice;
- (void) connectDevice:(CBPeripheral*) peripheral;
- (void) disconnectDevice;
- (BOOL) isLECapableHardware;
- (void) sendPackets:(CSLBlePacket *) packet;
- (NSData *) computeChecksum: (NSData *) dataIn;

@end
