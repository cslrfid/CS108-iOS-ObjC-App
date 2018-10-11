//
//  CSLBleInterface.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CSLBlePacket.h"
#import "CSLCircularQueue.h"

/**Reader status representations*/
typedef NS_ENUM(Byte, STATUS) {
    ///When reader is connected but in idle mode
    CONNECTED,
    ///When reader is not connected
    NOT_CONNECTED,
    ///Application is under device search mode
    SCANNING,
    ///Reader is busy and not able to receive any downlink command
    BUSY,
    ///Reader is performing actions on the tags (inventory/read/write/etc) in the background but still able to receive specific downlink commands
    TAG_OPERATIONS,
    ///Indicates an internal error
    ERROR
};

@class CSLBleInterface;             //define class, so protocol can see CSLBleInterface class
/**
 Delegate of the Bluetooth LE interface events
 */
@protocol CSLBleInterfaceDelegate <NSObject>   //define delegate protocol
/**
 This will be triggered when the status of the reader changes
 @param sender CSLBleReader object of the connected reader
 */
- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender;     //triggered when reader state chagnes
@end //end protocol

/**
 Low-level Bluetooth LE communication using Apple Core Bluetooth framework
 */
@interface CSLBleInterface : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate> {
    ///Reader connection status
    STATUS connectStatus;
}

///Once reader is connect, the device name obtained during the discovery process will be stored in this property.
@property NSString * deviceName;
///Last exception being returned, if any.
@property NSException* LastException;
///Array of CBPeripheral object after device discovery
@property NSMutableArray * bleDeviceList;
///Connected BLE device
@property CBPeripheral* bleDevice;
///Queue for the data packets returned
@property CSLCircularQueue* recvQueue;
///Property for the connection status that is read-only
@property (readonly) STATUS connectStatus;
///instance of the CSLBleInterfaceDelegate delegate
@property (nonatomic, weak) id <CSLBleInterfaceDelegate> delegate; //define CSLBleReaderDelegate as delegate

/**
 initialization selector that:
 - initialize Core Bluetooth Manager
 - initialize device list
 - initialize queue for packets
 */
- (id) init;
/**
 dealloc selector that release selector to the delegates
 */
- (void) dealloc;
/**
 Start scanning for readers in the environment
 */
- (void) startScanDevice;
/**
 Stop scanning for readers in the environment
 */
- (void) stopScanDevice;
/**
 Connect to device
 @param peripheral Connect to the CBPeripheral object being returned during device scanning
 */
- (void) connectDevice:(CBPeripheral*) peripheral;
/**
 Disconnect device
 */
- (void) disconnectDevice;
/**
 Check if device returned is a Bluetooth LE compatiable hardware
 @return TRUE if hardware is Bluetooth LE capable
 */
- (BOOL) isLECapableHardware;
/**
 Send downlink data packet to reader
@param packet Send CSLBlePacket to the reader
 */
- (void) sendPackets:(CSLBlePacket *) packet;
/**
 Calculate checksum of the data
 @param dataIn Data in binary referenced by NSData
 @return Checksum referenced by NSData
 */
- (NSData *) computeChecksum: (NSData *) dataIn;

@end
