//
//  CSLBleReader+AccessControl.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 23/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLBleReader+AccessControl.h"

@implementation CSLBleReader (AccessControl)

- (BOOL)setParametersForTagAccess {
    
    if(![self setAntennaCycle:1])
        return false;
    if (![self setQueryConfigurations:A querySession:S0 querySelect:SL])
        return false;
    if (![self selectAlgorithmParameter:FIXEDQ])
        return false;
    if (![self setInventoryAlgorithmParameters0:0 maximumQ:0 minimumQ:0 ThresholdMultiplier:0])
        return false;
    if (![self setInventoryAlgorithmParameters2:0 RunTillZero:0])
        return false;
    
    return true;
}

- (BOOL) TAGMSK_DESC_CFG:(BOOL)isEnable selectTarget:(Byte)sel_target selectAction:(Byte)sel_action {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGMSK_DESC_CFG - Specify the parameters for a Select operation");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGMSK_DESC_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x01, 0x08, (isEnable & 0x01) + ((sel_target << 1) & 0x0E) + ((sel_action << 4) & 0x70), 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGMSK_DESC_CFG length:sizeof(TAGMSK_DESC_CFG)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGMSK_DESC_CFG, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGMSK_DESC_CFG sent OK");
        return true;
    }
    else {
        NSLog(@"TAGMSK_DESC_CFG sent FAILED");
        return false;
    }
}

- (BOOL) TAGACC_DESC_CFG:(BOOL)isVerify retryCount:(Byte)count {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGMSK_DESC_CFG - Specify the parameters for a Select operation");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGACC_DESC_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x01, 0x0A, (isVerify & 0x01) + ((count << 1) & 0x03E), 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGACC_DESC_CFG length:sizeof(TAGACC_DESC_CFG)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGACC_DESC_CFG, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGACC_DESC_CFG sent OK");
        return true;
    }
    else {
        NSLog(@"TAGACC_DESC_CFG sent FAILED");
        return false;
    }
}

- (BOOL) TAGMSK_BANK:(MEMORYBANK)bank {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGMSK_BANK - Specify which memory bank is applied to during Select.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGMSK_BANK[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x08, (bank & 0x03), 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGMSK_BANK length:sizeof(TAGMSK_BANK)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGMSK_BANK, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGMSK_BANK sent OK");
        return true;
    }
    else {
        NSLog(@"TAGMSK_BANK sent FAILED");
        return false;
    }
}
- (BOOL) TAGMSK_PTR:(UInt16)ptr {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGMSK_PTR - Specify the bit offset in tag memory at which the configured mask will be applied during Select.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGMSK_PTR[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x08, ptr & 0xFF, (ptr >> 8) & 0xFF, (ptr >> 16) & 0xFF, (ptr >> 24) & 0xFF};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGMSK_PTR length:sizeof(TAGMSK_PTR)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGMSK_PTR, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGMSK_PTR sent OK");
        return true;
    }
    else {
        NSLog(@"TAGMSK_PTR sent FAILED");
        return false;
    }
}
- (BOOL) TAGMSK_LEN:(Byte)length {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGMSK_LEN - Specify the bit offset in tag memory at which the configured mask will be applied during Select.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGMSK_LEN[] = {0x80, 0x02, 0x70, 0x01, 0x04, 0x08, length & 0xFF, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGMSK_LEN length:sizeof(TAGMSK_LEN)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGMSK_LEN, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGMSK_LEN sent OK");
        return true;
    }
    else {
        NSLog(@"TAGMSK_LEN sent FAILED");
        return false;
    }
}

- (BOOL) setTAGMSK:(UInt16)TAGMSKAddr tagMask:(UInt32)mask {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"setTAGMSK - Write the tag mask data.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGMSK[] = {0x80, 0x02, 0x70, 0x01, TAGMSKAddr & 0xFF, (TAGMSKAddr >> 8) & 0xFF, (mask >> 24) & 0xFF, (mask >> 16) & 0xFF, (mask >> 8) & 0xFF, mask & 0xFF};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGMSK length:sizeof(TAGMSK)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGMSK, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"setTAGMSK sent OK");
        return true;
    }
    else {
        NSLog(@"setTAGMSK sent FAILED");
        return false;
    }
}

