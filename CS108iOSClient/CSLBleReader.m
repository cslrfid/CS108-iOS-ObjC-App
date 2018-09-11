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
//    BOOL isRunningAsync;
    int firstTagReceived;
}

- (void) stopInventoryBlocking;

@end

@implementation CSLBleReader

@synthesize filteredBuffer;
@synthesize cmdRespQueue;
@synthesize delegate; //synthesize CSLBleReaderDelegate delegate
@synthesize rangingTagCount;

- (id) init
{
    if (self = [super init])
    {
        rangingTagCount=0;
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

- (BOOL)readOEMData:(CSLBleInterface*)intf atAddr:(unsigned short)addr forData:(NSData*)data
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
    [self.cmdRespQueue removeAllObjects];
    
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    
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
        if ([self.cmdRespQueue count] !=0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    if ([self.cmdRespQueue count] != 0)
        recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
        if ([self.cmdRespQueue count] >= 2)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] >= 2)
        recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    else
    {
        NSLog(@"Command timed out.");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return false;
    }
    

    if (memcmp([recvPacket.payload bytes], OEMHSTCMD, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
        NSLog(@"Receive HST_CMD 0x03 response: OK");
    else
    {
        NSLog(@"Receive HST_CMD 0x03 response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    if (((Byte *)[recvPacket.payload bytes])[0] == 0x81 && ((Byte *)[recvPacket.payload bytes])[1] == 0x00)
    {
        NSLog(@"Read OEM data: OK");
        data = recvPacket.getPacketInHexString;
    }
    else
    {
        NSLog(@"Read OEM data: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return TRUE;
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
    [self.cmdRespQueue removeAllObjects];

    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    NSData * payloadData;
    
    //power on barcode
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Power %s barcode module...", enable ? "on" : "off");
    NSLog(@"----------------------------------------------------------------------");
    unsigned char barcodeOn[] = {0x90, 0x00};
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
        if ([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        payloadData = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
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
    [self.cmdRespQueue removeAllObjects];
    
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
    if (memcmp([payloadData bytes], powerRfid, sizeof(powerRfid)) == 0 && ((Byte *)[payloadData bytes])[2] == 0x00) {
        NSLog(@"Power %s RFID module OK", (enable ? "on" : "off"));
        return true;
    }
    else {
        NSLog(@"Power %s RFID module FAILED", (enable ? "on" : "off"));
        return false;
    }
}
- (BOOL)getBtFirmwareVersion:(NSString *)versionNumber
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
    [self.cmdRespQueue removeAllObjects];
    
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
       if([self.cmdRespQueue count] != 0)
           break;
           [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0)
        versionInfo = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
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
    
    versionNumber=btFwVersion;
    connectStatus=CONNECTED;
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    return true;
}

- (BOOL) getConnectedDeviceName:(NSString *) deviceName
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
        
    if ([self.cmdRespQueue count] != 0) {
        NSData * name = [((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload subdataWithRange:NSMakeRange(2, 21)];
        deviceName = [NSString stringWithUTF8String:[name bytes]];
        NSLog(@"Device Name: %@", deviceName);
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
- (BOOL)getSilLabIcVersion:(NSString *) slVersion
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    if ([self.cmdRespQueue count] != 0) {
        NSData * versionInfo = ((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload;
        slVersion=[NSString stringWithFormat:@"%d.%d.%d", ((Byte*)[versionInfo bytes])[2], ((Byte*)[versionInfo bytes])[3], ((Byte*)[versionInfo bytes])[4]];
        NSLog(@"SilconLab IC firmware version: %@", slVersion);
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


- (BOOL)getRfidBrdSerialNumber:(NSString*) serialNumber {
    
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

    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Get 16 bytes serial number...");
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        NSData * name = [((CSLBlePacket *)[self.cmdRespQueue deqObject]).payload subdataWithRange:NSMakeRange(2, 16)];
        serialNumber=[NSString stringWithUTF8String:[name bytes]];
        NSLog(@"16 byte serial number: %@", serialNumber);
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

- (BOOL)sendAbortCommand {
    
    @synchronized(self) {
        if (connectStatus!=CONNECTED && connectStatus!=TAG_OPERATIONS)  //reader is not idling for downlink command and not performing inventory
        {
            NSLog(@"Reader is not connected or busy. Access failure");
            return false;
        }
    }
    [self.cmdRespQueue removeAllObjects];
    
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
        if ([self.cmdRespQueue count] !=0)
        {
            recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
            if ([[recvPacket getPacketPayloadInHexString] containsString:@"4003BFFCBFFCBFFC"]) {
                isAborted=true;
                break;
            }
            
        }
        else
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
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

- (BOOL)getRfidFwVersionNumber:(NSString*) versionInfo {

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
        if([self.cmdRespQueue count] >= 2)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] >= 2) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
        if (memcmp([recvPacket.payload bytes], rfidFWVersion, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
            NSLog(@"RFID firmware version command sent: OK");
        else {
            NSLog(@"RFID firmware version command sent: FAILED");
            connectStatus=CONNECTED;
            return false;
        }
    }
        
    recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    unsigned short byte1, byte2, byte3, byte4;
    if (((Byte*)[recvPacket.payload bytes])[4] == 0x00 && ((Byte*)[recvPacket.payload bytes])[5] == 0x00 && [recvPacket.payload length] == 10) {
        byte1 = ((Byte*)[recvPacket.payload bytes])[6];
        byte2 = ((Byte*)[recvPacket.payload bytes])[7];
        byte3 = ((Byte*)[recvPacket.payload bytes])[8];
        byte4 = ((Byte*)[recvPacket.payload bytes])[9];
        versionInfo=[NSString stringWithFormat:@"%d.%d.%d", byte4, ((byte2 >> 4) & 0x0F) + ((byte3 << 4) & 0xF00), (byte2 & 0x0F) + byte1];
        NSLog(@"RFID firmware: %@", versionInfo);
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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


- (BOOL)selectAlgorithmParameter:(NSUInteger) descriptorIndex {
    
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
    
    //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
    //unsigned int desc_idx=3;    //select algortihm #3 (Dyanmic Q)
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Select which set of algorithm parameter registers to access (INV_SEL)...");
    NSLog(@"----------------------------------------------------------------------");
    
    unsigned char INV_SEL[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x09, descriptorIndex & 0x000000FF, (descriptorIndex & 0x0000FF00) >> 8, (descriptorIndex & 0x00FF0000) >> 16, (descriptorIndex & 0xFF000000) >> 24};
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
    [self.cmdRespQueue removeAllObjects];
    
    //Initialize data
    CSLBlePacket* packet= [[CSLBlePacket alloc] init];
    CSLBlePacket * recvPacket;
    //Set algorithm parameters (INV_ALG_PARM_0) for DyanmicQ reg_addr = 0x0901
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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

- (BOOL)setInventoryConfigurations:(Byte) inventoryAlgorithm MatchRepeats:(Byte)match_rep tagSelect:(Byte)tag_sel disableInventory:(Byte)disable_inventory tagRead:(Byte) tag_read
                      crcErrorRead:(Byte) crc_err_read QTMode:(Byte) QT_mode tagDelay:(Byte) tag_delay inventoryMode:(Byte)inv_mode {
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
    
    //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
    //Byte Inv_algo=0x03, match_rep=0, tag_sel=0, disable_inv=0, tag_read=0, crc_err_read=1, QT_mode=0, tag_delay=0, inv_mode=1;  //inventory algorithm #3, enable crc error read, compact mode inventory
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Set inventory configurations (INV_CFG) addr:0x0902...");
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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

- (BOOL)setQueryConfigurations:(Byte) queryTarget querySession:(Byte)query_session querySelect:(Byte)query_sel  {
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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

- (BOOL)setLinkProfile:(Byte) profile
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
    [self.cmdRespQueue removeAllObjects];
    
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
        if ([self.cmdRespQueue count] !=0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0)
        recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
    recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    if ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0080"])
        NSLog(@"Receive HST_CMD 0x19 command-begin response: OK");
    else
    {
        NSLog(@"Receive HST_CMD 0x19 command-begin response: FAILED");
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        return FALSE;
    }
    
    //command-end
    recvPacket = ((CSLBlePacket *)[self.cmdRespQueue deqObject]);
    if ([[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[recvPacket.getPacketPayloadInHexString substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0180"] && ((Byte *)[recvPacket.payload bytes])[14] == 0x00 && ((Byte *)[recvPacket.payload bytes])[15] == 0x00)
        NSLog(@"Receive HST_CMD 0x19 command-end response: OK");
    else
    {
        NSLog(@"Receive HST_CMD 0x19 command-end response: FAILED");
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
    }
    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
    [self.recvQueue removeAllObjects];
    [self.cmdRespQueue removeAllObjects];
    
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
        if([self.cmdRespQueue count] != 0)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if ([self.cmdRespQueue count] != 0) {
        recvPacket=((CSLBlePacket *)[self.cmdRespQueue deqObject]);
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
    
    connectStatus=TAG_OPERATIONS;
    [self performSelectorInBackground:@selector(decodePacketsInBufferAsync) withObject:(nil)];
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
            NSLog(@"Abort command response failure.  Try #%d", j);
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

- (void)decodePacketsInBufferAsync;
{
    CSLBlePacket* packet;
    NSString* payload;      //payload in hex string
    NSData* payloadInBytes; //payload in bytes
    NSString * eventCode;
    
    filteredBuffer=[[NSMutableArray alloc] init];
    
    BOOL isAppendPacket=false;
    
    int datalen;
    while (bleDevice)  //packet decoding would continue
    {
        @synchronized(recvQueue) {
            if ([self.recvQueue count] > 0)
            {
                //dequque the next packet received
                packet=((CSLBlePacket *)[self.recvQueue deqObject]);
            
                //get event code
                eventCode = [[packet getPacketPayloadInHexString] substringToIndex:4];
                
                //if we recieved a partial RFID packet on the previosu loop that to be combined with the current packet
                if (isAppendPacket && [eventCode isEqualToString:@"8100"]) { //append to the previous packet
                    
                    NSMutableData * combinedData=[payloadInBytes mutableCopy];
                    [combinedData appendData:[packet.payload subdataWithRange:NSMakeRange(2, [packet.payload length]-2)]];
                    payloadInBytes=combinedData;
                    
                    [payload stringByAppendingString:[packet.getPacketPayloadInHexString substringWithRange:NSMakeRange(4, packet.getPacketPayloadInHexString.length-4)]];
                }
                else {
                    payloadInBytes = packet.payload;
                    payload=packet.getPacketPayloadInHexString;
                }

                NSLog(@"[decodePacketsInBufferAsync] Payload to be decoded: %@", payload);
                
                //**************************************
                //selector of different command responses
                if ([eventCode isEqualToString:@"8100"])    //RFID module responses
                {
                    if ([payload containsString:@"81004003BFFCBFFCBFFC"]) {
                        NSLog(@"[decodePacketsInBufferAsync] Abort command received.  All opeartions ended");
                        [self.cmdRespQueue enqObject:packet];
                        connectStatus=CONNECTED;
                        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                        continue;
                    }
                    
                    //command begin response
                    if ([payload length] >= 12)
                    {
                        if ([[payload substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[payload substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0080"]) {
                            NSLog(@"[decodePacketsInBufferAsync] Command-begin response recieved: %@", payload);
                            //return packet directly to the API for decoding
                            [self.cmdRespQueue enqObject:packet];
                            continue;
                        }
                    }
                    
                    //command end response
                    if ([payload length] >= 12)
                    {
                        if ([[payload substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"02"] && [[payload substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0180"]) {
                            NSLog(@"[decodePacketsInBufferAsync] Command-end response recieved: %@", payload);
                            //return packet directly to the API for decoding
                            [self.cmdRespQueue enqObject:packet];
                            continue;
                        }
                    }
                    
                    if ([payload length] >= 8)
                    {
                        if ([[payload substringWithRange:NSMakeRange(4,4)] isEqualToString:@"7000"] || [[payload substringWithRange:NSMakeRange(4,4)] isEqualToString:@"7001"]) {
                            //response when reading/writing registers.  Return packet directly to the API for decoding
                            [self.cmdRespQueue enqObject:packet];
                            continue;
                        }
                    }
                    
                    NSLog(@"[decodePacketsInBufferAsync] Current filtered buffer size: %d", (int)[filteredBuffer count]);
                    //check if packet is compact response packet
                    if ([payload length] >= 12) {
                        if ([[payload substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"04"] && [[payload substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"0580"])
                        {
                            //start decode message
                            datalen=((Byte *)[payloadInBytes bytes])[6] + (((((Byte *)[payloadInBytes bytes])[7] << 8) & 0xFF00)) ;
                            
                            //iterate through all the tag data
                            int ptr=10;
                            while(TRUE)
                            {
                                CSLBleTag* tag=[[CSLBleTag alloc] init];
                                
                                tag.PC =((((Byte *)[payloadInBytes bytes])[ptr] << 8) & 0xFF00)+ ((Byte *)[payloadInBytes bytes])[ptr+1];
                                tag.EPC=[payload substringWithRange:NSMakeRange((ptr*2)+4, ((tag.PC >> 11) * 2) * 2)];
                                tag.rssi=(Byte)((Byte *)[payloadInBytes bytes])[(ptr + 2) + ((tag.PC >> 11) * 2)];
                                ptr+= (2 + ((tag.PC >> 11) * 2) + 1);
                                [self.readerDelegate didReceiveTagResponsePacket:self tagReceived:tag]; //this will call the method for handling the tag response.
                                
                                NSLog(@"[decodePacketsInBufferAsync] Tag data found: PC=%04X EPC=%@ rssi=%d", tag.PC, tag.EPC, tag.rssi);
                                rangingTagCount++;
                                
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
                                    
                                }
                                else if ( [((CSLBleTag*)filteredBuffer[findIndex]).EPC caseInsensitiveCompare:tag.EPC] != NSOrderedSame)
                                {
                                    //new tag found.  insert into buffer in sorted order
                                    [filteredBuffer insertObject:tag atIndex:findIndex];
                                }
                                else    //tag is duplicated, but will replace the existing tag information with the new one for updating the RRSI value.
                                {
                                    [filteredBuffer replaceObjectAtIndex:findIndex withObject:tag];
                                }
                                
                                //for the cases where we reaches the end of the RFID reponse packet but there are still data within the bluetooth reader packet.
                                // (1) user is aborting the operation so that the abort command reponse
                                if ((ptr >= (datalen + 10)) && ([payloadInBytes length] >= (datalen + 10 /* 8 bytes of bluetooth packet header + 2 byte for the payload reply */ + 8 /* 8 bytes for the abort command response or other RFID command reponse*/)))
                                {
                                    NSLog(@"[decodePacketsInBufferAsync] Decoding the data appended to the end of the 8100 packet: %@", [payload substringWithRange:NSMakeRange(ptr * 2, ([payloadInBytes length] - ptr) * 2)] );
                                    if ([[payload substringWithRange:NSMakeRange(ptr * 2, ([payloadInBytes length] - ptr) * 2)] containsString:@"4003BFFCBFFCBFFC"]) {
                                        NSLog(@"[decodePacketsInBufferAsync] Abort command received.  All operations ended");
                                        [self.cmdRespQueue enqObject:packet];
                                        connectStatus=CONNECTED;
                                        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                                        break;
                                    }
                                    //check if we are getting the beginning of another 8100 packet.  If so, decode the beinginning of the next RFID response
                                    else if ([[payload substringWithRange:NSMakeRange((ptr * 2)  + 4, 2)] isEqualToString:@"04"] && [[payload substringWithRange:NSMakeRange((ptr * 2)+8, 4)] isEqualToString:@"0580"])
                                    {
                                        datalen=((Byte *)[payloadInBytes bytes])[ptr+6] + (((((Byte *)[payloadInBytes bytes])[ptr+7] << 8) & 0xFF00)) ;
                                        payloadInBytes = [payloadInBytes subdataWithRange:NSMakeRange(ptr + 8, [payloadInBytes length]-ptr-8)];
                                        payload=[payload substringWithRange:NSMakeRange((ptr * 2) + 16, [payload length]-(ptr * 2)-16)];
                                        isAppendPacket=true;
                                    }
                                    else
                                        isAppendPacket=false;
                                }
                                
                                //return when pointer reaches the end of the RFID response packet.
                                if (ptr >= (datalen + 10))
                                    break;
                            }
                        }
                    }
                }
                else if ([eventCode isEqualToString:@"9000"]) {   //Power on barcode
                    NSLog(@"[decodePacketsInBufferAsync] Power on barcode");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"8000"]) {   //Power on RFID module
                    NSLog(@"[decodePacketsInBufferAsync] Power on Rfid Module");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"8001"]) {   //Power off RFID module
                    NSLog(@"[decodePacketsInBufferAsync] Power off Rfid Module");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"C000"]) {   //Get BT firmware version
                    NSLog(@"[decodePacketsInBufferAsync] Get BT firmware version");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"C004"]) {   //Get connected device name
                    NSLog(@"[decodePacketsInBufferAsync] Get connected device name");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"B000"]) {   //Get SilconLab IC firmware version.
                    NSLog(@"[decodePacketsInBufferAsync] Get SilconLab IC firmware version.");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"B004"]) {   //Get 16 byte serial number.
                    NSLog(@"[decodePacketsInBufferAsync] Get 16 byte serial number.");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"8002"]) {   //RFID firmware command response
                    NSLog(@"[decodePacketsInBufferAsync] RFID firmware command response.");
                    [self.cmdRespQueue enqObject:packet];
                }
                else if ([eventCode isEqualToString:@"A103"]) {
                    //Trigger key is released.  Trigger callback delegate method
                    NSLog(@"[decodePacketsInBufferAsync] Trigger key: OFF");
                    [self.readerDelegate didTriggerKeyChangedState:self keyState:false]; //this will call the method for handling the tag response.
                }
                else if ([eventCode isEqualToString:@"A102"]) {
                    //Trigger key is pressed.  Trigger callback delegate method
                    NSLog(@"[decodePacketsInBufferAsync] Trigger key: ON");
                    [self.readerDelegate didTriggerKeyChangedState:self keyState:true]; //this will call the method for handling the tag response.
                }
            }
        }
    }

    NSLog(@"[decodePacketsInBufferAsync] Ended!");
}


@end
