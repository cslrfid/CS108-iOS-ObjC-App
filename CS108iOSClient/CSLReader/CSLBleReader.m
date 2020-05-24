//
//  CSLBleReader.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 28/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLBleReader.h"

//define private methods and variables

@interface CSLBleReader() {
    CSLCircularQueue * cmdRespQueue;     //Buffer for storing response packet(s) after issuing a command synchronously
}
- (void) stopInventoryBlocking;

@end

@implementation CSLBleReader

@synthesize filteredBuffer;
@synthesize delegate; //synthesize CSLBleReaderDelegate delegate
@synthesize rangingTagCount;
@synthesize uniqueTagCount;
@synthesize batteryInfo;
@synthesize cmdRespQueue;

- (id) init
{
    if (self = [super init])
    {
        rangingTagCount=0;
        uniqueTagCount=0;
        batteryInfo=[[CSLReaderBattery alloc] initWithPcBVersion:1.8];
        cmdRespQueue=[[CSLCircularQueue alloc] initWithCapacity:16000];
    }
    return self;
}

- (void) dealloc
{
    
    
}

- (void) connectDevice:(CBPeripheral*) peripheral {

    [super connectDevice:peripheral];
    [self performSelectorInBackground:@selector(decodePacketsInBufferAsync) withObject:(nil)];
    
}

