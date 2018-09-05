//
//  ViewController.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 25/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize tagListing;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Insert code here to initialize your application
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"Initialize the CSLBleReader object instance...");
    NSLog(@"----------------------------------------------------------------------");
    reader = [[CSLBleReader alloc] init];

    NSLog(@"Bluetooth interface ready.");
    NSLog(@"Start scanning CSL reader for 5 seconds...");
    [reader startScanDevice];
    
    [NSThread sleepForTimeInterval:5.0f];   //scan for 5 seconds
    
    if (reader.bleDeviceList.count != 0)    //if device found.
    {
        
        //populate reader picker menu
        self.readerPicker.dataSource=self;
        self.readerPicker.delegate=self;
        [self.readerPicker reloadAllComponents];
        reader.delegate = self;
        reader.readerDelegate=self;
    }

    btnConnect.layer.borderWidth=1.0f;
    btnInventory.layer.borderWidth=1.0f;
    
    
    btnConnect.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnInventory.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    btnInventory.enabled=false;
    
    //tagListing = [[UITableView alloc] init];
    tagListing.dataSource=self;
    tagListing.delegate=self;
    [tagListing reloadData];
    
    //timer event on updating UI
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(refreshTagListing)
                                   userInfo:nil
                                    repeats:YES];
    
    //timer event on reading trigger key
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(readTriggerKey)
                                   userInfo:nil
                                    repeats:YES];
}

//Selector for timer event on updating UI
- (void)refreshTagListing {
    if (reader.connectStatus==BUSY)
    {
        //update table
        [tagListing reloadData];
        
        //update inventory count
        txtTagCount.text=[NSString stringWithFormat: @"%ld", (long)[tagListing numberOfRowsInSection:0]];
        
        //update tag rate
        NSLog(@"Total Tag Count: %ld, time elapsed: %ld", ((long)reader.rangingTagCount), (long)[[NSDate date] timeIntervalSinceDate:tagRangingStartTime]);
        txtTagRate.text = [NSString stringWithFormat: @"%ld", ((long)reader.rangingTagCount) / (long)[[NSDate date] timeIntervalSinceDate:tagRangingStartTime]];
        
    }
}

