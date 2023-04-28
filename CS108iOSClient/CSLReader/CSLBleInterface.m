//
//  CSLBleInterface.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLBleInterface.h"

@interface CSLBleInterface() {
    CBCentralManager * manager;
    CBCharacteristic * bleSend;     //Service UUID=9900
    CBCharacteristic * bleReceive;  //Service UUID=9901
    NSMutableData * sendBuffer;     //byte array for sending data
    NSMutableData * recvBuffer;     //byte array for receving data
}
- (void) startScanDeviceBlocking;

@end

@implementation CSLBleInterface

@synthesize bleDeviceList;
@synthesize LastException;
@synthesize bleDevice;
@synthesize recvQueue;
@synthesize connectStatus;
@synthesize deviceName;
@synthesize deviceListName;

@synthesize delegate; //synthesize CSLBleInterfaceDelegate delegate
@synthesize scanDelegate; //synthesize CSLBleScanDelegate delegate

- (id) init
{
    if (self = [super init])
    {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
        bleDeviceList = [NSMutableArray array];
        deviceListName = [NSMutableArray array];
        recvQueue=[[CSLCircularQueue alloc] initWithCapacity:16000];
    }
    return self;
}


- (void) dealloc
{
    if (self.connectStatus==SCANNING)
        [self stopScanDevice];
    
    [bleDevice setDelegate:nil];

}

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBManagerStatePoweredOn:
            return TRUE;
        case CBManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);

    return false;
}

- (void)startScanDevice
{
    [self performSelectorInBackground:@selector(startScanDeviceBlocking) withObject:(nil)];
}

- (void)startScanDeviceBlocking
{
    @autoreleasepool {
        @try {
            
            //wait for up to 5 seconds before the Central Manager state got updated.
            int countIn100Milliseconds=0;
            while(countIn100Milliseconds<50)
            {
                if (connectStatus==NOT_CONNECTED)
                    break;
                [NSThread sleepForTimeInterval:0.1f];
                countIn100Milliseconds++;
            }
            @synchronized(self) {
                if (connectStatus==NOT_CONNECTED && [self isLECapableHardware])
                {
                    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
                    [bleDeviceList removeAllObjects];
                    [deviceListName removeAllObjects];
                    [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"9800"]] options:options];
                    connectStatus=SCANNING;
                    [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
                }
                else
                    NSLog(@"Cannot scan device when device is already been scanning, or existing hardware does not support bluetooth");
            }
        }
        @catch (NSException* exception) {
            
        }
    }
}