- (BOOL) TAGACC_BANK:(MEMORYBANK)bank acc_bank2:(MEMORYBANK)bank2 {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGACC_BANK - Specify which memory bank is applied to during access.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGACC_BANK[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x0A, (bank & 0x03) + ((bank2 << 2) & 0x0C), 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGACC_BANK length:sizeof(TAGACC_BANK)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGACC_BANK, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGACC_BANK sent OK");
        return true;
    }
    else {
        NSLog(@"TAGACC_BANK sent FAILED");
        return false;
    }
}
- (BOOL) TAGACC_PTR:(UInt32)ptr secondBank:(UInt32)ptr2 {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGACC_PTR - Specify the offset (16 bit words) in tag memory for tag accesses.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGACC_PTR[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x0A, ptr & 0xFF, (ptr >> 8) & 0xFF, ptr2 & 0xFF, (ptr2 >> 8) & 0xFF};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGACC_PTR length:sizeof(TAGACC_PTR)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGACC_PTR, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGACC_PTR sent OK");
        return true;
    }
    else {
        NSLog(@"TAGACC_PTR sent FAILED");
        return false;
    }
}
- (BOOL) TAGACC_PTR:(UInt32)ptr {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGACC_PTR - Specify the offset (16 bit words) in tag memory for tag accesses.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGACC_PTR[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x0A, ptr & 0xFF, (ptr >> 8) & 0xFF, (ptr >> 16) & 0xFF, (ptr >> 24) & 0xFF};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGACC_PTR length:sizeof(TAGACC_PTR)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGACC_PTR, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGACC_PTR sent OK");
        return true;
    }
    else {
        NSLog(@"TAGACC_PTR sent FAILED");
        return false;
    }
}

- (BOOL) TAGACC_CNT:(Byte)length secondBank:(Byte)length2 {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGACC_CNT - Write this register to specify the number of 16 bit words that should be accessed.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGACC_CNT[] = {0x80, 0x02, 0x70, 0x01, 0x04, 0x0A, length & 0xFF, length2 & 0xFF, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGACC_CNT length:sizeof(TAGACC_CNT)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGACC_CNT, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGACC_CNT sent OK");
        return true;
    }
    else {
        NSLog(@"TAGACC_CNT sent FAILED");
        return false;
    }
}
- (BOOL) TAGACC_ACCPWD:(UInt32)password {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"TAGACC_ACCPWD - Set this register to the access password.");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char TAGACC_ACCPWD[] = {0x80, 0x02, 0x70, 0x01, 0x06, 0x0A, password & 0xFF, (password >> 8) & 0xFF, (password >> 16) & 0xFF, (password >> 24) & 0xFF};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:TAGACC_ACCPWD length:sizeof(TAGACC_ACCPWD)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], TAGACC_ACCPWD, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"TAGACC_ACCPWD sent OK");
        return true;
    }
    else {
        NSLog(@"TAGACC_ACCPWD sent FAILED");
        return false;
    }
}
- (BOOL) setTAGWRDAT:(UInt16)TAGWRDATAddr data_word:(UInt16)word data_offset:(UInt16)offset {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"setTAGWRDAT - Set these registers to valid data prior to issuing the “Write” command (0x11).");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char setTAGWRDAT[] = {0x80, 0x02, 0x70, 0x01, TAGWRDATAddr & 0xFF, (TAGWRDATAddr >> 8) & 0xFF, word & 0xFF, (word >> 8) & 0xFF, offset & 0xFF, (offset >> 8) & 0xFF};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:setTAGWRDAT length:sizeof(setTAGWRDAT)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes
        return false;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    if (memcmp([payloadData bytes], setTAGWRDAT, 2) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"setTAGWRDAT sent OK");
        return true;
    }
    else {
        NSLog(@"setTAGWRDAT sent FAILED");
        return false;
    }
}