- (BOOL)readOEMData:(CSLBleInterface*)intf atAddr:(unsigned short)addr forData:(UInt32*)data
{
    @synchronized(self) {
        if (self.connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
    
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    UInt32 OEMData=0;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Read OEM data (address: 0x%X)...", addr);
    NSLog(@"----------------------------------------------------------------------");
    //read OEM Address
    unsigned char OEMAddr[] = {0x80, 0x02, 0x70, 0x01, 0x0, 0x05, addr & 0x000000FF, (addr & 0x0000FF00) >> 8, (addr & 0x00FF0000) >> 16, (addr & 0xFF000000) >> 24};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:OEMAddr length:sizeof(OEMAddr)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [intf sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] !=0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }

    if ([cmdRespQueue count] != 0)
        recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }

    if (memcmp([recvPacket.payload bytes], OEMAddr, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Set OEM data address: OK");
    else
    {
        NSLog(@"Set OEM data address: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    NSLog(@"Send HST_CMD 0x00000003 to read OEM data...");
    //Send HST_CMD
    unsigned char OEMHSTCMD[] = {0x80, 0x02, 0x70, 0x01, 0x0, 0xF0, 0x03, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:OEMHSTCMD length:sizeof(OEMHSTCMD)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [intf sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] >= 2)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] >= 2)
        recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
        
    //command-begin
    recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    if (([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] &&
         [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0080"]) ||
        ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"] &&
         [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0000"])
        ) {
        NSLog(@"Receive HST_CMD 0x03 command-begin response: OK");
    }
    else
    {
        NSLog(@"Receive HST_CMD 0x03 command-begin response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    //OEM read response
    if ([recvPacket.payload length] < 50) {
        NSLog(@"Receive HST_CMD 0x03 response (length check): FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    if (([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(36, 2)] isEqualToString:@"01"] &&
         [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(40, 4)] isEqualToString:@"0730"])) {

        OEMData = ((Byte *)[recvPacket.payload bytes])[30] +
        (((Byte *)[recvPacket.payload bytes])[31] << 8) +
        (((Byte *)[recvPacket.payload bytes])[32] << 16) +
        (((Byte *)[recvPacket.payload bytes])[33] << 24);
        
        *data = OEMData;


    }
    else
    {
        NSLog(@"Receive HST_CMD 0x03 command-begin response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }

    
    //command-end
    //recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    if (([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(68, 2)] isEqualToString:@"02"] ||
         [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(68, 2)] isEqualToString:@"01"]) &&
        ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(72, 4)] isEqualToString:@"0180"] ||
         [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(72, 4)] isEqualToString:@"0100"]) &&
        ((Byte *)[recvPacket.payload bytes])[46] == 0x00 &&
        ((Byte *)[recvPacket.payload bytes])[47] == 0x00) {
        self.lastMacErrorCode=(((Byte *)[recvPacket.payload bytes])[15] << 8) + (((Byte *)[recvPacket.payload bytes])[14]);
        NSLog(@"Receive HST_CMD 0x03 command-end response: OK");
    }
    else
    {
        NSLog(@"Receive HST_CMD 0x03 command-end response: FAILED");
        self.lastMacErrorCode=(((Byte *)[recvPacket.payload bytes])[15] << 8) + (((Byte *)[recvPacket.payload bytes])[14]);
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
    
}

- (BOOL)setFrequencyBand:(UInt32)frequencySelector bandState:(BOOL) config multdiv:(UInt32)mult_div pllcc:(UInt32) pll_cc {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Write selector address to register RFTC_FRQCH_SEL 0x0C01");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char FRQCH_SEL[] = {0x80, 0x02, 0x70, 0x01, 0x01, 0x0C, frequencySelector & 0xFF, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:FRQCH_SEL length:sizeof(FRQCH_SEL)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], FRQCH_SEL, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set FRQCH_SEL: OK");
        else {
            NSLog(@"Set FRQCH_SEL: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    packet= [[CSLBlePacket alloc] init];
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Write config address to register RFTC_FRQCH_CFG 0x0C02");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char FRQCH_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x0C, config ? 1 : 0, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:FRQCH_CFG length:sizeof(FRQCH_CFG)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], FRQCH_CFG, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set FRQCH_CFG: OK");
        else {
            NSLog(@"Set FRQCH_CFG: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    if (config) {
        packet= [[CSLBlePacket alloc] init];
        NSLog(@"----------------------------------------------------------------------");
        NSLog(@"Write multdiv address to register RFTC_FRQCH_DESC_PLLDIVMULT 0x0C03");
        NSLog(@"----------------------------------------------------------------------");
        
        unsigned char PLLDIVMULT[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x0C, mult_div & 0x000000FF, (mult_div & 0x0000FF00) >> 8, (mult_div & 0x00FF0000) >> 16, (mult_div & 0xFF000000) >> 24};
        packet.prefix=0xA7;
        packet.connection = Bluetooth;
        packet.payloadLength=0x0A;
        packet.deviceId=RFID;
        packet.Reserve=0x82;
        packet.direction=Downlink;
        packet.crc1=0;
        packet.crc2=0;
        packet.payload=[NSData dataWithBytes:PLLDIVMULT length:sizeof(PLLDIVMULT)];
        
        NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
        [self sendPackets:packet];
        
        for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
            if([cmdRespQueue count] != 0)
                break;
            [NSThread sleepForTimeInterval:0.001f];
        }
        
        if ([cmdRespQueue count] != 0) {
            recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
            if (memcmp([recvPacket.payload bytes], PLLDIVMULT, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
                NSLog(@"Set PLLDIVMULT: OK");
            else {
                NSLog(@"Set PLLDIVMULT: FAILED");
                connectStatus=CONNECTED;
                [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                return false;
            }
        }
        else {
            NSLog(@"Command response failure.");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
        
        packet= [[CSLBlePacket alloc] init];
        NSLog(@"----------------------------------------------------------------------");
        NSLog(@"Write PLLCC address to register RFTC_FRQCH_DESC_PLLDACCTL 0x0C04");
        NSLog(@"----------------------------------------------------------------------");
        
        unsigned char PLLCC[] = {0x80, 0x02, 0x70, 0x01, 0x04, 0x0C, pll_cc & 0x000000FF, (pll_cc & 0x0000FF00) >> 8, (pll_cc & 0x00FF0000) >> 16, (pll_cc & 0xFF000000) >> 24};
        packet.prefix=0xA7;
        packet.connection = Bluetooth;
        packet.payloadLength=0x0A;
        packet.deviceId=RFID;
        packet.Reserve=0x82;
        packet.direction=Downlink;
        packet.crc1=0;
        packet.crc2=0;
        packet.payload=[NSData dataWithBytes:PLLCC length:sizeof(PLLCC)];
        
        NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
        [self sendPackets:packet];
        
        for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
            if([cmdRespQueue count] != 0)
                break;
            [NSThread sleepForTimeInterval:0.001f];
        }
        
        if ([cmdRespQueue count] != 0) {
            recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
            if (memcmp([recvPacket.payload bytes], PLLCC, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
                NSLog(@"Set PLLCC: OK");
            else {
                NSLog(@"Set PLLCC: FAILED");
                connectStatus=CONNECTED;
                [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                return false;
            }
        }
        else {
            NSLog(@"Command response failure.");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;

}

- (BOOL) SetHoppingChannel:(CSLReaderFrequency*) frequencyInfo RegionCode:(NSString*)region {
    
    UInt32 channelCount=(UInt32)[(NSArray*)frequencyInfo.FrequencyValues[region] count];
    
    //Enable channels
    for (UInt32 i = 0; i < channelCount; i++)
    {
        
        if (![self setFrequencyBand:i
                     bandState:true
                       multdiv:[[((NSArray*)[frequencyInfo.FrequencyValues objectForKey:region]) objectAtIndex:i] unsignedIntValue]
                         pllcc:[self GetPllcc:region]])
            return false;

    }

    //Disable channels
    for (UInt32 i = channelCount; i < 50; i++)
    {
        if (![self setFrequencyBand:channelCount
                     bandState:false
                       multdiv:0
                         pllcc:0])
            return false;
    }
    return true;
}

- (BOOL) SetFixedChannel:(CSLReaderFrequency*) frequencyInfo RegionCode:(NSString*)region channelIndex:(UInt32)index {
    
    //get the frequncy value of the selected index
    int ind=[[((NSArray*)[frequencyInfo.FrequencyIndex objectForKey:region]) objectAtIndex:index] unsignedIntValue];
    UInt32 frequencyValue=[[((NSArray*)[frequencyInfo.FrequencyValues objectForKey:region]) objectAtIndex:ind] unsignedIntValue];
    
    
    //Enable channel
    if(![self setFrequencyBand:0
                 bandState:true
                   multdiv:frequencyValue
                     pllcc:[self GetPllcc:region]])
        return false;

    //Disable channels
    for (uint i = 1; i < 50; i++)
    {
        if(![self setFrequencyBand:i
                     bandState:false
                       multdiv:0
                         pllcc:0])
            return false;
    }

    return true;
}

- (UInt32) GetPllcc:(NSString*) region {


     if ([region isEqualToString:@"G800"] ||
         [region isEqualToString:@"ETSI"] ||
         [region isEqualToString:@"IN"]) {
         
         return 0x14070400;
     }
            
     return 0x14070200;
}
         
- (BOOL)setLNAParameters:(CSLBleInterface*)intf rflnaHighComp:(Byte)rflna_high_comp rflnaGain:(Byte)rflna_gain iflnaGain:(Byte)iflna_gain ifagcGain:(Byte)ifagc_gain
{
    @synchronized(self) {
        if (self.connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
    
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Write HST_MBP_ADDR (address: 0x0400)...");
    NSLog(@"----------------------------------------------------------------------");
    //Write address 0x0405 for ANA_RX_GAIN_NORM
    unsigned int addr = 0x0405;
    unsigned char MBPAddr[] = {0x80, 0x02, 0x70, 0x01, 0x00, 0x04, addr & 0x000000FF, (addr & 0x0000FF00) >> 8, (addr & 0x00FF0000) >> 16, (addr & 0xFF000000) >> 24};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:MBPAddr length:sizeof(MBPAddr)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [intf sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] !=0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }

    if ([cmdRespQueue count] != 0)
        recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }

    if (memcmp([recvPacket.payload bytes], MBPAddr, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Set MBP address: OK");
    else
    {
        NSLog(@"Set MBP address: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    packet= [[CSLBlePacket alloc] init];
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Write HST_MBP_DATA (address: 0x0401)...");
    NSLog(@"----------------------------------------------------------------------");
    //Write address 0x0405 for ANA_RX_GAIN_NORM
    unsigned int data = (ifagc_gain & 0x07) || ((iflna_gain & 0x07) << 3) || ((rflna_gain & 0x03) << 6) || ((rflna_high_comp & 0x1) << 7);
    unsigned char MBPData[] = {0x80, 0x02, 0x70, 0x01, 0x01, 0x04, data & 0x000000FF, (data & 0x0000FF00) >> 8, (data & 0x00FF0000) >> 16, (data & 0xFF000000) >> 24};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:MBPData length:sizeof(MBPData)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [intf sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] !=0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }

    if ([cmdRespQueue count] != 0)
        recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }

    if (memcmp([recvPacket.payload bytes], MBPData, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Set MBP data: OK");
    else
    {
        NSLog(@"Set MBP data: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    NSLog(@"Send HST_CMD 0x00000006 to write to tilden register...");
    //Send HST_CMD
    unsigned char TILHSTCMD[] = {0x80, 0x02, 0x70, 0x01, 0x0, 0xF0, 0x06, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TILHSTCMD length:sizeof(TILHSTCMD)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [intf sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] >= 2)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] >= 1)
        recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    

    if (memcmp([recvPacket.payload bytes], TILHSTCMD, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Receive HST_CMD 0x06 response: OK");
    else
    {
        NSLog(@"Receive HST_CMD 0x06 response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return TRUE;
}

- (BOOL)setImpinjExtension:(Byte)tag_Focus fastId:(Byte)fast_id blockWriteMode:(Byte)blockwrite_mode  {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set Impinj extension register
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set Impinj extension register 0x0203");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned int value=(blockwrite_mode & 0x0F) || ((tag_Focus & 0x01) << 4) || ((fast_id & 0x01) << 5);
    unsigned char IMPJ_EXT[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x02, value & 0xFF, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:IMPJ_EXT length:sizeof(IMPJ_EXT)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], IMPJ_EXT, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set Impinj extension: OK");
        else {
            NSLog(@"Set Impinj extension: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)barcodeReader:(BOOL)enable
{
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];

    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    //power on barcode
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Power %s barcode module...", enable ? "on" : "off");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char barcodeOn[]= {0x90, 0x00};
    if (!enable)
        barcodeOn[1]=0x01;
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02;
    packet.deviceId=Barcode;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:barcodeOn length:sizeof(barcodeOn)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    if ([cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], barcodeOn, sizeof(barcodeOn)) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"Power %s barcode module OK", enable ? "on" : "off");
        return true;
    }
    else {
        NSLog(@"Power %s barcode module FAILED", enable ? "on" : "off");
        return false;
    }
}


- (BOOL)barcodeReaderSendCommand:(NSData*)command
{
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];

    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    //power on barcode
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Send command to barcode reader");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char barcodeCmd[]= {0x90, 0x03};
    unsigned char barcodeRsp[]= {0x91, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02+[command length];
    packet.deviceId=Barcode;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    
    NSMutableData *payload = [[NSData dataWithBytes:barcodeCmd length:sizeof(barcodeCmd)] mutableCopy];
    [payload appendData:command];
    packet.payload=[payload copy];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] > 1)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    if ([cmdRespQueue count] > 1)
        payloadData = ((CSLBlePacket *)[cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    if (memcmp([payloadData bytes], barcodeCmd, sizeof(barcodeCmd)) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"Send barcode command OK");
    }
    else {
        NSLog(@"end barcode command FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    payloadData = ((CSLBlePacket *)[cmdRespQueue deqObject]).payload;

    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], barcodeRsp, sizeof(barcodeRsp)) == 0 && ((Byte *)[payloadData bytes])[2] == 0x06) {
        NSLog(@"Barcode command ACCEPTED");
        return true;
    }
    else {
        NSLog(@"Barcode command REJECTED");
        return false;
    }
    
    
}

- (BOOL)sendBarcodeCommandData: (NSData*)data
{
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    //power on barcode
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@" Send command to barcode ");
    NSLog(@"----------------------------------------------------------------------");
    //unsigned char barcodeStart[] = {0x90, 0x03, 0x1b, 0x33};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x04;
    packet.deviceId=Barcode;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithData:data];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    if ([cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], [data bytes], 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"Send barcode command OK");
        return true;
    }
    else {
        NSLog(@"Sned barcode command FAILED");
        return false;
    }
}


- (BOOL)startBarcodeReading
{
    unsigned char dataBytes[] = {0x1B, 0x33};
    NSData* data=[NSData dataWithBytes:dataBytes length:2];
    NSLog(@"Start barcode reading...");
    if ([self barcodeReaderSendCommand:data])
        return true;
    else
        return false;
}

- (BOOL)stopBarcodeReading
{
    unsigned char dataBytes[] = {0x1B, 0x30};
    NSData* data=[NSData dataWithBytes:dataBytes length:2];
    NSLog(@"Stop barcode reading...");
    if ([self barcodeReaderSendCommand:data])
        return true;
    else
        return false;
}

- (BOOL)powerOnRfid:(BOOL)enable
{
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    //power RFID
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Power %s RFID module...", enable ? "on" : "off");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char powerRfid[] = {0x80, (enable ? 0x00 : 0x01)};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:powerRfid length:sizeof(powerRfid)];

    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];

    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    if ([cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], powerRfid, sizeof(powerRfid)) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"Power %s RFID module OK", (enable ? "on" : "off"));
        return true;
    }
    else {
        NSLog(@"Power %s RFID module FAILED", (enable ? "on" : "off"));
        return false;
    }
}
- (BOOL)getBtFirmwareVersion:(NSString **)versionNumber
{
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * versionInfo;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Get Bluetooth IC firmware version...");
    NSLog(@"----------------------------------------------------------------------");
    //Get BT IC FW version
    unsigned char getBTFWVersion[] = {0xC0, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02;
    packet.deviceId=BluetoothIC;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:getBTFWVersion length:sizeof(getBTFWVersion)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];

    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
       if([cmdRespQueue count] != 0)
           break;
           [NSThread sleepForTimeInterval:0.001f];
    }
    if ([cmdRespQueue count] != 0)
        versionInfo = ((CSLBlePacket *)[cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        NSLog(@"Get BT IC firmware version: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    NSString * btFwVersion = [NSString stringWithFormat:@"%d.%d.%d", ((Byte*)[versionInfo bytes])[2], ((Byte*)[versionInfo bytes])[3], ((Byte*)[versionInfo bytes])[4]];
    NSLog(@"Bluetooth IC firmware version: %@", btFwVersion);
    
    *versionNumber=btFwVersion;
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL) getConnectedDeviceName:(NSString **) deviceName
{
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];

    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Get device name...");
    NSLog(@"----------------------------------------------------------------------");
    //Get device name
    unsigned char dev[] = {0xC0, 0x04};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02;
    packet.deviceId=BluetoothIC;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:dev length:sizeof(dev)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
            [NSThread sleepForTimeInterval:0.001f];
    }
        
    if ([cmdRespQueue count] != 0) {
        NSData * name = [((CSLBlePacket *)[cmdRespQueue deqObject]).payload subdataWithRange:NSMakeRange(2, 21)];
        *deviceName = [NSString stringWithUTF8String:[name bytes]];
        NSLog(@"Device Name: %@", *deviceName);
    }
    else {
        NSLog(@"Command timed out.");
        NSLog(@"Get connected device name: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}
- (BOOL)getSilLabIcVersion:(NSString **) slVersion
{
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Get SilconLab IC firmware version...");
    NSLog(@"----------------------------------------------------------------------");

    //Get SilconLab IC firmware version
    unsigned char SiLabFWVersion[] = {0xB0, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02;
    packet.deviceId=SiliconLabIC;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:SiLabFWVersion length:sizeof(SiLabFWVersion)];

    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];

    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    if ([cmdRespQueue count] != 0) {
        NSData * versionInfo = ((CSLBlePacket *)[cmdRespQueue deqObject]).payload;
        *slVersion=[NSString stringWithFormat:@"%d.%d.%d", ((Byte*)[versionInfo bytes])[2], ((Byte*)[versionInfo bytes])[3], ((Byte*)[versionInfo bytes])[4]];
        NSLog(@"SilconLab IC firmware version: %@", *slVersion);
    }
    else {
        NSLog(@"Command timed out.");
        NSLog(@"Get SilconLab IC firmware version: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}


- (BOOL)getRfidBrdSerialNumber:(NSString**) serialNumber {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];

    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Get 13 bytes serial number...");
    NSLog(@"----------------------------------------------------------------------");
    //Get 16 bytes serial number
    unsigned char sn[] = {0xB0, 0x04, 00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x03;
    packet.deviceId=SiliconLabIC;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:sn length:sizeof(sn)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        CSLBlePacket* packet = (CSLBlePacket *)[cmdRespQueue deqObject];
        if ([packet.payload length] >= 15) {
            NSData * name = [packet.payload subdataWithRange:NSMakeRange(2, 13)];
            *serialNumber=[NSString stringWithUTF8String:[name bytes]];
            NSLog(@"13 byte serial number: %@", *serialNumber);
        }
    }
    if ([*serialNumber length] != 13) {
        NSLog(@"Get 13 byte serial number: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)getPcBBoardVersion:(NSString**) boardVersion {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Get board version...");
    NSLog(@"----------------------------------------------------------------------");
    //Get 16 bytes serial number
    unsigned char sn[] = {0xB0, 0x04, 00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x03;
    packet.deviceId=SiliconLabIC;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:sn length:sizeof(sn)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        CSLBlePacket* packet=(CSLBlePacket *)[cmdRespQueue deqObject];
        if([packet.payload length]>=18) {
            NSData * name =[packet.payload subdataWithRange:NSMakeRange(15, 3)];
            *boardVersion=[NSString stringWithFormat:@"%@.%@", [[NSString stringWithUTF8String:[name bytes]] substringToIndex:1], [[NSString stringWithUTF8String:[name bytes]] substringFromIndex:1]];
            NSLog(@"PCB board version: %@", *boardVersion);
        }
    }
    if([*boardVersion length] < 3) {
        NSLog(@"Command timed out.");
        NSLog(@"Get PCB board version: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}


- (BOOL)sendAbortCommand {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED && connectStatus!=TAG_OPERATIONS)  //reader is not idling for downlink command and not performing inventory
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
    }
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket* recvPacket;
    BOOL isAborted=false;

    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Abort command...");
    NSLog(@"----------------------------------------------------------------------");
    //Send abort command
    unsigned char abortCmd[] = {0x80, 0x02, 0x40, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:abortCmd length:sizeof(abortCmd)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
                
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] !=0)
        {
            recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
            if ([[recvPacket getPacketPayloadInHexString] containsString:@"4003BFFCBFFCBFFC"]) {
                isAborted=true;
                break;
            }
            
        }
        else
            [NSThread sleepForTimeInterval:0.1f];
    }
    
    if (isAborted) {
        NSLog(@"Abort command: OK");
        return true;
    }
    else {
        NSLog(@"Abort command response: FAILED");
        return false;
    }

}

- (BOOL)startBatteryAutoReporting {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED && connectStatus!=TAG_OPERATIONS)  //reader is not idling for downlink command and not performing inventory
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
    }
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket* recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Start battery auto reporting command...");
    NSLog(@"----------------------------------------------------------------------");
    //Send abort command
    unsigned char startBattReporting[] = {0xA0, 0x02};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02;
    packet.deviceId=Notification;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:startBattReporting length:sizeof(startBattReporting)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] !=0)
    {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], startBattReporting, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Start battery auto reporting sent: OK");
        else {
            NSLog(@"Start battery auto reporting sent: FAILED");
            connectStatus=CONNECTED;
            return false;
        }
        
    }
    else {
        NSLog(@"Command timed out.");
        NSLog(@"Start battery auto reporting: FAILED");
        connectStatus=CONNECTED;
        return false;
    }
    connectStatus=CONNECTED;
    return true;
}

- (BOOL)stopBatteryAutoReporting {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED && connectStatus!=TAG_OPERATIONS)  //reader is not idling for downlink command and not performing inventory
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
    }
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket* recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Stop battery auto reporting command...");
    NSLog(@"----------------------------------------------------------------------");
    //Send abort command
    unsigned char startBattReporting[] = {0xA0, 0x03};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x02;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:startBattReporting length:sizeof(startBattReporting)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] !=0)
    {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], startBattReporting, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Stop battery auto reporting sent: OK");
        else {
            NSLog(@"Stop battery auto reporting sent: FAILED");
            connectStatus=CONNECTED;
            return false;
        }
        
    }
    else {
        NSLog(@"Command timed out.");
        NSLog(@"Stop battery auto reporting: FAILED");
        connectStatus=CONNECTED;
        return false;
    }
    connectStatus=CONNECTED;
    return true;
}


- (BOOL)getRfidFwVersionNumber:(NSString**) versionInfo {

    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Read regiseter 0x0000 FW version...");
    NSLog(@"----------------------------------------------------------------------");
    //Send abort
    unsigned char rfidFWVersion[] = {0x80, 0x02, 0x70, 0x00, 0x0, 0x00, 0x00, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:rfidFWVersion length:sizeof(rfidFWVersion)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] >= 2)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] >= 2) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], rfidFWVersion, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"RFID firmware version command sent: OK");
        else {
            NSLog(@"RFID firmware version command sent: FAILED");
            connectStatus=CONNECTED;
            return false;
        }
    }
        
    recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
    unsigned short byte1, byte2, byte3, byte4;
    if (((Byte*)[recvPacket.payload bytes])[4] == 0x00 && ((Byte*)[recvPacket.payload bytes])[5] == 0x00 && [recvPacket.payload length] == 10) {
        byte1 = ((Byte*)[recvPacket.payload bytes])[6];
        byte2 = ((Byte*)[recvPacket.payload bytes])[7];
        byte3 = ((Byte*)[recvPacket.payload bytes])[8];
        byte4 = ((Byte*)[recvPacket.payload bytes])[9];
        *versionInfo=[NSString stringWithFormat:@"%d.%d.%d", byte4, ((byte2 >> 4) & 0x0F) + ((byte3 << 4) & 0xF00), (byte2 & 0x0F) + byte1];
        NSLog(@"RFID firmware: %@", *versionInfo);
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}
    