- (void) connectDevice:(CBPeripheral*) peripheral {
    
    [self stopScanDevice];
    
    
    if(bleDevice && (bleDevice.state == CBPeripheralStateConnected))
    {
        /* Disconnect peripheral if its already connected */
        [manager cancelPeripheralConnection:bleDevice];
    }
    else if (bleDevice)
    {
        /* Device is not connected, cancel pending connection */
        [manager cancelPeripheralConnection:bleDevice];
        bleDevice = peripheral;
        [manager connectPeripheral:bleDevice options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
    else
    {
        /* No outstanding connection, open scan sheet */
        bleDevice = peripheral;
        [manager connectPeripheral:bleDevice options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

- (void) disconnectDevice;
{
    @try {
        if(bleDevice)
        {
            [manager cancelPeripheralConnection:bleDevice];
            connectStatus=NOT_CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        }
    }
    @catch (NSException *Exception ) {
        LastException = Exception;
    }
}

- (void)stopScanDevice
{
    @try {
        if (self.connectStatus==SCANNING)
        {
            [manager stopScan];
            connectStatus=NOT_CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        }
    }
    @catch (NSException *Exception ){
        LastException = Exception;
    }
    
}

- (void) sendPackets:(CSLBlePacket *) packet
{
    if(!(connectStatus==ERROR || connectStatus==NOT_CONNECTED))
    {
        Byte header[] = { packet.prefix, packet.connection, packet.payloadLength, packet.deviceId, packet.Reserve, packet.direction, packet.crc1, packet.crc2};
        NSMutableData * data = [NSMutableData dataWithBytes:header length:sizeof(header)];
        [data appendData:packet.payload];

        /*
        if(bleReceive)
        {
            [bleDevice setNotifyValue:true forCharacteristic:bleReceive];
        }
        [NSThread sleepForTimeInterval:0.2f];
        */
        if(bleSend)
        {
            [bleDevice writeValue:data forCharacteristic:bleSend type:CBCharacteristicWriteWithResponse];
        }
        
    }
    else
        NSLog(@"Unable to send packet (%@): reader status=%d",[packet getPacketInHexString],connectStatus);
    
}

#pragma mark - CBManagerDelegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    @synchronized(self) {
        if ([self isLECapableHardware])
        {
            connectStatus=NOT_CONNECTED;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        }
        else
        {
            connectStatus=ERROR;
            [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        }
    }
}

/*
 Invoked when the central discovers CSL peripheral while scanning.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData);
    
    //for CS463 BT mode, copy the kCBAdvDataLocalName value to the peripheral name.
    NSString* peripheralName=(NSString*)[advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    if (peripheralName) {
        NSMutableArray *peripherals = [self mutableArrayValueForKey:@"bleDeviceList"];
        if( ![bleDeviceList containsObject:peripheral] ) {
            [deviceListName addObject:peripheralName];
            [peripherals addObject:peripheral];
            [self.scanDelegate deviceListWasUpdated:peripheral];
        }
    }

}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Assign the list to the device list on the object
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
    
    @try {
        //[self stopScanDevice];

        /* If there are any known devices, automatically connect to it.*/
        if([peripherals count] >=1)
        {
            bleDevice  = [peripherals objectAtIndex:0];
            [manager connectPeripheral:bleDevice options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        }
    }
    @catch (NSException *Exception ){
        LastException = Exception;
    }

}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect to peripheral: %@", peripheral);
    
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    [self.scanDelegate didConnectToDevice:peripheral];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did Disconnect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);
    @synchronized(self) {
        connectStatus = NOT_CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        [self.scanDelegate didDisconnectDevice:peripheral];
        if( bleDevice )
        {
            [bleDevice setDelegate:nil];
            bleDevice = nil;
        }
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);
    [self.scanDelegate didFailedToConnect:peripheral];
    if( bleDevice )
    {
        [bleDevice setDelegate:nil];
        bleDevice = nil;
    }
}

#pragma mark - CBPeripheralDelegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    for (CBService * service in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@", service.UUID.UUIDString);
        
        // for the CSL reader UUID
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"9800"]])
        {
            /* CSL Characterister UUID  - downlink and uplink respectively */
            [bleDevice discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:@"9900"], [CBUUID UUIDWithString:@"9901"],  nil] forService:service];
        }
        else if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            /* CSL Device Information Service - discover manufacture name characteristic */
            [bleDevice discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A29"]] forService:service];
        }
        
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    NSLog(@"didDiscoverCharacteristicsForService service UUID=%@", service.UUID);
    
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"9800"]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            NSLog(@"Service UUID=%@ | characteristic UUID=%@", service.UUID, characteristic.UUID);
            /* Set downlink */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"9900"]])
            {
                bleSend = characteristic;
                NSLog(@"Found a BLE Downlink Characteristic");
            }
            /* Set notification on intermediate temperature measurement */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"9901"]])
            {
                bleReceive = characteristic;
                NSLog(@"Found a BLE Uplink Characteristic");
            }
        }
        [NSThread sleepForTimeInterval:0.2f];

    }
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            /* Read manufacturer name */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
            {
                [bleDevice readValueForCharacteristic:characteristic];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
    if (bleSend && bleReceive)
    {
        connectStatus=CONNECTED;
        [self.delegate didInterfaceChangeConnectStatus:self]; //this will call the method for connections status chagnes.
        [bleDevice setNotifyValue:true forCharacteristic:bleReceive];
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Start didUpdateValueForCharacteristic");
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    /* Updated value for data packet received */
    //NSLog(@"Value for characteristic: %@", characteristic.value);
    
    if(([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"9901"]]) && characteristic.value)
    {
        if (recvBuffer == nil)
            recvBuffer = [[NSMutableData alloc] initWithData:characteristic.value];
        else
            [recvBuffer appendData:characteristic.value];

        if (recvBuffer.length >= 2) {
            if (((unsigned char *)[recvBuffer bytes])[0] != 0xA7 || ((unsigned char *)[recvBuffer bytes])[1] != 0xB3)
            {
                NSLog(@"BLE data received but incorrect header information.");
                [recvBuffer setLength:0];
                return;
            }
        }
        
        //decode the packet header to find out the type and size of the packet.  If the receival of the packet is not completed, wait for the next reception
        if(recvBuffer.length < (((unsigned char *)[recvBuffer bytes])[2] + 8))
        {
            NSLog(@"Partial packet received.  Current buffer size: %d, packet size: %d", (unsigned int)[recvBuffer length], (((unsigned char *)[recvBuffer bytes])[2] + 8));
            return;
        }
        else
        {
            NSLog(@"Complete received.  Curerent buffer size: %d", (unsigned int)[recvBuffer length]);
            //the receive buffer contains data for a complete packet.  Start decode packet and push to the circular buffer
            CSLBlePacket* packet= [[CSLBlePacket alloc] init];
            
            packet.prefix=((Byte*)[recvBuffer bytes])[0];
            packet.connection = ((Byte*)[recvBuffer bytes])[1];
            packet.payloadLength=((Byte*)[recvBuffer bytes])[2];
            packet.deviceId=((Byte*)[recvBuffer bytes])[3];
            packet.Reserve=((Byte*)[recvBuffer bytes])[4];
            packet.direction=((Byte*)[recvBuffer bytes])[5];
            packet.crc1=((Byte*)[recvBuffer bytes])[6];;
            packet.crc2=((Byte*)[recvBuffer bytes])[7];;
            packet.payload=[NSData dataWithBytes:&([recvBuffer bytes][8]) length:packet.payloadLength];
            
            NSLog(@"BLE Packet received: %@", packet.getPacketInHexString);
            NSData * cs=[self computeChecksum:[[NSData alloc] initWithBytes:[recvBuffer bytes] length:8+packet.payloadLength]];
            NSLog(@"Checksum calculated: %02X%02X", ((Byte*)[cs bytes])[1], ((Byte*)[cs bytes])[0]);
            if (((Byte*)[cs bytes])[1] == packet.crc1 && ((Byte*)[cs bytes])[0] == packet.crc2) {
                NSLog(@"Checksum verification: PASSED");
                packet.isCRCPassed=true;
            }
            else {
                NSLog(@"Checksum verification: FAILED");
                packet.isCRCPassed=false;
            }
            
            //always enqueue the packet even it has a checksum verification fail.  This will be caught during decoding
            [recvQueue enqObject:packet];
            
            NSLog(@"Received packet payload size: 0x%2X byte(s)", ((unsigned char *)[recvBuffer bytes])[2] );

            //[recvBuffer replaceBytesInRange:NSMakeRange(0, packet.payloadLength+8) withBytes:NULL length:0];
            [recvBuffer setLength:0];
        }
    }
    
    /* Value for device name received */
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A00"]])
    {
        deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Device Name = %@", deviceName);
    }
    
}

