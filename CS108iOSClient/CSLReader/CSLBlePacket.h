//
//  CSLBlePacket.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 9/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
///Device ID
typedef NS_ENUM(Byte, DEVICEID)
{
    RFID = 0xc2,
    Barcode = 0x6a,
    Notification = 0xd9,
    SiliconLabIC = 0xe8,
    BluetoothIC = 0x5f
};
///Connection type (USB/Bluetooth)
typedef NS_ENUM(Byte, CONNECTION)
{
    USB = 0xE6,
    Bluetooth = 0xB3
};
///Direction of data transfer
typedef NS_ENUM(Byte, DIRECTION)
{
    Downlink = 0x37,
    Uplink=0x9E
};

/**
Data information of a Bluetooth LE packet
 */
@interface CSLBlePacket : NSObject
///prefix (0xA0)
@property (assign) Byte prefix;
///Connection type (USB/Bluetooth)
@property (assign) CONNECTION connection;
///Payload length 1 to 120
@property (assign) Byte payloadLength;
///Destination/Source (RFID/Barcode/Notification/Silicon Lab IC/Bluetooth IC)
@property (assign) DEVICEID deviceId;
///Reserved byte. 0x82 in most cases, or the sequence number of data stream
@property (assign) Byte Reserve;
///Direction (downlink/uplink)
@property (assign) DIRECTION direction;
///CRC of data packet (byte 1)
@property (assign) Byte crc1;
///CRC of data packet (byte 2)
@property (assign) Byte crc2;
///payload of data packet (first two bytes would be event code)
@property NSData* payload;

/**Return serialized packet data in hexdecimal string
 @return NSString of the hexdecimal data
 */
- (NSString*) getPacketInHexString;
/**Return serialized packet payload in hexdecimal string
 @return NSString of the hexdecimal data
 */
- (NSString*) getPacketPayloadInHexString;

@end
