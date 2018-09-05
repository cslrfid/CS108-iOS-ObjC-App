//
//  CSLBlePacket.h
//  CS108Playground
//
//  Created by Lam Ka Shun on 9/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _DEVICEID : Byte
{
    RFID = 0xc2,
    Barcode = 0x6a,
    Notification = 0xd9,
    SiliconLabIC = 0xe8,
    BluetoothIC = 0x5f
} DEVICEID;

typedef enum _CONNECTION : Byte
{
    USB = 0xE6,
    Bluetooth = 0xB3
} CONNECTION;

typedef enum _DIRECTION
{
    Downlink = 0x37,
    Uplink=0x9E
} DIRECTION;


@interface CSLBlePacket : NSObject
{
    Byte prefix;
    CONNECTION connection;
    Byte payloadLength;
    DEVICEID deviceId;
    Byte Reserve;
    DIRECTION direction;
    Byte crc1;
    Byte crc2;
    NSData* payload;
}
@property (assign) Byte prefix;
@property (assign) CONNECTION connection;
@property (assign) Byte payloadLength;
@property (assign) DEVICEID deviceId;
@property (assign) Byte Reserve;
@property (assign) DIRECTION direction;
@property (assign) Byte crc1;
@property (assign) Byte crc2;
@property (retain) NSData* payload;


- (NSData*) getPacketInHexString;
- (NSString*) getPacketPayloadInHexString;

@end