//Selector for timer event on reading trigger key
- (void)readTriggerKey {
    
    static BOOL stoppedByKey=false;
    
    if (reader.connectStatus==CONNECTED)
    {
        BOOL keyState=false;
        if ([reader getTriggerKeyStatus:&keyState])
        {
            if (keyState) {
                [btnInventory sendActionsForControlEvents:UIControlEventTouchDown];
                stoppedByKey=TRUE;
            }
            else
            {   //this is the case where user releases the trigger key but not pressed the UI button.
                if ([[btnInventory currentTitle] isEqualToString:@"Stop Inventory"])
                {
                    [btnInventory sendActionsForControlEvents:UIControlEventTouchDown];
                    stoppedByKey=FALSE;
                }
            }
        }

    }
}
- (void)viewDidAppear:(BOOL)animated {

    //The application launches and scan reader for 5 seconds.  The reader list will continue the readers being detected within these 5 seconds.  If no reader found, the reader will return.
    if(reader.bleDeviceList.count==0) {
        //no device found.  Exit applicatinon
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CS108 Not Found!" message:@"Please ensure that your reader is turned on.  Application is now being closed." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {
                                 exit(0);
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Connect Button
/*
 This method is called when connect button pressed and it takes appropriate actions depending on device connection state
 */
- (IBAction)connectButtonPressed:(id)sender
{
    btnConnect.enabled=false;
    [self.view bringSubviewToFront:spinner];
    [spinner startAnimating];
 
    if ([btnConnect.currentTitle isEqualToString:@"Disconnect"])
    {
        [reader disconnectDevice];
        btnConnect.enabled=true;
        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        btnInventory.enabled=false;
        [spinner stopAnimating];
        reader.filteredBuffer=nil;
        [tagListing reloadData];
        return;
    }
    
    [reader stopScanDevice];
    
    [reader connectDevice:[reader.bleDeviceList objectAtIndex:[self.readerPicker selectedRowInComponent:0]]];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++)
        while((reader.connectStatus != CONNECTED) && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]);
    
    if (reader.connectStatus != CONNECTED) {
        NSLog(@"Failed to connect to reader.");
        return;
    }
    
    NSString * btFwVersion;
    NSString * slVersion;
    NSString * rfidBoardSn;
    NSString * rfidFwVersion;
    NSData* OEMData;
    
    //Configure reader
    [reader barcodeReader:true];
    [reader powerOnRfid:false];
    [reader powerOnRfid:true];
    [reader getBtFirmwareVersion:btFwVersion];
    [reader getSilLabIcVersion:slVersion];
    [reader getRfidBrdSerialNumber:rfidBoardSn];
    [reader sendAbortCommand];
    [reader getRfidFwVersionNumber:rfidFwVersion];
    
    //read OEM data
    [reader readOEMData:reader atAddr:0x00000002 forData:OEMData];
    [reader readOEMData:reader atAddr:0x00000008 forData:OEMData];
    [reader readOEMData:reader atAddr:0x0000008E forData:OEMData];
    [reader readOEMData:reader atAddr:0x0000008F forData:OEMData];
    [reader readOEMData:reader atAddr:0x0000009D forData:OEMData];
    [reader readOEMData:reader atAddr:0x000000A3 forData:OEMData];
    [reader readOEMData:reader atAddr:0x000000A4 forData:OEMData];
    [reader readOEMData:reader atAddr:0x00000004 forData:OEMData];
    [reader readOEMData:reader atAddr:0x00000005 forData:OEMData];
    [reader readOEMData:reader atAddr:0x00000006 forData:OEMData];
    [reader readOEMData:reader atAddr:0x00000007 forData:OEMData];
    [reader readOEMData:reader atAddr:0x000000A5 forData:OEMData];
    
    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    btnConnect.enabled=true;
    btnInventory.enabled=true;
    [spinner stopAnimating];
}

