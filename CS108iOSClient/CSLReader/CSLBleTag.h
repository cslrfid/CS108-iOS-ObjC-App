//
//  CSLBleTag.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 29/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
///Tag Access Command
typedef NS_ENUM(Byte, ACCESSCMD)
{
    READ = 0xC2,
    WRITE = 0xC3,
    KILL = 0xC4,
    LOCK = 0xC5,
    EAS = 0x04
};

/**
Tag data information
 */
@interface CSLBleTag : NSObject 

///Protocol Control bits
@property (assign) int PC;
///EPC data string
@property NSString * EPC;
///DATA1 string
@property NSString* DATA1;
///DATA1 length
@property (assign) Byte DATA1Length;
///DATA2 string
@property NSString* DATA2;
///DATA2 length
@property (assign) Byte DATA2Length;
///DATA1+DATA2 string
@property NSString* DATA;
///DATA1+DATA2 length
@property (assign) Byte DATALength;
///Return RRSI of the tag response
@property (assign) Byte rssi;
///Return timestamp of the tag readtime
@property NSDate* timestamp;
///CRC error flag
@property (assign) BOOL CRCError;
///command of the tag access operation
@property (assign) ACCESSCMD AccessCommand;
///Backscatter error flag with 0=no error, otherwise it represents the error code
@property (assign) Byte BackScatterError;
///ACK timeout flag
@property (assign) BOOL ACKTimeout;
///Antenna port tag being returned
@property (assign) int portNumber;
///Access Operation error flag with 0=no error, otherwise it represents the error code
@property (assign) Byte AccessError;


@end