- (BOOL)setPower:(double) powerInDbm {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set antenna power (ANT_PORT_POWER) command reg_addr=0x0706
    unsigned int power=(unsigned int)(powerInDbm / 0.1);
    unsigned char ANT_PORT_POWER[] = {0x80, 0x02, 0x70, 0x01, 0x06, 0x07, power & 0x000000FF, (power & 0x0000FF00) >> 8, (power & 0x00FF0000) >> 16, (power & 0xFF000000) >> 24};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:ANT_PORT_POWER length:sizeof(ANT_PORT_POWER)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], ANT_PORT_POWER, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set antenna power command sent: OK");
        else {
            NSLog(@"Set antenna power command sent: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
        
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setAntennaCycle:(NSUInteger) cycles {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set antenna cycles (ANT_CYCLES) to loop forever
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set antenna cycles (ANT_CYCLES)...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char ANT_CYCLES[] = {0x80, 0x02, 0x70, 0x01, 0x00, 0x07, cycles & 0xFF, (cycles & 0xFF00) >> 8, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:ANT_CYCLES length:sizeof(ANT_CYCLES)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], ANT_CYCLES, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set antenna cycles: OK");
        else {
            NSLog(@"Set antenna cycles: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setAntennaDwell:(NSUInteger) timeInMilliseconds {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set antenna port dwell time (ANT_PORT_DWELL)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set antenna port dwell time (ANT_PORT_DWELL)...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char ANT_DWELL[] = {0x80, 0x02, 0x70, 0x01, 0x05, 0x07, timeInMilliseconds & 0xFF, (timeInMilliseconds & 0xFF00) >> 8, (timeInMilliseconds & 0xFF0000) >> 16, (timeInMilliseconds & 0xFF000000) >> 24};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:ANT_DWELL length:sizeof(ANT_DWELL)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], ANT_DWELL, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set antenna dwell: OK");
        else {
            NSLog(@"Set antenna dwell: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)selectAntennaPort:(NSUInteger) portIndex {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Select antenna port (ANT_PORT_SEL)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Select antenna port (ANT_PORT_SEL)...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char ANT_PORT[] = {0x80, 0x02, 0x70, 0x01, 0x01, 0x07, portIndex & 0xF, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:ANT_PORT length:sizeof(ANT_PORT)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], ANT_PORT, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set antenna port: OK");
        else {
            NSLog(@"Set antenna port: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setAntennaConfig:(BOOL)isEnable
           InventoryMode:(Byte)mode
           InventoryAlgo:(Byte)algo
                  StartQ:(Byte)qValue
             ProfileMode:(Byte)pMode
                 Profile:(Byte)pValue
           FrequencyMode:(Byte)fMode
        FrequencyChannel:(Byte)fChannel
            isEASEnabled:(BOOL)eas {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set antenna config (ANT_PORT_CFG)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set antenna config (ANT_PORT_CFG)...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char ANT_PORT_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x07, isEnable | ((mode & 0x01) << 1) | ((algo & 0x03) << 2) | ((qValue & 0x0F) << 4), pMode | ((pValue & 0x0F) << 1) | ((fMode & 0x01) << 5) | ((fChannel & 0x03) << 6), ((fChannel & 0x3C) >> 6) | (eas << 4), 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:ANT_PORT_CFG length:sizeof(ANT_PORT_CFG)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], ANT_PORT_CFG, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set antenna port config: OK");
        else {
            NSLog(@"Set antenna port config: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setAntennaInventoryCount:(NSUInteger) count {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set antenna inventory count (ANT_PORT_INV_CNT)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set antenna inventory count (ANT_PORT_INV_CNT)...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char ANT_INV_CNT[] = {0x80, 0x02, 0x70, 0x01, 0x07, 0x07, count & 0xFF, (count & 0xFF00) >> 8, (count & 0xFF0000) >> 16, (count & 0xFF000000) >> 24};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:ANT_INV_CNT length:sizeof(ANT_INV_CNT)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], ANT_INV_CNT, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set antenna dwell: OK");
        else {
            NSLog(@"Set antenna dwell: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}





- (BOOL)selectAlgorithmParameter:(QUERYALGORITHM) algorithm {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
    //unsigned int desc_idx=3;    //select algortihm #3 (Dyanmic Q)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Select which set of algorithm parameter registers to access (INV_SEL)...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char INV_SEL[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x09, algorithm & 0x000000FF, (algorithm & 0x0000FF00) >> 8, (algorithm & 0x00FF0000) >> 16, (algorithm & 0xFF000000) >> 24};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:INV_SEL length:sizeof(INV_SEL)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], INV_SEL, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Select which set of algorithm parameter registers: OK");
        else {
            NSLog(@"Select which set of algorithm parameter registers: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setInventoryAlgorithmParameters0:(Byte) startQ maximumQ:(Byte)maxQ minimumQ:(Byte)minQ ThresholdMultiplier:(Byte)tmult  {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    //Set algorithm parameters (INV_ALG_PARM_0) for DynamicQ reg_addr = 0x0901
    //Byte startQ=6, maxQ=15, minQ=0, tmult=4;
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set algorithm parameters (INV_ALG_PARM_0) addr:0x0903");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char INV_ALG_PARM[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x09, (startQ & 0x0F) + ((maxQ & 0x0F) << 4), (minQ & 0x0F) + ((tmult & 0x0F) << 4), (tmult & 0xF0) >> 4, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:INV_ALG_PARM length:sizeof(INV_ALG_PARM)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], INV_ALG_PARM, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set algorithm parameter 0: OK");
        else {
            NSLog(@"Set algorithm parameter 0: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setInventoryAlgorithmParameters1:(Byte) retry {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set algorithm parameters (INV_ALG_PARM_1)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set algorithm parameters (INV_ALG_PARM_1) addr:0x0904");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char INV_ALG_PARM[] = {0x80, 0x02, 0x70, 0x01, 0x04, 0x09, retry, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:INV_ALG_PARM length:sizeof(INV_ALG_PARM)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], INV_ALG_PARM, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set algorithm parameter 1: OK");
        else {
            NSLog(@"Set algorithm parameter 1: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setInventoryAlgorithmParameters2:(BOOL) toggle RunTillZero:(BOOL)rtz {
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Set algorithm parameters (INV_ALG_PARM_1)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set algorithm parameters (INV_ALG_PARM_2) addr:0x0905");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char INV_ALG_PARM[] = {0x80, 0x02, 0x70, 0x01, 0x05, 0x09, toggle + (rtz << 1), 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:INV_ALG_PARM length:sizeof(INV_ALG_PARM)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], INV_ALG_PARM, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set algorithm parameter 2: OK");
        else {
            NSLog(@"Set algorithm parameter 2: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setInventoryConfigurations:(QUERYALGORITHM) inventoryAlgorithm MatchRepeats:(Byte)match_rep tagSelect:(Byte)tag_sel disableInventory:(Byte)disable_inventory tagRead:(Byte)tag_read crcErrorRead:(Byte) crc_err_read QTMode:(Byte) QT_mode tagDelay:(Byte) tag_delay inventoryMode:(Byte)inv_mode {
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
        
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
    //Byte Inv_algo=0x03, match_rep=0, tag_sel=0, disable_inv=0, tag_read=0, crc_err_read=1, QT_mode=0, tag_delay=0, inv_mode=1;  //inventory algorithm #3, enable crc error read, compact mode inventory
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set inventory configurations (INV_CFG) addr:0x0901...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char INV_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x01, 0x09, (inventoryAlgorithm & 0x3F) + ((match_rep & 0x03) << 6), ((match_rep & 0xFC) >> 2) + ((tag_sel & 0x01) << 6) + ((disable_inventory & 0x01) << 7), (tag_read & 0x03) + ((crc_err_read & 0x01) << 2) + ((QT_mode & 0x01) << 3) + ((tag_delay & 0x0F) << 4), ((tag_delay & 0x30) >> 4) + ((inv_mode & 0x01) << 2)};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:INV_CFG length:sizeof(INV_CFG)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], INV_CFG, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Set inventory configurations: OK");
        else {
            NSLog(@"Set inventory configurations: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setQueryConfigurations:(TARGET) queryTarget querySession:(SESSION)query_session querySelect:(QUERYSELECT)query_sel {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
        
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
    //Byte query_target=0x00, query_session=1, query_sel=0;
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Configure parameters on query and inventory operations (QUERY_CFG) addr:0x0900");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char QUERY_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x00, 0x09, ((queryTarget & 0x01) << 4) + ((query_session & 0x03) << 5) + ((query_sel & 0x01) << 7), ((query_sel & 0x02) >> 1), 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:QUERY_CFG length:sizeof(QUERY_CFG)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], QUERY_CFG, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Configure parameters on query and inventory operations: OK");
        else {
            NSLog(@"Configure parameters on query and inventory operations: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL)setLinkProfile:(LINKPROFILE) profile
{
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set link profile...");
    NSLog(@"----------------------------------------------------------------------");
    //read OEM Address
    unsigned char linkProfile[] = {0x80, 0x02, 0x70, 0x01, 0x60, 0x0B, profile, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:linkProfile length:sizeof(linkProfile)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] !=0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0)
        recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    if (memcmp([recvPacket.payload bytes], linkProfile, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Set link profile: OK");
    else
    {
        NSLog(@"Set link profile: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    NSLog(@"Send HST_CMD 0x00000019 to set link profile...");
    //Send HST_CMD
    unsigned char OEMHSTCMD[] = {0x80, 0x02, 0x70, 0x01, 0x0, 0xF0, 0x19, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:OEMHSTCMD length:sizeof(OEMHSTCMD)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([cmdRespQueue count] >= 3) //command response + command begin + command end
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] >= 3)
        recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    if (memcmp([recvPacket.payload bytes], OEMHSTCMD, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Receive HST_CMD 0x19 response: OK");
    else
    {
        NSLog(@"Receive HST_CMD 0x19 response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    //command-begin
    recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    if (([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0080"]) ||
        ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0000"])
        ) {
        self.lastMacErrorCode=0x0000;
        NSLog(@"Receive HST_CMD 0x19 command-begin response: OK");
    }
    else
    {
        NSLog(@"Receive HST_CMD 0x19 command-begin response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    //command-end
    recvPacket = ((CSLBlePacket *)[cmdRespQueue deqObject]);
    if (([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] || [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"]) &&
        ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0180"] || [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0100"]) &&
        ((Byte *)[recvPacket.payload bytes])[14] == 0x00 &&
        ((Byte *)[recvPacket.payload bytes])[15] == 0x00) {
        self.lastMacErrorCode=(((Byte *)[recvPacket.payload bytes])[15] << 8) + (((Byte *)[recvPacket.payload bytes])[14]);
        NSLog(@"Receive HST_CMD 0x19 command-end response: OK");
    }
    else
    {
        NSLog(@"Receive HST_CMD 0x19 command-end response: FAILED");
        self.lastMacErrorCode=(((Byte *)[recvPacket.payload bytes])[15] << 8) + (((Byte *)[recvPacket.payload bytes])[14]);
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return TRUE;
}

-(BOOL)startInventory {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED)
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
        
        connectStatus=BUSY;
        rangingTagCount=0;
        uniqueTagCount=0;
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Start inventory...");
    NSLog(@"----------------------------------------------------------------------");
    
    NSLog(@"Send start inventory...");
    unsigned char cmd[] = {0x80, 0x02, 0x70, 0x01, 0x00, 0xF0, 0x0F, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:cmd length:sizeof(cmd)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);

    [self sendPackets:packet];

    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([cmdRespQueue count] != 0)
            break;
        [NSThread sleepForTimeInterval:0.001f];
    }
    
    if ([cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], cmd, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"Start inventory: OK");
        else {
            NSLog(@"Start inventory: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
    }
    else {
        NSLog(@"Command response failure.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    self.isTagAccessMode=false;
    connectStatus=TAG_OPERATIONS;
    //[self performSelectorInBackground:@selector(decodePacketsInBufferAsync) withObject:(nil)];
    return true;
}

-(BOOL)stopInventory {
    
    //retry multiple times in case rfid module is busy on receiving the abort command
    for (int j=0;j<3;j++)
    {
        [self performSelectorInBackground:@selector(stopInventoryBlocking) withObject:(nil)];
        
        for (int i=0;i<COMMAND_TIMEOUT_3S;i++) {  //receive data or time out in 3 seconds
            ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]);
            if(connectStatus == CONNECTED)
                break;
        }
        if (connectStatus != CONNECTED)
        {
            NSLog(@"Abort command response failure.  Try #%d", j+1);
            continue;
        }
        else
        {
            NSLog(@"Abort command response: OK");
            break;
        }
        
    }
    
    return ((connectStatus != CONNECTED) ? false : true);

}

-(void)stopInventoryBlocking {
    
    @autoreleasepool {
        //Initialize data
        CSLBlePacket* packet= [[CSLBlePacket alloc] init];
        
        if (connectStatus==TAG_OPERATIONS)
        {
            NSLog(@"----------------------------------------------------------------------");
            NSLog(@"Abort command for inventory...");
            NSLog(@"----------------------------------------------------------------------");
            //Send abort command
            unsigned char abortCmd[] = {0x80, 0x02, 0x40, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
            packet.prefix=0xA7;
            packet.connection = Bluetooth;
            packet.payloadLength=0x0A;
            packet.deviceId=RFID;
            packet.Reserve=0x82;
            packet.direction=Downlink;
            packet.crc1=0;
            packet.crc2=0;
            packet.payload=[NSData dataWithBytes:abortCmd length:sizeof(abortCmd)];
            
            NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
            [self sendPackets:packet];
            [self sendPackets:packet];
            [self sendPackets:packet];
        }
    }

}

- (void)decodePacketsInBufferAsync;
{
    CSLBlePacket* packet;
    CSLReaderBarcode* barcode;
    NSString * eventCode;
    NSMutableData* rfidPacketBuffer;    //buffer to all packets returned by the rfid module
    NSString* rfidPacketBufferInHexString;
    unsigned char ecode[] = {0x81, 0x00};
    NSMutableData* tempMutableData;
    
    filteredBuffer=[[NSMutableArray alloc] init];
    rfidPacketBuffer=[[NSMutableData alloc] init];
    rfidPacketBufferInHexString=[[NSString alloc] init];
    
    int datalen;        //data length given on the RFID packet
    int sequenceNumber=0;
    
    while (self.bleDevice)  //packet decoding will continue as long as there is a connected device instance
    {
        @autoreleasepool {
            @synchronized(self.recvQueue) {
                if ([self.recvQueue count] > 0)
                {
                    //dequque the next packet received
                    packet=((CSLBlePacket *)[self.recvQueue deqObject]);
                    if ([packet isKindOfClass:[NSNull class]]) {
                        continue;
                    }
                    
                    if (packet.direction==Uplink && packet.deviceId==RFID) {
                        
                        NSLog(@"[decodePacketsInBufferAsync] Current sequence number: %d", sequenceNumber);
                        
                        //validate checksum of packet
                        if (!packet.isCRCPassed) {
                            NSLog(@"[decodePacketsInBufferAsync] Checksum verification failed.  Discarding data in buffer");
                            [rfidPacketBuffer setLength:0];
                            continue;
                        }
                    
                        if ([rfidPacketBuffer length] == 0)
                            sequenceNumber=packet.Reserve;
                        else {
                            if (packet.Reserve != (sequenceNumber+1)) {
                                NSLog(@"[decodePacketsInBufferAsync] Packet out-of-order based on sequence number.  Discarding data in buffer");
                                [rfidPacketBuffer setLength:0];
                                continue;
                            }
                            else
                                sequenceNumber++;
                        }
                    }
                }
                else
                    continue;
            }
            
            NSLog(@"[decodePacketsInBufferAsync] RFID Packet buffer before arrival for packet: %@", [rfidPacketBuffer length] == 0 ? @"(EMPTY)" : [CSLBleReader convertDataToHexString:rfidPacketBuffer]);
            //append ble payload to the rfid packet buffer
            if ([rfidPacketBuffer length] == 0) {
                [rfidPacketBuffer appendData:packet.payload];
            }
            else {
                //if there were partial packet from previous iteration, append the current data after stripping out the event code and header information
                if ([[[CSLBleReader convertDataToHexString:rfidPacketBuffer] substringToIndex:4] isEqualToString:@"8100"] && packet.payloadLength>=2 && [[[CSLBleReader convertDataToHexString:packet.payload] substringToIndex:4] isEqualToString:@"8100"]) {
                    [rfidPacketBuffer appendData:[packet.payload subdataWithRange:NSMakeRange(2, packet.payloadLength - 2)]];
                    packet.payload=[NSData dataWithBytes:[rfidPacketBuffer bytes] length:[rfidPacketBuffer length]];
                }
                else {
                    //other event code
                    //drop packet and wait for next data
                    continue;
                }
            }
            //buffer in hex string format
            rfidPacketBufferInHexString=[CSLBleReader convertDataToHexString:rfidPacketBuffer];
            
            //get event code
            eventCode = [rfidPacketBufferInHexString substringToIndex:4];
        
            NSLog(@"[decodePacketsInBufferAsync] Payload to be decoded: %@", rfidPacketBufferInHexString);
        
            //**************************************
            //selector of different command responses
            if ([eventCode isEqualToString:@"8100"])    //RFID module responses
            {
                if ([rfidPacketBufferInHexString containsString:@"81004003BFFCBFFCBFFC"]) {
                    NSLog(@"[decodePacketsInBufferAsync] Abort command received.  All opeartions ended");
                    [cmdRespQueue enqObject:packet];
                    [rfidPacketBuffer setLength:0];
                    connectStatus=CONNECTED;
                    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                    continue;
                }
                
                //command begin response
                if ([rfidPacketBufferInHexString length] >= 12)
                {
                    if (
                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0080"]) ||
                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0000"])
                        ) {
                        NSLog(@"[decodePacketsInBufferAsync] Command-begin response recieved: %@", rfidPacketBufferInHexString);
                        self.lastMacErrorCode=0x0000;
                        //return packet directly to the API for decoding
                        [cmdRespQueue enqObject:packet];
                        [rfidPacketBuffer setLength:0];
                        continue;
                    }
                }
                
                //command end response
                if ([rfidPacketBufferInHexString length] >= 12)
                {
                    if (
                        ([[[CSLBleReader convertDataToHexString:rfidPacketBuffer] substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0180"]) ||
                        ([[[CSLBleReader convertDataToHexString:rfidPacketBuffer] substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0100"])
                        ) {
                        NSLog(@"[decodePacketsInBufferAsync] Command-end response recieved: %@", rfidPacketBufferInHexString);
                        //return packet directly to the API for decoding
                        self.lastMacErrorCode=(((Byte *)[rfidPacketBuffer bytes])[15] << 8) + (((Byte *)[rfidPacketBuffer bytes])[14]);
                        [cmdRespQueue enqObject:packet];
                        [rfidPacketBuffer setLength:0];
                        connectStatus=CONNECTED;
                        continue;
                    }
                }
                
                //tag search response with no tag found
                if ([rfidPacketBufferInHexString length] >= 12)
                {
                    if ([[[CSLBleReader convertDataToHexString:rfidPacketBuffer] substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0E00"]) {
                        
                        CSLBleTag* tag=[[CSLBleTag alloc] init];
                        tag.EPC=@"";
                        tag.rssi=0;
                        tag.timestamp=[NSDate date];
                        
                        NSLog(@"[decodePacketsInBufferAsync] Tag search response with no tag found recieved: %@", rfidPacketBufferInHexString);
                        //return packet directly to the API for decoding
                        [self.readerDelegate didReceiveTagResponsePacket:self tagReceived:tag]; //this will call the method for handling the tag response.
                        [rfidPacketBuffer setLength:0];
                        continue;
                    }
                }
                
                //antenna cycle
                if ([rfidPacketBufferInHexString length] >= 12)
                {
                    if (
                        ([[[CSLBleReader convertDataToHexString:rfidPacketBuffer] substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0007"]) ||
                        ([[[CSLBleReader convertDataToHexString:rfidPacketBuffer] substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0007"])
                        ) {
                        
                        //discard data for now
                        NSLog(@"[decodePacketsInBufferAsync] Antenna cycle recieved: %@", rfidPacketBufferInHexString);
                        [rfidPacketBuffer setLength:0];
                        continue;
                    }
                }
                
                
                if ([rfidPacketBufferInHexString length] >= 8)
                {
                    if ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4,4)] isEqualToString:@"7000"] ||
                        [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4,4)] isEqualToString:@"7001"] ||
                        [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4,4)] isEqualToString:@"0000"] ||
                        [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4,4)] isEqualToString:@"0001"]
                        ) {
                        //response when reading/writing registers.  Return packet directly to the API for decoding
                        [cmdRespQueue enqObject:packet];
                        [rfidPacketBuffer setLength:0];
                        continue;
                    }
                }
                
                NSLog(@"[decodePacketsInBufferAsync] Current filtered buffer size: %d", (int)[filteredBuffer count]);
                
                //inventory response and tag-access packet returned during read/write
                //packet much be longer than 44 hex characteres (0x8100 + 20 bytes of header)
                if ([rfidPacketBufferInHexString length] >= 44) {
                    //inventory response packet (full packet mode)during tag access (not inventory mode)
                    if (
                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"03"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0580"] && [self isTagAccessMode]) ||
                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"03"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0500"] && [self isTagAccessMode])
                        
                        ) {
                        //start decode message
                        //first need to check if we have received the complete message if this is a tag-access response.  Otherwise, will return and wait for the partial packet to return on the next round.
                        int tagAccessPktLen=0;
                        int payloadDataLen=0;
                        bool tagInventoryPacketOnly=false; //flag being set when there is inventory response only for tag search operations.
                        
                        //length of data field (in bytes) for the inventory response = ((pkt_len – 3) * 4) – ((flags >> 6) & 3)
                        datalen=(((((Byte *)[rfidPacketBuffer bytes])[6] + (((((Byte *)[rfidPacketBuffer bytes])[7] << 8) & 0xFF00)))-3) * 4) - ((((Byte *)[rfidPacketBuffer bytes])[3] >> 6) & 3);
                        
                        //in the case where the abort reponse command is being appended to the end of the buffer, remove the abort reponse and decode the remaining tag reponses
                        if ([rfidPacketBufferInHexString containsString:@"4003BFFCBFFCBFFC"]) {
                            NSLog(@"[decodePacketsInBufferAsync] Abort command received during tag access.  All operations ended");
                            [cmdRespQueue enqObject:packet];
                            [rfidPacketBuffer setLength:0];
                            connectStatus=CONNECTED;
                            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                            continue;
                        }
                        //in the case where BLE packet returned only contain full inventory response and reader is in inventory mode (not sync read/write mode), decode packet and then return
                        else if (([rfidPacketBuffer length] == (22 + datalen)) && connectStatus == TAG_OPERATIONS) {
                            tagInventoryPacketOnly=true;
                        }
                        else if ([rfidPacketBuffer length] > (22 + datalen + 20)) {
                            tagAccessPktLen=((Byte *)[rfidPacketBuffer bytes])[22+datalen+4] + ((((Byte *)[rfidPacketBuffer bytes])[22+datalen+5] << 8) & 0xFF00);
                            payloadDataLen= ((tagAccessPktLen - 3) * 4) - ((((Byte*)[rfidPacketBuffer bytes])[22+datalen+1] >> 6) & 3);
                            if ([rfidPacketBuffer length] < (22+datalen+20+payloadDataLen))
                                continue;
                        }
                        else
                            continue;
                        
                        int ptr=22;     //starting point of the tag data
                        CSLBleTag* tag=[[CSLBleTag alloc] init];
                        
                        tag.PC =((((Byte *)[rfidPacketBuffer bytes])[ptr] << 8) & 0xFF00)+ ((Byte *)[rfidPacketBuffer bytes])[ptr+1];
                        //for the case where we reaches to the end of the BLE packet but not the RFID response packet, where there will be partial packet to be returned from the next packet.  The partial tag data will be combined with the next packet being returned.
                        if ((ptr + datalen) > [rfidPacketBuffer length]) {
                            //stop decoding and wait for the partial tag data to be appended in the next packet arrival
                            NSLog(@"[decodePacketsInBufferAsync] partial inventory response packet being returned.  Wait for next rfid response packet for complete tag data.");
                            continue;
                        }
                        tag.EPC=[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr*2)+4, ((tag.PC >> 11) * 2) * 2)];
                        tag.rssi = ((Byte *)[rfidPacketBuffer bytes])[15];
                        tag.portNumber=((Byte *)[rfidPacketBuffer bytes])[20];
                        tag.CRCError=((Byte *)[rfidPacketBuffer bytes])[3] & 0x01;
                        
                        //shifting pointer beginning of tag access packet
                        ptr+= datalen;
                        
                        NSLog(@"[decodePacketsInBufferAsync] Tag data found: PC=%04X EPC=%@ rssi=%d", tag.PC, tag.EPC, tag.rssi);
                        tag.timestamp=[NSDate date];
                        
                        if (tagInventoryPacketOnly) {
                            NSLog(@"[decodePacketsInBufferAsync] Finished decode inventory response (full) packet.");
                            //trigger delegate for returning the tag response
                            [self.readerDelegate didReceiveTagResponsePacket:self tagReceived:tag]; //this will call the method for handling the tag access response.
                            [rfidPacketBuffer setLength:0];
                            continue;
                        }
                        
                        //for the cases where we reaches the end of the RFID reponse packet but there are still data within the bluetooth reader packet.
                        // start of teh tag-access packet
                        if ([rfidPacketBufferInHexString length] >= ptr + 20)
                        {
                            NSLog(@"[decodePacketsInBufferAsync] Decoding the tag-access data appended to the end of the inventory response packet: %@", [rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] );
                            //check if we are getting tag response packet
                            if ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2), 2)] isEqualToString:@"01"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)+4, 4)] isEqualToString:@"0600"]) {
                                
                                NSLog(@"[decodePacketsInBufferAsync] Tag-access packet received.");
                                //tag.DATA1Length=((Byte *)[rfidPacketBuffer bytes])[18];
                                //tag.DATA2Length=((Byte *)[rfidPacketBuffer bytes])[19];
                                
                                //start decode taq-response message
                                //length of data field (in bytes) = ((pkt_len – 3) * 4) – ((flags >> 6) & 3)
                                datalen=(((((Byte *)[rfidPacketBuffer bytes])[ptr+4] + (((((Byte *)[rfidPacketBuffer bytes])[ptr+5] << 8) & 0xFF00)))-3) * 4) - ((((Byte *)[rfidPacketBuffer bytes])[ptr+1] >> 6) & 3);
                                tag.DATALength=datalen / 2;
                                
                                /*
                                if (tag.DATA1Length > 0 && (((tag.DATA1Length + tag.DATA2Length) * 2) == datalen))
                                    tag.DATA1 = [rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2) + 40, tag.DATA1Length * 4)];  //20 byte tag response header = 40 hex digits
                                else
                                    tag.DATA1=@"";
                                if (tag.DATA2Length > 0 && (((tag.DATA1Length + tag.DATA2Length) * 2) == datalen))
                                    tag.DATA2 = [rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2) + 40 + (tag.DATA1Length * 4), tag.DATA2Length * 4)]; //20 byte tag response header = 40 hex digits
                                else
                                    tag.DATA2=@"";
                                NSLog(@"[decodePacketsInBufferAsync] Tag-access packet.  DATA1=%@ DATA2=%@", tag.DATA1, tag.DATA2);
                                 */
                                if (tag.DATALength > 0) {
                                    tag.DATA = [rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2) + 40, tag.DATALength * 4)];  //20 byte tag response header = 40 hex digits
                                }
                                NSLog(@"[decodePacketsInBufferAsync] Tag-access packet.  DATA1+DATA2=%@", tag.DATA);
                                tag.timestamp=[NSDate date];
                                
                                //set flags
                                tag.CRCError = tag.CRCError || ((((Byte *)[rfidPacketBuffer bytes])[ptr+1] & 0x08) >> 3);
                                
                                if ((((Byte *)[rfidPacketBuffer bytes])[ptr+1] & 0x02) >> 1) {
                                    //get error code
                                    tag.BackScatterError = ((Byte *)[rfidPacketBuffer bytes])[ptr+13];
                                }
                                else
                                    tag.BackScatterError=0xFF;
                                
                                tag.ACKTimeout=(((Byte *)[rfidPacketBuffer bytes])[ptr+1] & 0x04) >> 2;
                                
                                //if access error occurred and nothg of the following: tag backscatter error, ack time out, crc error indicated a fault,
                                //read error code form the data field
                                if ((((Byte *)[rfidPacketBuffer bytes])[ptr+1] & 0x01) && tag.BackScatterError == 0xFF && !tag.CRCError && !tag.ACKTimeout) {
                                    tag.AccessError=((Byte *)[rfidPacketBuffer bytes])[ptr+20];
                                }
                                else
                                    tag.AccessError=0xFF;
                                
                                tag.portNumber=((Byte *)[rfidPacketBuffer bytes])[ptr+14];

                                //save the access command read/write/kill/lock/EAS
                                tag.AccessCommand=((Byte *)[rfidPacketBuffer bytes])[ptr+12];

                                //trigger delegate for returning the tag response
                                [self.readerDelegate didReceiveTagAccessData:self tagReceived:tag]; //this will call the method for handling the tag access response.
                                
                                //shifting pointer to the beginning of the next RFID response packet (if any)
                                ptr+= (20+((tagAccessPktLen - 3) * 4));

                                //check and see if we have received a complete RFID response packet (command-end)
                                if ([rfidPacketBuffer length] >= (ptr+4)) {
                                    if (
                                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, 2)] isEqualToString:@"02"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr+2) * 2, 4)] isEqualToString:@"0180"]) ||
                                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, 2)] isEqualToString:@"01"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr+2) * 2, 4)] isEqualToString:@"0100"])
                                        ) {
                                        
                                        self.lastMacErrorCode=(((Byte *)[rfidPacketBuffer bytes])[ptr+13] << 8) + (((Byte *)[rfidPacketBuffer bytes])[ptr+12]);
                                        //partial command-end packet received
                                        //remove decoded data from rfid buffer and leave the partial packet on the buffer with 8100 appended to the beginning
                                        
                                        tempMutableData=[NSMutableData data];
                                        [tempMutableData appendData:[NSMutableData dataWithBytes:ecode length:sizeof(ecode)]];
                                        [tempMutableData appendData:[[rfidPacketBuffer subdataWithRange:NSMakeRange(ptr, [rfidPacketBuffer length]-ptr)] mutableCopy]];
                                        
                                        if ([rfidPacketBuffer length] >= (ptr+16)) {
                                            //return packet to the API for decoding
                                            packet.payload=[NSData dataWithBytes:[tempMutableData bytes] length:[tempMutableData length]];
                                            [cmdRespQueue enqObject:packet];
                                            [rfidPacketBuffer setLength:0];
                                            continue;
                                        }
                                        else {
                                            rfidPacketBuffer=tempMutableData;
                                            connectStatus=CONNECTED;
                                            continue;
                                        }

                                    }
                                }
                            }
                        }
                        
                        //return when pointer reaches the end of the RFID response packet.
                        NSLog(@"[decodePacketsInBufferAsync] Decode tag response packet completed with error.");
                        [rfidPacketBuffer setLength:0];
                        continue;
      
                    }
                    //inventory response packet (full packet mode) during multibank inventory, where data1_count and/or data2_count are non-zero
                    else if ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"03"]) {
                        
                        //start decode message
                        UInt32 pkt_len=((Byte *)[rfidPacketBuffer bytes])[6] + (((((Byte *)[rfidPacketBuffer bytes])[7] << 8) & 0xFF00));
                        datalen=((pkt_len - 3) * 4) - ((((Byte *)[rfidPacketBuffer bytes])[7] >> 6) & 3);
                        
                        
                        //iterate through all the tag data
                        int ptr=22;     //starting point of the tag data
                        while(TRUE)
                        {
                            CSLBleTag* tag=[[CSLBleTag alloc] init];
                            
                            tag.PC =((((Byte *)[rfidPacketBuffer bytes])[ptr] << 8) & 0xFF00)+ ((Byte *)[rfidPacketBuffer bytes])[ptr+1];
                            tag.DATA1Length=((Byte *)[rfidPacketBuffer bytes])[18];
                            tag.DATA2Length=((Byte *)[rfidPacketBuffer bytes])[19];
                            
                            //for the case where we reaches to the end of the BLE packet but not the RFID response packet, where there will be partial packet to be returned from the next packet.  The partial tag data will be combined with the next packet being returned.
                            if ([rfidPacketBuffer length] < (22+datalen)) {
                                //stop decoding and wait for the partial tag data to be appended in the next packet arrival
                                NSLog(@"[decodePacketsInBufferAsync] partial tag data being returned.  Wait for next rfid response packet for complete tag data.");
                                break;
                            }
                            
                            tag.EPC=[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr*2)+4, ((tag.PC >> 11) * 2) * 2)];
                            if (tag.DATA1Length) {
                                tag.DATA1 = [rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr*2)+4+(((tag.PC >> 11) * 2) * 2), tag.DATA1Length * 4)];
                            }
                            if (tag.DATA2Length) {
                                tag.DATA2 = [rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr*2)+4+(((tag.PC >> 11) * 2) * 2)+(tag.DATA1Length * 4), tag.DATA2Length * 4)];
                            }
                            tag.rssi = ((Byte *)[rfidPacketBuffer bytes])[15];
                            tag.portNumber = ((Byte *)[rfidPacketBuffer bytes])[20];
                            ptr+= datalen;
                            [self.readerDelegate didReceiveTagResponsePacket:self tagReceived:tag]; //this will call the method for handling the tag response.
                            
                            NSLog(@"[decodePacketsInBufferAsync] Tag data found: PC=%04X EPC=%@ DATA1=%@ DATA2=%@ rssi=%d", tag.PC, tag.EPC, tag.DATA1, tag.DATA2, tag.rssi);
                            tag.timestamp=[NSDate date];
                            rangingTagCount++;
                            
                            @synchronized(filteredBuffer) {
                                //insert the tag data to the sorted filteredBuffer if not duplicated
                                
                                //check and see if epc exists on the array using binary search
                                NSRange searchRange = NSMakeRange(0, [filteredBuffer count]);
                                NSUInteger findIndex = [filteredBuffer indexOfObject:tag
                                                                       inSortedRange:searchRange
                                                                             options:NSBinarySearchingInsertionIndex
                                                                     usingComparator:^(id obj1, id obj2)
                                                        {
                                                            NSString* str1=((CSLBleTag*)obj1).EPC;
                                                            NSString* str2=((CSLBleTag*)obj2).EPC;
                                                            return [str1 compare:str2 options:NSCaseInsensitiveSearch];
                                                        }];
                                
                                if ( findIndex >= [filteredBuffer count] )  //tag to be the largest.  Append to the end.
                                {
                                    [filteredBuffer insertObject:tag atIndex:findIndex];
                                    uniqueTagCount++;
                                    
                                }
                                else if ( [((CSLBleTag*)filteredBuffer[findIndex]).EPC caseInsensitiveCompare:tag.EPC] != NSOrderedSame)
                                {
                                    //new tag found.  insert into buffer in sorted order
                                    [filteredBuffer insertObject:tag atIndex:findIndex];
                                    uniqueTagCount++;
                                }
                                else    //tag is duplicated, but will replace the existing tag information with the new one for updating the RRSI value.
                                {
                                    [filteredBuffer replaceObjectAtIndex:findIndex withObject:tag];
                                }
                            }
                            
                            //for the cases where we reaches the end of the RFID reponse packet but there are still data within the bluetooth reader packet.
                            // (1) user is aborting the operation so that the abort command reponse
                            if ((ptr >= (datalen + 22)) && ([rfidPacketBuffer length] >= (datalen + 22 /* 8 bytes of bluetooth packet header + 2 byte for the payload reply */ + 8 /* 8 bytes for the abort command response or other RFID command reponse*/)))
                            {
                                NSLog(@"[decodePacketsInBufferAsync] Decoding the data appended to the end of the 8100 packet: %@", [rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] );
                                if ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] containsString:@"4003BFFCBFFCBFFC"]) {
                                    NSLog(@"[decodePacketsInBufferAsync] Abort command received.  All operations ended");
                                    [cmdRespQueue enqObject:packet];
                                    [rfidPacketBuffer setLength:0];
                                    connectStatus=CONNECTED;
                                    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                                    break;
                                }
                                //for the case where command-end appended to the packet as the radio stopped unexpectedly
                                else if ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] containsString:@"0101010002000000"]) {
                                    NSLog(@"[decodePacketsInBufferAsync] Unexpected command-end received.  All operations ended");
                                    //get mac error code
                                    int startOfCmdEnd=(int)[[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] rangeOfString:@"0101010002000000"].location / 2;
                                    self.lastMacErrorCode=(((Byte *)[rfidPacketBuffer bytes])[ptr+startOfCmdEnd+13] << 8) + (((Byte *)[rfidPacketBuffer bytes])[ptr+startOfCmdEnd+12]);
                                    [cmdRespQueue enqObject:packet];
                                    [rfidPacketBuffer setLength:0];
                                    connectStatus=CONNECTED;
                                    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                                    break;
                                }
                                //check if we are getting the beginning of another 8100 packet but with no 8100 event code.  If so, add the event code back with the header response
                                else if (![[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] containsString:@"8100"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2), 2)] isEqualToString:@"03"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)+4, 4)] isEqualToString:@"0580"]) {
                                    
                                    NSLog(@"[decodePacketsInBufferAsync] Partial acket has not 8100 event code.  Append event code and leave it on the buffer");
                                    //remove decoded data from rfid buffer and leave the partial packet on the buffer with 8100 appended to the beginning
                                    rfidPacketBuffer=[[rfidPacketBuffer subdataWithRange:NSMakeRange(ptr, [rfidPacketBuffer length]-ptr)] mutableCopy];
                                    tempMutableData=[NSMutableData data];
                                    [tempMutableData appendData:[NSMutableData dataWithBytes:ecode length:sizeof(ecode)]];
                                    [tempMutableData appendData:rfidPacketBuffer];
                                    rfidPacketBuffer=tempMutableData;
                                    break;
                                    
                                }
                                //check if we are getting the beginning of another 8100 packet.  If so, extract header of the response
                                else if (
                                         ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)  + 4, 2)] isEqualToString:@"03"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)+8, 4)] isEqualToString:@"0580"]) ||
                                         ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)  + 4, 2)] isEqualToString:@"03"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)+8, 4)] isEqualToString:@"0500"])
                                         ) {
                                    NSLog(@"[decodePacketsInBufferAsync] Remove decoded data from rfid buffer and leave the partial packet on the buffer");
                                    //remove decoded data from rfid buffer and leave the partial packet on the buffer
                                    rfidPacketBuffer=[[rfidPacketBuffer subdataWithRange:NSMakeRange(ptr, [rfidPacketBuffer length]-ptr)] mutableCopy];
                                    break;
                                }
                            }
                            //partial packet appended at the end but the partial packet is shorter than the required header for decode, wait for more incoming data for decoding.
                            else if ((ptr >= (datalen + 22)) && ([rfidPacketBuffer length] > (datalen + 22))) {
                                NSLog(@"[decodePacketsInBufferAsync] Remove decoded data from rfid buffer and leave the partial packet (shorter than 8 bytes) on the buffer");
                                //remove decoded data from rfid buffer and leave the partial packet on the buffer
                                rfidPacketBuffer=[[rfidPacketBuffer subdataWithRange:NSMakeRange(ptr, [rfidPacketBuffer length]-ptr)] mutableCopy];
                                break;
                            }
                            
                            //return when pointer reaches the end of the RFID response packet.
                            if (ptr >= (datalen + 22)) {
                                NSLog(@"[decodePacketsInBufferAsync] Finished decode all tags in packet.");
                                [rfidPacketBuffer setLength:0];
                                break;
                            }
                        }
                        continue;
                    }
                }
                //check if packet is compact response packet (inventory)
                if ([rfidPacketBufferInHexString length] >= 12) {
                    if (
                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"04"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0580"]) ||
                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"04"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0500"])
                        )
                    {
                        //start decode message
                        datalen=((Byte *)[rfidPacketBuffer bytes])[6] + (((((Byte *)[rfidPacketBuffer bytes])[7] << 8) & 0xFF00)) ;
                        
                        //iterate through all the tag data
                        int ptr=10;     //starting point of the tag data
                        while(TRUE)
                        {
                            CSLBleTag* tag=[[CSLBleTag alloc] init];
                            
                            tag.PC =((((Byte *)[rfidPacketBuffer bytes])[ptr] << 8) & 0xFF00)+ ((Byte *)[rfidPacketBuffer bytes])[ptr+1];
                            
                            //for the case where we reaches to the end of the BLE packet but not the RFID response packet, where there will be partial packet to be returned from the next packet.  The partial tag data will be combined with the next packet being returned.
                            //8100 (two bytes) + 8 bytes RFID packet header + payload length being calcuated ont he header
                            if ((10 + datalen) > [rfidPacketBuffer length]) {
                                //stop decoding and wait for the partial tag data to be appended in the next packet arrival
                                NSLog(@"[decodePacketsInBufferAsync] partial tag data being returned.  Wait for next rfid response packet for complete tag data.");
                                break;
                            }
                            
                            tag.EPC=[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr*2)+4, ((tag.PC >> 11) * 2) * 2)];
                            tag.rssi=(Byte)((Byte *)[rfidPacketBuffer bytes])[(ptr + 2) + ((tag.PC >> 11) * 2)];
                            tag.portNumber=(Byte)((Byte *)[rfidPacketBuffer bytes])[8];
                            ptr+= (2 + ((tag.PC >> 11) * 2) + 1);
                            [self.readerDelegate didReceiveTagResponsePacket:self tagReceived:tag]; //this will call the method for handling the tag response.
                            
                            NSLog(@"[decodePacketsInBufferAsync] Tag data found: PC=%04X EPC=%@ rssi=%d", tag.PC, tag.EPC, tag.rssi);
                            rangingTagCount++;
                            
                            @synchronized(filteredBuffer) {
                                //insert the tag data to the sorted filteredBuffer if not duplicated
                                
                                //check and see if epc exists on the array using binary search
                                NSRange searchRange = NSMakeRange(0, [filteredBuffer count]);
                                NSUInteger findIndex = [filteredBuffer indexOfObject:tag
                                                                    inSortedRange:searchRange
                                                                          options:NSBinarySearchingInsertionIndex
                                                                  usingComparator:^(id obj1, id obj2)
                                                                    {
                                                                        NSString* str1=((CSLBleTag*)obj1).EPC;
                                                                        NSString* str2=((CSLBleTag*)obj2).EPC;
                                                                        return [str1 compare:str2 options:NSCaseInsensitiveSearch];
                                                                    }];
                                
                                if ( findIndex >= [filteredBuffer count] )  //tag to be the largest.  Append to the end.
                                {
                                    [filteredBuffer insertObject:tag atIndex:findIndex];
                                    uniqueTagCount++;
                                    
                                }
                                else if ( [((CSLBleTag*)filteredBuffer[findIndex]).EPC caseInsensitiveCompare:tag.EPC] != NSOrderedSame)
                                {
                                    //new tag found.  insert into buffer in sorted order
                                    [filteredBuffer insertObject:tag atIndex:findIndex];
                                    uniqueTagCount++;
                                }
                                else    //tag is duplicated, but will replace the existing tag information with the new one for updating the RRSI value.
                                {
                                    [filteredBuffer replaceObjectAtIndex:findIndex withObject:tag];
                                }
                            }
                            
                            //for the cases where we reaches the end of the RFID reponse packet but there are still data within the bluetooth reader packet.
                            // (1) user is aborting the operation so that the abort command reponse
                            if ((ptr >= (datalen + 10)) && ([rfidPacketBuffer length] >= (datalen + 10 /* 8 bytes of bluetooth packet header + 2 byte for the payload reply */ + 8 /* 8 bytes for the abort command response or other RFID command reponse*/)))
                            {
                                NSLog(@"[decodePacketsInBufferAsync] Decoding the data appended to the end of the 8100 packet: %@", [rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] );
                                if ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] containsString:@"4003BFFCBFFCBFFC"]) {
                                    NSLog(@"[decodePacketsInBufferAsync] Abort command received.  All operations ended");
                                    [cmdRespQueue enqObject:packet];
                                    [rfidPacketBuffer setLength:0];
                                    connectStatus=CONNECTED;
                                    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                                    break;
                                }
                                //for the case where command-end appended to the packet as the radio stopped unexpectedly
                                else if ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] containsString:@"0101010002000000"]) {
                                    NSLog(@"[decodePacketsInBufferAsync] Unexpected command-end received.  All operations ended");
                                    //get mac error code
                                    int startOfCmdEnd=(int)[[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] rangeOfString:@"0101010002000000"].location / 2;
                                    self.lastMacErrorCode=(((Byte *)[rfidPacketBuffer bytes])[ptr+startOfCmdEnd+13] << 8) + (((Byte *)[rfidPacketBuffer bytes])[ptr+startOfCmdEnd+12]);
                                    [cmdRespQueue enqObject:packet];
                                    [rfidPacketBuffer setLength:0];
                                    connectStatus=CONNECTED;
                                    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                                    break;
                                }
                                //check if we are getting the beginning of another 8100 packet but with no 8100 event code.  If so, add the event code back with the header response
                                else if (![[rfidPacketBufferInHexString substringWithRange:NSMakeRange(ptr * 2, ([rfidPacketBuffer length] - ptr) * 2)] containsString:@"8100"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2), 2)] isEqualToString:@"04"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)+4, 4)] isEqualToString:@"0580"]) {

                                    NSLog(@"[decodePacketsInBufferAsync] Partial acket has not 8100 event code.  Append event code and leave it on the buffer");
                                    //remove decoded data from rfid buffer and leave the partial packet on the buffer with 8100 appended to the beginning
                                    rfidPacketBuffer=[[rfidPacketBuffer subdataWithRange:NSMakeRange(ptr, [rfidPacketBuffer length]-ptr)] mutableCopy];
                                    tempMutableData=[NSMutableData data];
                                    [tempMutableData appendData:[NSMutableData dataWithBytes:ecode length:sizeof(ecode)]];
                                    [tempMutableData appendData:rfidPacketBuffer];
                                    rfidPacketBuffer=tempMutableData;
                                    break;
                                    
                                }
                                //check if we are getting the beginning of another 8100 packet.  If so, extract header of the response
                                else if (
                                         ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)  + 4, 2)] isEqualToString:@"04"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)+8, 4)] isEqualToString:@"0580"]) ||
                                        ([[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)  + 4, 2)] isEqualToString:@"04"] && [[rfidPacketBufferInHexString substringWithRange:NSMakeRange((ptr * 2)+8, 4)] isEqualToString:@"0500"])
                                        ) {
                                    NSLog(@"[decodePacketsInBufferAsync] Remove decoded data from rfid buffer and leave the partial packet on the buffer");
                                    //remove decoded data from rfid buffer and leave the partial packet on the buffer
                                    rfidPacketBuffer=[[rfidPacketBuffer subdataWithRange:NSMakeRange(ptr, [rfidPacketBuffer length]-ptr)] mutableCopy];
                                    break;
                                }

                            }
                            
                            //return when pointer reaches the end of the RFID response packet.
                            if (ptr >= (datalen + 10)) {
                                NSLog(@"[decodePacketsInBufferAsync] Finished decode all tags in packet.");
                                [rfidPacketBuffer setLength:0];
                                break;
                            }
                        }
                    }
                    else {
                        //unknown 8100 rfid packet.  Dropping the data
                        NSLog(@"[decodePacketsInBufferAsync] Unknown 8100 RFID packet.  Dropping the data");
                        [rfidPacketBuffer setLength:0];
                    }
                }
            }
            else if ([eventCode isEqualToString:@"9000"]) {   //Power on barcode
                NSLog(@"[decodePacketsInBufferAsync] Power on barcode");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"9001"]) {   //Power on barcode
                NSLog(@"[decodePacketsInBufferAsync] Power off barcode");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"8000"]) {   //Power on RFID module
                NSLog(@"[decodePacketsInBufferAsync] Power on Rfid Module");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"8001"]) {   //Power off RFID module
                NSLog(@"[decodePacketsInBufferAsync] Power off Rfid Module");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"C000"]) {   //Get BT firmware version
                NSLog(@"[decodePacketsInBufferAsync] Get BT firmware version");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"C004"]) {   //Get connected device name
                NSLog(@"[decodePacketsInBufferAsync] Get connected device name");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"B000"]) {   //Get SilconLab IC firmware version.
                NSLog(@"[decodePacketsInBufferAsync] Get SilconLab IC firmware version.");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"B004"]) {   //Get 16 byte serial number.
                NSLog(@"[decodePacketsInBufferAsync] Get 16 byte serial number.");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"8002"]) {   //RFID firmware command response
                NSLog(@"[decodePacketsInBufferAsync] RFID firmware command response.");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"A103"]) {
                //Trigger key is released.  Trigger callback delegate method
                NSLog(@"[decodePacketsInBufferAsync] Trigger key: OFF");
                [rfidPacketBuffer setLength:0];
                [self.readerDelegate didTriggerKeyChangedState:self keyState:false]; //this will call the method for handling the tag response.
            }
            else if ([eventCode isEqualToString:@"A102"]) {
                //Trigger key is pressed.  Trigger callback delegate method
                NSLog(@"[decodePacketsInBufferAsync] Trigger key: ON");
                [rfidPacketBuffer setLength:0];
                [self.readerDelegate didTriggerKeyChangedState:self keyState:true]; //this will call the method for handling the tag response.
            }
            else if ([eventCode isEqualToString:@"A002"]) {
                NSLog(@"[decodePacketsInBufferAsync] Battery auto reporting: ON");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"A000"]) {
                NSLog(@"[decodePacketsInBufferAsync] Battery auto reporting Return: 0x%@", [rfidPacketBufferInHexString substringWithRange:NSMakeRange(4,4)]);
                if (connectStatus==TAG_OPERATIONS)
                    [batteryInfo setBatteryMode:INVENTORY];
                else
                    [batteryInfo setBatteryMode:IDLE];
                [self.readerDelegate didReceiveBatteryLevelIndicator:self batteryPercentage:[batteryInfo getBatteryPercentageByVoltage:(double)((((Byte *)[rfidPacketBuffer bytes])[2] * 256) + ((Byte *)[rfidPacketBuffer bytes])[3]) / 1000.00f]];
                [rfidPacketBuffer setLength:0];
            }
            else if ([eventCode isEqualToString:@"9003"]) {
                NSLog(@"[decodePacketsInBufferAsync] Barcode command sent.");
                [rfidPacketBuffer setLength:0];
                [cmdRespQueue enqObject:packet];
            }
            else if ([eventCode isEqualToString:@"9100"]) {
                NSLog(@"[decodePacketsInBufferAsync] Barcode data received.");
                NSData* barcodeRsp=[rfidPacketBuffer subdataWithRange:NSMakeRange(2, [rfidPacketBuffer length]-2)];
                if ([barcodeRsp length] == 1) {
                    NSLog(@"[decodePacketsInBufferAsync] Barcode command sent.");
                    [cmdRespQueue enqObject:packet];
                }
                else {
                    barcode=[[CSLReaderBarcode alloc] initWithSerialData:[rfidPacketBuffer subdataWithRange:NSMakeRange(2, [rfidPacketBuffer length]-2)]];
                    if (barcode.aimId != nil && barcode.codeId != nil && barcode.barcodeValue!=nil) {
                        NSLog(@"[decodePacketsInBufferAsync] Barcode received: Code ID=%@ AIM ID=%@ Barcode=%@", barcode.codeId, barcode.aimId, barcode.barcodeValue);
                        
                        @synchronized(filteredBuffer) {
                            //check and see if epc exists on the array using binary search
                            NSRange searchRange = NSMakeRange(0, [filteredBuffer count]);
                            NSUInteger findIndex = [filteredBuffer indexOfObject:barcode
                                                                   inSortedRange:searchRange
                                                                         options:NSBinarySearchingInsertionIndex
                                                                 usingComparator:^(id obj1, id obj2)
                                                    {
                                                        NSString* str1=((CSLReaderBarcode*)obj1).barcodeValue;
                                                        NSString* str2=((CSLReaderBarcode*)obj2).barcodeValue;
                                                        return [str1 compare:str2 options:NSCaseInsensitiveSearch];
                                                    }];
                            
                            if ( findIndex >= [filteredBuffer count] )  //tag to be the largest.  Append to the end.
                                [filteredBuffer insertObject:barcode atIndex:findIndex];
                            else if ( [((CSLReaderBarcode*)filteredBuffer[findIndex]).barcodeValue caseInsensitiveCompare:barcode.barcodeValue] != NSOrderedSame)
                                //new tag found.  insert into buffer in sorted order
                                [filteredBuffer insertObject:barcode atIndex:findIndex];
                            else    //tag is duplicated, but will replace the existing tag information with the new one for updating the RRSI value.
                                [filteredBuffer replaceObjectAtIndex:findIndex withObject:barcode];
                        }
                        [self.readerDelegate didReceiveBarcodeData:self scannedBarcode:barcode];
                    }
                }
                [rfidPacketBuffer setLength:0];
            }
            else if ([eventCode isEqualToString:@"9101"]) {
                NSLog(@"[decodePacketsInBufferAsync] Barcode data good read.");
                [rfidPacketBuffer setLength:0];
            }
            else {
                //for all other event code that is not covered.
                [rfidPacketBuffer setLength:0];
            }
        }
    }
    NSLog(@"[decodePacketsInBufferAsync] Ended!");
}