- (IBAction)startInventory:(id)sender
{
    if (reader.connectStatus==CONNECTED && [[btnInventory currentTitle] isEqualToString:@"Start Inventory"])
    {
        btnInventory.enabled=false;
        //reader configurations before inventory
        CSLBlePacket* packet= [[CSLBlePacket alloc] init];
        CSLBlePacket * recvPacket=[[CSLBlePacket alloc] init];
        
        //clear UI
        txtTagRate.text=@"0";
        txtTagCount.text=@"0";
        reader.filteredBuffer=nil;
        [tagListing reloadData];
    
        
        //set power
        [reader setPower:30.0];
        [reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
        
         
         //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
         unsigned int desc_idx=3;    //select algortihm #3 (Dyanmic Q)
         NSLog(@"----------------------------------------------------------------------");
         NSLog(@"Select which set of algorithm parameter registers to access (INV_SEL)...");
         NSLog(@"----------------------------------------------------------------------");
         
         unsigned char INV_SEL_3[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x09, desc_idx & 0x000000FF, (desc_idx & 0x0000FF00) >> 8, (desc_idx & 0x00FF0000) >> 16, (desc_idx & 0xFF000000) >> 24};
         packet.prefix=0xA7;
         packet.connection = Bluetooth;
         packet.payloadLength=0x0A;
         packet.deviceId=RFID;
         packet.Reserve=0x82;
         packet.direction=Downlink;
         packet.crc1=0;
         packet.crc2=0;
         packet.payload=[NSData dataWithBytes:INV_SEL_3 length:sizeof(INV_SEL_3)];
         
         NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
         [reader sendPackets:packet];
         
         while((!([reader.recvQueue count] > 0)) && (([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])));
         
         recvPacket=((CSLBlePacket *)[reader.recvQueue deqObject]);
         if (memcmp([recvPacket.payload bytes], INV_SEL_3, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
         NSLog(@"Select which set of algorithm parameter registers: OK");
         else
         NSLog(@"Select which set of algorithm parameter registers: FAILED");
         
         //Set algorithm parameters (INV_ALG_PARM_0) for DyanmicQ reg_addr = 0x0901
         Byte startQ=6, maxQ=15, minQ=0, tmult=4;
         NSLog(@"----------------------------------------------------------------------");
         NSLog(@"Set algorithm parameters (INV_ALG_PARM_0) for DyanmicQ...");
         NSLog(@"----------------------------------------------------------------------");
         
         unsigned char INV_ALG_PARM_3[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x09, (startQ & 0x0F) + ((maxQ & 0x0F) << 4), (minQ & 0x0F) + ((tmult & 0x0F) << 4), (tmult & 0xF0) >> 4, 0x00};
         packet.prefix=0xA7;
         packet.connection = Bluetooth;
         packet.payloadLength=0x0A;
         packet.deviceId=RFID;
         packet.Reserve=0x82;
         packet.direction=Downlink;
         packet.crc1=0;
         packet.crc2=0;
         packet.payload=[NSData dataWithBytes:INV_ALG_PARM_3 length:sizeof(INV_ALG_PARM_3)];
         
         NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
         [reader sendPackets:packet];
         
         while((!([reader.recvQueue count] > 0)) && (([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])));
         
         recvPacket=((CSLBlePacket *)[reader.recvQueue deqObject]);
         if (memcmp([recvPacket.payload bytes], INV_ALG_PARM_3, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
         NSLog(@"Set DynamicQ parameter: OK");
         else
         NSLog(@"Set DynamicQ parameter: FAILED");
         
         ////
         //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
         desc_idx=0;    //select algortihm #0 (Fixed Q)
         NSLog(@"----------------------------------------------------------------------");
         NSLog(@"Select which set of algorithm parameter registers to access (INV_SEL)...");
         NSLog(@"----------------------------------------------------------------------");
         
         unsigned char INV_SEL_0[] = {0x80, 0x02, 0x70, 0x01, 0x02, 0x09, desc_idx & 0x000000FF, (desc_idx & 0x0000FF00) >> 8, (desc_idx & 0x00FF0000) >> 16, (desc_idx & 0xFF000000) >> 24};
         packet.prefix=0xA7;
         packet.connection = Bluetooth;
         packet.payloadLength=0x0A;
         packet.deviceId=RFID;
         packet.Reserve=0x82;
         packet.direction=Downlink;
         packet.crc1=0;
         packet.crc2=0;
         packet.payload=[NSData dataWithBytes:INV_SEL_0 length:sizeof(INV_SEL_0)];
         
         NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
         [reader sendPackets:packet];
         
         while((!([reader.recvQueue count] > 0)) && (([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])));
         
         recvPacket=((CSLBlePacket *)[reader.recvQueue deqObject]);
         if (memcmp([recvPacket.payload bytes], INV_SEL_0, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
         NSLog(@"Select which set of algorithm parameter registers: OK");
         else
         NSLog(@"Select which set of algorithm parameter registers: FAILED");
         
         
         //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
         Byte FixedQ=6;
         NSLog(@"----------------------------------------------------------------------");
         NSLog(@"Set algorithm parameters (INV_ALG_PARM_0) for FixedQ...");
         NSLog(@"----------------------------------------------------------------------");
         
         unsigned char INV_ALG_PARM_0[] = {0x80, 0x02, 0x70, 0x01, 0x03, 0x09, FixedQ & 0x0000000F, 0x00, 0x00, 0x00};
         packet.prefix=0xA7;
         packet.connection = Bluetooth;
         packet.payloadLength=0x0A;
         packet.deviceId=RFID;
         packet.Reserve=0x82;
         packet.direction=Downlink;
         packet.crc1=0;
         packet.crc2=0;
         packet.payload=[NSData dataWithBytes:INV_ALG_PARM_0 length:sizeof(INV_ALG_PARM_0)];
         
         NSLog(@"BLE packet sending: %@", [packet getPacketInHexString]);
         [reader sendPackets:packet];
         
         while((!([reader.recvQueue count] > 0)) && (([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])));
         
         recvPacket=((CSLBlePacket *)[reader.recvQueue deqObject]);
         if (memcmp([recvPacket.payload bytes], INV_ALG_PARM_0, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
         NSLog(@"Set FixedQ parameter: OK");
         else
         NSLog(@"Set FixedQ parameter: FAILED");
         ////
         
         //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
         Byte Inv_algo=0x03, match_rep=0, tag_sel=0, disable_inv=0, tag_read=0, crc_err_read=1, QT_mode=0, tag_delay=0, inv_mode=1;  //inventory algorithm #3, enable crc error read, compact mode inventory
         NSLog(@"----------------------------------------------------------------------");
         NSLog(@"Set inventory configurations (INV_CFG)...");
         NSLog(@"----------------------------------------------------------------------");
         
         unsigned char INV_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x01, 0x09, (Inv_algo & 0x3F) + ((match_rep & 0x03) << 6), ((match_rep & 0xFC) >> 2) + ((tag_sel & 0x01) << 6) + ((disable_inv & 0x01) << 7), (tag_read & 0x03) + ((crc_err_read & 0x01) << 2) + ((QT_mode & 0x01) << 3) + ((tag_delay & 0x0F) << 4), ((tag_delay & 0x30) >> 4) + ((inv_mode & 0x01) << 2)};
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
         [reader sendPackets:packet];
         
         while((!([reader.recvQueue count] > 0)) && (([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])));
         
         recvPacket=((CSLBlePacket *)[reader.recvQueue deqObject]);
         if (memcmp([recvPacket.payload bytes], INV_CFG, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
         NSLog(@"Set inventory configurations: OK");
         else
         NSLog(@"Set inventory configurations: FAILED");
         
         //Select which set of algorithm parameter registers to access (INV_SEL) reg_addr = 0x0902
         Byte query_target=0x00, query_session=1, query_sel=0;
         NSLog(@"----------------------------------------------------------------------");
         NSLog(@"Configure parameters on query and inventory operations (QUERY_CFG)...");
         NSLog(@"----------------------------------------------------------------------");
         
         unsigned char QUERY_CFG[] = {0x80, 0x02, 0x70, 0x01, 0x00, 0x09, ((query_target & 0x01) << 4) + ((query_session & 0x03) << 5) + ((query_sel & 0x01) << 7), ((query_sel & 0x02) >> 1), 0x00, 0x00};
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
         [reader sendPackets:packet];
         
         while((!([reader.recvQueue count] > 0)) && (([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])));
         
         recvPacket=((CSLBlePacket *)[reader.recvQueue deqObject]);
         if (memcmp([recvPacket.payload bytes], QUERY_CFG, 2) == 0 && ((Byte *)[recvPacket.payload bytes])[2] == 0x00)
         NSLog(@"Configure parameters on query and inventory operations: OK");
         else
         NSLog(@"Configure parameters on query and inventory operations: FAILED");
    
        //start inventory
        tagRangingStartTime=[NSDate date];
        [reader startInventory];
        [btnInventory setTitle:@"Stop Inventory" forState:UIControlStateNormal];
        btnInventory.enabled=true;
        btnConnect.enabled=false;
    }
    else if ([[btnInventory currentTitle] isEqualToString:@"Stop Inventory"])
    {
        if([reader stopInventory])
        {
            [btnInventory setTitle:@"Start Inventory" forState:UIControlStateNormal];
            btnConnect.enabled=true;
            btnInventory.enabled=true;
        }
        else
        {
            [btnInventory setTitle:@"Stop Inventory" forState:UIControlStateNormal];
            btnConnect.enabled=true;
            btnInventory.enabled=true;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)[reader.bleDeviceList count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return ((CBPeripheral*)reader.bleDeviceList[row]).name;
}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    //[tagListing reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [reader.filteredBuffer count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* epc=((CSLBleTag*)[reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:epc];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:epc];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    cell.textLabel.text = [NSString stringWithFormat:@"%d | %@ | RSSI: %d", (int)(indexPath.row + 1), epc, (int)((CSLBleTag*)[reader.filteredBuffer objectAtIndex:indexPath.row]).rssi];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
@end