- (BOOL) sendHostCommandWrite {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Send HST_CMD 0x11 (Write Tag)...");
    NSLog(@"----------------------------------------------------------------------");
    
    //Send HST_CMD
    unsigned char HSTCMD[] = {0x80, 0x02, 0x70, 0x01, 0x0, 0xF0, 0x11, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:HSTCMD length:sizeof(HSTCMD)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([self.cmdRespQueue count] >= 3) //command response + command begin + command end
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] >= 3)
        recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    if (memcmp([recvPacket.payload bytes], HSTCMD, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Receive HST_CMD 0x11 response: OK");
    else
    {
        NSLog(@"Receive HST_CMD 0x11 response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    return true;
}
- (BOOL) sendHostCommandRead {
    
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Send HST_CMD 0x10 (Read Tag)...");
    NSLog(@"----------------------------------------------------------------------");
    
    //Send HST_CMD
    unsigned char HSTCMD[] = {0x80, 0x02, 0x70, 0x01, 0x0, 0xF0, 0x10, 0x00, 0x00, 0x00};
    packet.prefix=0xA7;
    packet.connection = Bluetooth;
    packet.payloadLength=0x0A;
    packet.deviceId=RFID;
    packet.Reserve=0x82;
    packet.direction=Downlink;
    packet.crc1=0;
    packet.crc2=0;
    packet.payload=[NSData dataWithBytes:HSTCMD length:sizeof(HSTCMD)];
    
    NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
    [self sendPackets:packet];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([self.cmdRespQueue count] >= 1) //command response + command begin + command end
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] >= 1)
        recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    if (memcmp([recvPacket.payload bytes], HSTCMD, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Receive HST_CMD 0x10 response: OK");
    else
    {
        NSLog(@"Receive HST_CMD 0x10 response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    return true;
}

- (BOOL) selectTag:(MEMORYBANK)maskbank maskPointer:(UInt16)ptr maskLength:(UInt32)length maskData:(NSData*)mask {
    
    BOOL result=true;
    
    NSLog(@"Tag select mask in hex: %@", [CSLBleReader convertDataToHexString:mask] );
    
    //Select the desired tag
    result=[self TAGMSK_DESC_CFG:true selectTarget:4 /* SL*/ selectAction:0];
    result=[self TAGMSK_BANK:maskbank];
    result=[self TAGMSK_PTR:ptr];
    result=[self TAGMSK_LEN:length];
    if (length > 0 && mask.length > 0) {
        result=[self setTAGMSK:TAGMSK_0_3 tagMask:((UInt32)(((Byte *)[mask bytes])[0] << 24)) + ((UInt32)(((Byte *)[mask bytes])[1] << 16)) + ((UInt32)(((Byte *)[mask bytes])[2] << 8)) + ((UInt32)((Byte *)[mask bytes])[3])];
    }
    if (length > 32 && mask.length > 4) {
        result=[self setTAGMSK:TAGMSK_4_7 tagMask:((UInt32)(((Byte *)[mask bytes])[4] << 24)) + ((UInt32)(((Byte *)[mask bytes])[5] << 16)) + ((UInt32)(((Byte *)[mask bytes])[6] << 8)) + ((UInt32)((Byte *)[mask bytes])[7])];
    }
    if (length > 64 && mask.length > 8) {
        result=[self setTAGMSK:TAGMSK_8_11 tagMask:((UInt32)(((Byte *)[mask bytes])[8] << 24)) + ((UInt32)(((Byte *)[mask bytes])[9] << 16)) + ((UInt32)(((Byte *)[mask bytes])[10] << 8)) + ((UInt32)((Byte *)[mask bytes])[11])];
    }
    if (length > 96 && mask.length > 12) {
        result=[self setTAGMSK:TAGMSK_12_15 tagMask:((UInt32)(((Byte *)[mask bytes])[12] << 24)) + ((UInt32)(((Byte *)[mask bytes])[13] << 16)) + ((UInt32)(((Byte *)[mask bytes])[14] << 8)) + ((UInt32)((Byte *)[mask bytes])[15])];
    }
    if (length > 128 && mask.length > 16) {
        result=[self setTAGMSK:TAGMSK_16_19 tagMask:((UInt32)(((Byte *)[mask bytes])[16] << 24)) + ((UInt32)(((Byte *)[mask bytes])[17] << 16)) + ((UInt32)(((Byte *)[mask bytes])[18] << 8)) + ((UInt32)((Byte *)[mask bytes])[19])];
    }
    if (length > 160 && mask.length > 20) {
        result=[self setTAGMSK:TAGMSK_20_23 tagMask:((UInt32)(((Byte *)[mask bytes])[20] << 24)) + ((UInt32)(((Byte *)[mask bytes])[21] << 16)) + ((UInt32)(((Byte *)[mask bytes])[22] << 8)) + ((UInt32)((Byte *)[mask bytes])[23])];
    }
    if (length > 192 && mask.length > 24) {
        result=[self setTAGMSK:TAGMSK_24_27 tagMask:((UInt32)(((Byte *)[mask bytes])[24] << 24)) + ((UInt32)(((Byte *)[mask bytes])[25] << 16)) + ((UInt32)(((Byte *)[mask bytes])[26] << 8)) + ((UInt32)((Byte *)[mask bytes])[27])];
    }
    if (length > 224 && mask.length > 28) {
        result=[self setTAGMSK:TAGMSK_28_31 tagMask:((UInt32)(((Byte *)[mask bytes])[28] << 24)) + ((UInt32)(((Byte *)[mask bytes])[29] << 16)) + ((UInt32)(((Byte *)[mask bytes])[30] << 8)) + ((UInt32)((Byte *)[mask bytes])[31])];
    }
    
    //stop after 1 tag inventoried, enable tag select, compact mode
    [self setInventoryConfigurations:FIXEDQ MatchRepeats:1 tagSelect:1 disableInventory:0 tagRead:0 crcErrorRead:0 QTMode:0 tagDelay:0 inventoryMode:0];
    
    return result;
}
- (BOOL) startTagMemoryRead:(MEMORYBANK)bank dataOffset:(UInt16)offset dataCount:(UInt16)count ACCPWD:(UInt32)password maskBank:(MEMORYBANK)mask_bank maskPointer:(UInt16)mask_pointer maskLength:(UInt32)mask_Length maskData:(NSData*)mask_data {
    
    BOOL result=true;
    CSLBlePacket *recvPacket;
    
    result=[self setParametersForTagAccess];
    
    //if mask data is not nil, tag will be selected before reading
    if (mask_data != nil)
        result=[self selectTag:mask_bank maskPointer:32 maskLength:mask_Length  maskData:mask_data];
    
    result = [self TAGACC_BANK:bank acc_bank2:0];
    result = [self TAGACC_PTR:offset];
    result = [self TAGACC_CNT:count secondBank:0];
    result = [self TAGACC_ACCPWD:password];
    result = [self sendHostCommandRead];
    
    //wait for the command-begin and command-end packet
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
        if ([self.cmdRespQueue count] >= 2)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] < 2) {
        NSLog(@"Tag read command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    
    //command-begin
    recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    if ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0080"])
        NSLog(@"Receive read command-begin response: OK");
    else
    {
        NSLog(@"Receive read command-begin response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    //decode command-end
    recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    if ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0180"] && ((Byte *)[recvPacket.payload bytes])[14] == 0x00 && ((Byte *)[recvPacket.payload bytes])[15] == 0x00)
        NSLog(@"Receive read command-end response: OK");
    else
    {
        NSLog(@"Receive read command-end response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return result;
}

- (BOOL) startTagMemoryWrite:(MEMORYBANK)bank dataOffset:(UInt16)offset dataCount:(UInt16)count writeData:(NSData*)data ACCPWD:(UInt32)password maskBank:(MEMORYBANK)mask_bank maskPointer:(UInt16)mask_pointer maskLength:(UInt32)mask_Length maskData:(NSData*)mask_data {
    
    int ptr, ptr2;  //tag write buffer pointer
    BOOL result=true;
    CSLBlePacket *recvPacket;
    
    result=[self setParametersForTagAccess];
    
    //if mask data is not nil, tag will be selected before reading
    if (mask_data != nil)
        result=[self selectTag:mask_bank maskPointer:32 maskLength:mask_Length  maskData:mask_data];
    
    result = [self TAGACC_DESC_CFG:true retryCount:7];
    result = [self TAGACC_BANK:bank acc_bank2:0];
    result = [self TAGACC_PTR:0];
    result = [self TAGACC_CNT:count secondBank:0];
    result = [self TAGACC_ACCPWD:password];

    ptr=0; ptr2=0;
    ptr+=offset;
    while ([data length] > ptr2) {
        if (count >= ptr) {
            result = [self setTAGWRDAT:0x0A09 data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        if ([data length]  > ptr2) {
            result = [self setTAGWRDAT:0x0A0A data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        if ([data length]  > ptr2) {
            result = [self setTAGWRDAT:0x0A0B data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        if ([data length]  > ptr2) {
            result = [self setTAGWRDAT:0x0A0C data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        if ([data length]  > ptr2) {
            result = [self setTAGWRDAT:0x0A0D data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        if ([data length] > ptr2) {
            result = [self setTAGWRDAT:0x0A0E data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        if ([data length] > ptr2) {
            result = [self setTAGWRDAT:0x0A0F data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        if ([data length] > ptr2) {
            result = [self setTAGWRDAT:0x0A0A data_word:((((Byte*)[data bytes])[ptr2] << 8)+((Byte*)[data bytes])[ptr2+1]) data_offset:ptr];
            ptr++; ptr2+=2;
        }
        
        result = [self sendHostCommandWrite];
        
        //wait for the command-begin and command-end packet
        for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
            if ([self.cmdRespQueue count] >= 2)
                break;
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if ([self.cmdRespQueue count] < 2) {
            NSLog(@"Tag read command timed out.");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return false;
        }
        
        //command-begin
        recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
        if ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0080"])
            NSLog(@"Receive read command-begin response: OK");
        else
        {
            NSLog(@"Receive read command-begin response: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return FALSE;
        }
        
        //decode command-end
        recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
        if ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0180"] && ((Byte *)[recvPacket.payload bytes])[14] == 0x00 && ((Byte *)[recvPacket.payload bytes])[15] == 0x00)
            NSLog(@"Receive read command-end response: OK");
        else
        {
            NSLog(@"Receive read command-end response: FAILED");
            connectStatus=CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
            return FALSE;
        }
    }

    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return result;
}

@end