+ (NSString*) convertDataToHexString:(NSData*) data {
    
    @try {
        int dlen=(int)[data length];
        NSMutableString* hexStr = [NSMutableString stringWithCapacity:dlen];
        
        
        for(int i = 0; i < [data length]; i++)
            [hexStr appendFormat:@"%02X", ((Byte*)[data bytes])[i]];
        
        return [NSString stringWithString: hexStr];
    }
    @catch (NSException* exception)
    {
        NSLog(@"Exception on convertDataToHexString: %@", exception.description);
        return nil;
    }
}

+ (NSData *)convertHexStringToData:(NSString *)hexString {
    
    const char *hexChar = [hexString UTF8String];
    
    Byte *bt = malloc(sizeof(Byte)*(hexString.length/2));
    
    char tmpChar[3] = {'\0','\0','\0'};
    
    int btIndex = 0;
    
    for (int i=0; i<hexString.length; i += 2) {
        
        tmpChar[0] = hexChar[i];
        
        tmpChar[1] = hexChar[i+1];
        
        bt[btIndex] = strtoul(tmpChar, NULL, 16);
        
        btIndex ++;
        
    }
    
    NSData *data = [NSData dataWithBytes:bt length:btIndex];
    
    free(bt);
    
    return data;
    
}



@end
