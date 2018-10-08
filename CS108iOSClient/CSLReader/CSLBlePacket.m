//
//  CSLBlePacket.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 9/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLBlePacket.h"

@implementation CSLBlePacket

@synthesize prefix;
@synthesize connection;
@synthesize payloadLength;
@synthesize deviceId;
@synthesize Reserve;
@synthesize direction;
@synthesize crc1;
@synthesize crc2;
@synthesize payload;

- (NSString*) getPacketInHexString
{
    @try {
        int dlen=8+payloadLength;
        NSMutableString* hexStr = [NSMutableString stringWithCapacity:dlen];
        
        [hexStr appendFormat:@"%02X", prefix];
        [hexStr appendFormat:@"%02X", connection];
        [hexStr appendFormat:@"%02X", payloadLength];
        [hexStr appendFormat:@"%02X", deviceId];
        [hexStr appendFormat:@"%02X", Reserve];
        [hexStr appendFormat:@"%02X", direction];
        [hexStr appendFormat:@"%02X", crc1];
        [hexStr appendFormat:@"%02X", crc2];
        
        for(int i = 0; i < [payload length]; i++)
            [hexStr appendFormat:@"%02X", ((Byte*)[payload bytes])[i]];
        
        return [NSString stringWithString: hexStr];
    }
    @catch (NSException* exception)
    {
        NSLog(@"Exception on getPacketInHexString: %@", exception.description);
        
    }

}

- (NSString*) getPacketPayloadInHexString
{
    @try {
        int dlen=payloadLength;
        NSMutableString* hexStr = [NSMutableString stringWithCapacity:dlen];
        
        
        for(int i = 0; i < [payload length]; i++)
            [hexStr appendFormat:@"%02X", ((Byte*)[payload bytes])[i]];
        
        return [NSString stringWithString: hexStr];
    }
    @catch (NSException* exception)
    {
        NSLog(@"Exception on getPacketInHexString: %@", exception.description);
        
    }
    
}

@end
