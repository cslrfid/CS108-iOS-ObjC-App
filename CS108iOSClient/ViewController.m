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
}

//Selector for timer event on updating UI
- (void)refreshTagListing {
    if (reader.connectStatus==TAG_OPERATIONS)
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
        
        //clear UI
        txtTagRate.text=@"0";
        txtTagCount.text=@"0";
        reader.filteredBuffer=nil;
        [tagListing reloadData];
    
        
        //set power
        [reader setPower:30.0];
        [reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
        [reader setAntennaDwell:0];
        [reader setLinkProfile:2];
        [reader setQueryConfigurations:0 querySession:0 querySelect:0];
        [reader selectAlgorithmParameter:1];
        [reader setInventoryAlgorithmParameters0:6 maximumQ:15 minimumQ:0 ThresholdMultiplier:4];
        [reader setInventoryConfigurations:3 MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:0 crcErrorRead:1 QTMode:0 tagDelay:0 inventoryMode:1];
        
        
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

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (btnInventory.enabled)
        {
            if (state) {
                if ([[btnInventory currentTitle] isEqualToString:@"Start Inventory"])
                    [btnInventory sendActionsForControlEvents:UIControlEventTouchDown];
            }
            else {
                if ([[btnInventory currentTitle] isEqualToString:@"Stop Inventory"])
                    [btnInventory sendActionsForControlEvents:UIControlEventTouchDown];
            }
        }
    });
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