/*
 Invoked upon completion of a -[setNotifyValue:forCharacteristic:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating notification state for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    NSLog(@"Updated notification state for characteristic %@ (newState:%@)", characteristic.UUID, [characteristic isNotifying] ? @"Notifying" : @"Not Notifying");
    
    if( ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"9901"]]) )
    {
        if( [characteristic isNotifying] )
        {
            
        }
        else
        {

        }
    }
}

- (NSData *) computeChecksum: (NSData *) dataIn
{
    unsigned short checksum = 0;
    unsigned char *bytePtr = (unsigned char *)[dataIn bytes];
    
    for (int i = 0; i < (bytePtr[2]  + 8); i++)
    {
        if (i != 6 && i != 7)
        {
            int index = (checksum ^ (bytePtr[i] & 0x0FF)) & 0x0FF;
            checksum = (unsigned short)((checksum >> 8) ^ crc_lookup_table[index]);
        }
    }
    
    return [NSData dataWithBytes:&checksum length:2];
}

unsigned short crc_lookup_table[] = {
    0x0000, 0x1189, 0x2312, 0x329b, 0x4624, 0x57ad, 0x6536, 0x74bf,
    0x8c48, 0x9dc1, 0xaf5a, 0xbed3, 0xca6c, 0xdbe5, 0xe97e, 0xf8f7,
    0x1081, 0x0108, 0x3393, 0x221a, 0x56a5, 0x472c, 0x75b7, 0x643e,
    0x9cc9, 0x8d40, 0xbfdb, 0xae52, 0xdaed, 0xcb64, 0xf9ff, 0xe876,
    0x2102, 0x308b, 0x0210, 0x1399, 0x6726, 0x76af, 0x4434, 0x55bd,
    0xad4a, 0xbcc3, 0x8e58, 0x9fd1, 0xeb6e, 0xfae7, 0xc87c, 0xd9f5,
    0x3183, 0x200a, 0x1291, 0x0318, 0x77a7, 0x662e, 0x54b5, 0x453c,
    0xbdcb, 0xac42, 0x9ed9, 0x8f50, 0xfbef, 0xea66, 0xd8fd, 0xc974,
    0x4204, 0x538d, 0x6116, 0x709f, 0x0420, 0x15a9, 0x2732, 0x36bb,
    0xce4c, 0xdfc5, 0xed5e, 0xfcd7, 0x8868, 0x99e1, 0xab7a, 0xbaf3,
    0x5285, 0x430c, 0x7197, 0x601e, 0x14a1, 0x0528, 0x37b3, 0x263a,
    0xdecd, 0xcf44, 0xfddf, 0xec56, 0x98e9, 0x8960, 0xbbfb, 0xaa72,
    0x6306, 0x728f, 0x4014, 0x519d, 0x2522, 0x34ab, 0x0630, 0x17b9,
    0xef4e, 0xfec7, 0xcc5c, 0xddd5, 0xa96a, 0xb8e3, 0x8a78, 0x9bf1,
    0x7387, 0x620e, 0x5095, 0x411c, 0x35a3, 0x242a, 0x16b1, 0x0738,
    0xffcf, 0xee46, 0xdcdd, 0xcd54, 0xb9eb, 0xa862, 0x9af9, 0x8b70,
    0x8408, 0x9581, 0xa71a, 0xb693, 0xc22c, 0xd3a5, 0xe13e, 0xf0b7,
    0x0840, 0x19c9, 0x2b52, 0x3adb, 0x4e64, 0x5fed, 0x6d76, 0x7cff,
    0x9489, 0x8500, 0xb79b, 0xa612, 0xd2ad, 0xc324, 0xf1bf, 0xe036,
    0x18c1, 0x0948, 0x3bd3, 0x2a5a, 0x5ee5, 0x4f6c, 0x7df7, 0x6c7e,
    0xa50a, 0xb483, 0x8618, 0x9791, 0xe32e, 0xf2a7, 0xc03c, 0xd1b5,
    0x2942, 0x38cb, 0x0a50, 0x1bd9, 0x6f66, 0x7eef, 0x4c74, 0x5dfd,
    0xb58b, 0xa402, 0x9699, 0x8710, 0xf3af, 0xe226, 0xd0bd, 0xc134,
    0x39c3, 0x284a, 0x1ad1, 0x0b58, 0x7fe7, 0x6e6e, 0x5cf5, 0x4d7c,
    0xc60c, 0xd785, 0xe51e, 0xf497, 0x8028, 0x91a1, 0xa33a, 0xb2b3,
    0x4a44, 0x5bcd, 0x6956, 0x78df, 0x0c60, 0x1de9, 0x2f72, 0x3efb,
    0xd68d, 0xc704, 0xf59f, 0xe416, 0x90a9, 0x8120, 0xb3bb, 0xa232,
    0x5ac5, 0x4b4c, 0x79d7, 0x685e, 0x1ce1, 0x0d68, 0x3ff3, 0x2e7a,
    0xe70e, 0xf687, 0xc41c, 0xd595, 0xa12a, 0xb0a3, 0x8238, 0x93b1,
    0x6b46, 0x7acf, 0x4854, 0x59dd, 0x2d62, 0x3ceb, 0x0e70, 0x1ff9,
    0xf78f, 0xe606, 0xd49d, 0xc514, 0xb1ab, 0xa022, 0x92b9, 0x8330,
    0x7bc7, 0x6a4e, 0x58d5, 0x495c, 0x3de3, 0x2c6a, 0x1ef1, 0x0f78};




@end
