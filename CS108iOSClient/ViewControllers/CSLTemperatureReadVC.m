//
//  CSLTemperatureReadVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 28/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLTemperatureReadVC.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CSLTemperatureReadVC () {
    NSTimer* scrRefreshTimer;
    NSTimer* scrBeepTimer;
}

@end

@implementation CSLTemperatureReadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //pre-configure inventory
    //hardcode multibank inventory parameter for RFMicron tag reading (EPC+OCRSSI+TEMPERATURE)
    [CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled = true;
    [CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled = true;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank1=RESERVED;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset=12;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length=3;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank2=USER;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset=8;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length=4;
    
    //for multiplebank inventory
    Byte tagRead=0;
    if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled && [CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled)
        tagRead=2;
    else if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled)
        tagRead=1;
    else
        tagRead=0;
    
    [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:0];
    [[CSLRfidAppEngine sharedAppEngine].reader setQueryConfigurations:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? A : [CSLRfidAppEngine sharedAppEngine].settings.target) querySession:[CSLRfidAppEngine sharedAppEngine].settings.session querySelect:ALL];
    [[CSLRfidAppEngine sharedAppEngine].reader selectAlgorithmParameter:[CSLRfidAppEngine sharedAppEngine].settings.algorithm];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters0:[CSLRfidAppEngine sharedAppEngine].settings.QValue maximumQ:15 minimumQ:0 ThresholdMultiplier:4];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters1:5];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters2:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? true : false) RunTillZero:false];
    
    [[CSLRfidAppEngine sharedAppEngine].reader setLinkProfile:[CSLRfidAppEngine sharedAppEngine].settings.linkProfile];
    
    //multiple bank select
    unsigned char emptyByte[] = {0x00};
    unsigned char OCRSSI[] = {0x20};
    //[[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:0];
    [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:TID maskPointer:0 maskLength:28 maskData:[CSLBleReader convertHexStringToData:@"E2824030"] sel_action:0];
    [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:1];
    [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:USER maskPointer:0xE0 maskLength:0 maskData:[NSData dataWithBytes:emptyByte length:sizeof(emptyByte)] sel_action:1];
    [[CSLRfidAppEngine sharedAppEngine].reader TAGMSK_DESC_SEL:2];
    [[CSLRfidAppEngine sharedAppEngine].reader selectTagForInventory:USER maskPointer:0xD0 maskLength:8 maskData:[NSData dataWithBytes:OCRSSI length:sizeof(OCRSSI)] sel_action:2];
    
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:tagRead crcErrorRead:(tagRead ? 0 : 1) QTMode:0 tagDelay:(tagRead ? 30 : 0) inventoryMode:(tagRead ? 0 : 1)];
    
    // if multibank read is enabled
    if (tagRead) {
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_BANK:[CSLRfidAppEngine sharedAppEngine].settings.multibank1 acc_bank2:[CSLRfidAppEngine sharedAppEngine].settings.multibank2];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_PTR:([CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset << 16) + [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_CNT:(tagRead ? [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length : 0) secondBank:(tagRead==2 ? [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length : 0)];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:1 disableInventory:0 tagRead:tagRead crcErrorRead:(tagRead ? 0 : 1) QTMode:0 tagDelay:(tagRead ? 30 : 0) inventoryMode:(tagRead ? 0 : 1)];
    }
    
    //initialize averaging buffer
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAveragingBuffer = [[NSMutableDictionary alloc] init];
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer = [[NSMutableDictionary alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController setTitle:@"Read Sensors"];
    
    if ((self.tblTagList.dataSource==nil) && (self.tblTagList.delegate==nil)) {
        //clear UI
        //self.lbTagCount.text=@"0";
        //[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
        
        self.tblTagList.dataSource=self;
        self.tblTagList.delegate=self;
        self.tblTagList.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTagList.bounds.size.width, 0.01f)];
        [self.tblTagList reloadData];
        
        [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
        [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
        
    }
    else {
        //refresh table
        [self.tblTagList reloadData];
    }
    
    //timer event on updating UI
    scrRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                       target:self
                                                     selector:@selector(refreshTagListing)
                                                     userInfo:nil
                                                      repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:scrRefreshTimer forMode:NSRunLoopCommonModes];
    
    scrBeepTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(playBeepDuringInventory)
                                                     userInfo:nil
                                                      repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:scrBeepTimer forMode:NSRunLoopCommonModes];
    
    [self.tblTagList setEditing:true animated:true];
    self.tblTagList.backgroundView = nil;
    self.tblTagList.backgroundColor = [UIColor whiteColor];

    
}
- (void)viewDidAppear:(BOOL)animated {
    

    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Selector for timer event on updating UI
- (void)refreshTagListing {
    @autoreleasepool {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
        {
            //[[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
            //update table
            [self.tblTagList reloadData];
            
            //update inventory count
            self.lbTagCount.text=[NSString stringWithFormat: @"%ld", (long)[self.tblTagList numberOfRowsInSection:0]];
            
        }
        else if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode) {
            //update table
            [self.tblTagList reloadData];
        }
        
        
        if ([CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage < 0 || [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage > 100)
            self.lbBatteryLevel.text=@"-";
        else
            self.lbBatteryLevel.text=[NSString stringWithFormat:@"%d%%", [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage];
        
    }
}
//Selector for timer event on please
- (void)playBeepDuringInventory {
    @autoreleasepool {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
        {
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //stop inventory if it is still running
    if (self.btnInventory.enabled)
    {
        if ([self.lbInventory.text isEqualToString:@"Stop"])
            [self.btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    
    [scrRefreshTimer invalidate];
    scrRefreshTimer=nil;
    [scrBeepTimer invalidate];
    scrBeepTimer=nil;
    
    [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=false;

}

- (IBAction)btnInventoryPressed:(id)sender {
    
    if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [self.lbInventory.text isEqualToString:@"Start"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        self.btnInventory.enabled=false;
        
        [[CSLRfidAppEngine sharedAppEngine].reader startBarcodeReading];
        [self.btnInventory setImage:[UIImage imageNamed:@"Stop-icon.png"] forState:UIControlStateNormal];
        self.lbInventory.text=@"Stop";
        self.btnInventory.enabled=true;
    }
    else if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [self.lbInventory.text isEqualToString:@"Stop"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        self.btnInventory.enabled=false;
        
        [[CSLRfidAppEngine sharedAppEngine].reader stopBarcodeReading];
        [self.btnInventory setImage:[UIImage imageNamed:@"Start-icon.png"] forState:UIControlStateNormal];
        self.lbInventory.text=@"Start";
        self.btnInventory.enabled=true;
    }
    else if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==CONNECTED && [self.lbInventory.text isEqualToString:@"Start"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        self.btnInventory.enabled=false;
        
        //start inventory
        [[CSLRfidAppEngine sharedAppEngine].reader startInventory];
        [self.btnInventory setImage:[UIImage imageNamed:@"Stop-icon.png"] forState:UIControlStateNormal];
        self.lbInventory.text=@"Stop";
        self.btnInventory.enabled=true;
        self.btnRemoveAllTag.enabled=false;
        self.btnSelectAllTag.enabled=false;
    }
    else if ([self.lbInventory.text isEqualToString:@"Stop"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        if([[CSLRfidAppEngine sharedAppEngine].reader stopInventory])
        {
            [self.btnInventory setImage:[UIImage imageNamed:@"Start-icon.png"] forState:UIControlStateNormal];
            self.lbInventory.text=@"Start";
            self.btnInventory.enabled=true;
            
            @synchronized ([CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer) {

                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                
                //refresh tag list to the latest after stopping inventory
                [self.tblTagList reloadData];
                self.lbTagCount.text=[NSString stringWithFormat: @"%ld", (long)[self.tblTagList numberOfRowsInSection:0]];
                
                //remove tags that are out of rssi range
                for (int i=0;i<[self.tblTagList numberOfRowsInSection:0];i++) {
                    if (((CSLTemperatureTagListCell*)[self.tblTagList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]).viTemperatureCell.layer.opacity != 1.0) {
                        [indexSet addIndex:[[NSIndexPath indexPathForRow:i inSection:0] row]];
                        [[CSLRfidAppEngine sharedAppEngine].temperatureSettings removeTemperatureAverageForEpc:((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:i]).EPC];
                        [[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer removeObjectForKey:((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:i]).EPC];
                    }
                }
                
                if (indexSet.count>0) {
                    //remove rows that are selected
                    [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeObjectsAtIndexes:indexSet];
                    //update inventory count
                    [self.tblTagList reloadData];
                    self.lbTagCount.text=[NSString stringWithFormat: @"%ld", (long)[self.tblTagList numberOfRowsInSection:0]];
                }
                
            }
            self.btnRemoveAllTag.enabled=true;
            self.btnSelectAllTag.enabled=true;
            
        }
        else
        {
            [self.btnInventory setImage:[UIImage imageNamed:@"Stop-icon.png"] forState:UIControlStateNormal];
            self.lbInventory.text=@"Stop";
            self.btnInventory.enabled=true;
        }
    }
    
    
}

- (IBAction)btnSelectAllTagPressed:(id)sender {
    int totalRows=(int)[self.tblTagList numberOfRowsInSection:0];
    
    //check if all rows are selected
    if([self.tblTagList indexPathsForSelectedRows].count==totalRows) {
        for (int row=0;row<totalRows;row++) {
            [self.tblTagList deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:false];
            [self.btnSelectAllTag setImage:[UIImage imageNamed:@"Check-icon.png"] forState:UIControlStateNormal];
        }
    }
    else {
        for (int row=0;row<totalRows;row++) {
            [self.tblTagList selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
        }
        [self.btnSelectAllTag setImage:[UIImage imageNamed:@"Clear-icon.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnRemoveAllTagPressed:(id)sender {
    
    NSArray *indexPathForSelectedRows = [self.tblTagList indexPathsForSelectedRows];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for(int i=0;i<indexPathForSelectedRows.count;i++) {
        [indexSet addIndex:[indexPathForSelectedRows[i] row]];
        [[CSLRfidAppEngine sharedAppEngine].temperatureSettings removeTemperatureAverageForEpc:((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:[indexPathForSelectedRows[i] row]]).EPC];
        [[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer removeObjectForKey:((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:[indexPathForSelectedRows[i] row]]).EPC];
    }
    if (indexSet.count>0) {
        //remove rows that are selected
        [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeObjectsAtIndexes:indexSet];
        //update inventory count
        [self.tblTagList reloadData];
        self.lbTagCount.text=[NSString stringWithFormat: @"%ld", (long)[self.tblTagList numberOfRowsInSection:0]];
        [self.btnSelectAllTag setImage:[UIImage imageNamed:@"Check-icon.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)uivInventoryPressed:(id)sender {
    [self.btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
    
}

- (IBAction)uivRemoveAllTagPressed:(id)sender {
        [self.btnRemoveAllTag sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)uivSelectAllTagPressed:(id)sender {
        [self.btnSelectAllTag sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    //[tagListing reloadData];
}
- (void) didReceiveTagAccessData: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    //no used
}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_btnInventory.enabled)
        {
            if (state) {
                if ([self->_lbInventory.text isEqualToString:@"Start"])
                    [self->_btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                if ([self->_lbInventory.text isEqualToString:@"Stop"])
                    [self->_btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    });
}


- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {
    [[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count];
}

- (void)buttonForDetailsClicked:(UIButton*)sender {
    //ignore details button click if inventory is running
    if ([self.lbInventory.text isEqualToString:@"Start"] && self.btnInventory.enabled)
    {
        [scrRefreshTimer invalidate];
        scrRefreshTimer=nil;
        [scrBeepTimer invalidate];
        scrBeepTimer=nil;
        [CSLRfidAppEngine sharedAppEngine].reader.delegate = nil;
        [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=nil;
        
        [CSLRfidAppEngine sharedAppEngine].tagSelected = ((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:sender.tag]).EPC;
        [CSLRfidAppEngine sharedAppEngine].CSLBleTagSelected = ((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:sender.tag]);
        [((CSLTemperatureTabVC*)self.tabBarController) tabBarController:((CSLTemperatureTabVC*)self.tabBarController) shouldSelectViewController:[[((CSLTemperatureTabVC*)self.tabBarController) viewControllers] objectAtIndex:CSL_VC_TEMPTAB_DETAILS_VC_IDX]];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CSLTemperatureTagListCell * cell;

    @synchronized ([CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer) {
        if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLBleTag class]]) {
            
            UInt32 ocrssi = 0;
            NSScanner *scanner;
            double temperatureValue = 0.0;
            int rssi;
            
            CSLBleTag* currentBleTag=(CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row];
            NSString* epc=currentBleTag.EPC;
            NSString* data1=currentBleTag.DATA1;
            NSString* data2=currentBleTag.DATA2;
            rssi=(int)currentBleTag.rssi;
            
            cell=[tableView dequeueReusableCellWithIdentifier:@"TemperatureTagCell"];
            if (cell == nil) {
                [tableView registerNib:[UINib nibWithNibName:@"CSLTemperatureTagListCell" bundle:nil] forCellReuseIdentifier:@"TemperatureTagCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"TemperatureTagCell"];
            }
            
            temperatureValue=[CSLTemperatureTagListCell calculateCalibratedTemperatureValue:[data1 substringWithRange:NSMakeRange(8, 4)] calibration:data2];
            
            //grey out tag from list if it is outside the on-chip rssi limits
            scanner = [NSScanner scannerWithString:[data1 substringWithRange:NSMakeRange(4, 4)]];
            [scanner scanHexInt:&ocrssi];
            ocrssi &= 0x0000001F;
            if (ocrssi >= [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiLowerLimit &&  //when the last read packet in the buffer is with ocrssi limits
                ocrssi <= [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiUpperLimit &&
                currentBleTag != [[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer objectForKey:epc] &&    //avoid decoding packet being processed before
                (temperatureValue > MIN_TEMP_VALUE && temperatureValue < MAX_TEMP_VALUE)) {         //filter out invalid packets that are out of temperature range on spec
                [[CSLRfidAppEngine sharedAppEngine].temperatureSettings setTemperatureValueForAveraging:[NSNumber numberWithDouble:temperatureValue] EPCID:epc];
                [[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer setObject:currentBleTag forKey:epc];
            }

            NSNumber* average=[[CSLRfidAppEngine sharedAppEngine].temperatureSettings getTemperatureValueAveraging:epc];
            if (average != nil) {
                cell.viTemperatureCell.layer.opacity=1.0;
                if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit == CELCIUS)
                    cell.lbTemperature.text = [NSString stringWithFormat:@"%3.1f\u00BA", [average doubleValue]];
                else
                    cell.lbTemperature.text = [NSString stringWithFormat:@"%3.1f\u00BA", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[average doubleValue]]];
            }
            else {
                cell.viTemperatureCell.layer.opacity=0.5;
                [cell spinTemperatureValueIndicator];
            }
            
            //tag read timestamp
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSDate* date;
            NSString *stringFromDate;
            [dateFormatter setDateFormat:@"dd/MM/YY HH:mm:ss"];
            if ([[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer objectForKey:currentBleTag.EPC]) {
                date=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer objectForKey:currentBleTag.EPC]).timestamp;
                stringFromDate = [dateFormatter stringFromDate:date];
            }
            else
                stringFromDate=@"";
            
            cell.lbEPC.text = [NSString stringWithFormat:@"%@", epc];
            cell.lbRssi.text= [NSString stringWithFormat:@"%3d", rssi > 100 ? 100 : rssi];
            cell.lbDate.text=stringFromDate;
            
            //temperature alert
            cell.lbTagStatus.layer.borderWidth=1.0f;
            cell.lbTagStatus.layer.cornerRadius=5.0f;
            cell.lbTagStatus.layer.borderColor=[UIColor clearColor].CGColor;
            //if temperature is not valid, hide temperature alert.
            if ([cell.lbTemperature.text isEqualToString:@"  -  "] ||
                [cell.lbTemperature.text isEqualToString:@"  \\  "] ||
                [cell.lbTemperature.text isEqualToString:@"  |  "] ||
                [cell.lbTemperature.text isEqualToString:@"  /  "] ) {
                cell.lbTagStatus.layer.opacity=0.0;
            }
            else
                cell.lbTagStatus.layer.opacity=1.0;
            
            if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.isTemperatureAlertEnabled && average != nil) {
                if ([average doubleValue] < [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit) {
                    cell.lbTagStatus.backgroundColor=UIColorFromRGB(0x74b9ff);
                    [cell.lbTagStatus setTitle:@"Low" forState:UIControlStateNormal];
                }
                else if ([average doubleValue] > [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit) {
                    cell.lbTagStatus.backgroundColor=UIColorFromRGB(0xd63031);
                    [cell.lbTagStatus setTitle:@"High" forState:UIControlStateNormal];
                }
                else {
                    cell.lbTagStatus.backgroundColor=UIColorFromRGB(0x26A65B);
                    [cell.lbTagStatus setTitle:@"Normal" forState:UIControlStateNormal];
                }
            }
            else {
                cell.lbTagStatus.backgroundColor=UIColorFromRGB(0x26A65B);
                [cell.lbTagStatus setTitle:@"Normal" forState:UIControlStateNormal];
            }
            
            cell.accessory.tag = indexPath.row;
            [cell.accessory addTarget:self action:@selector(buttonForDetailsClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.viewAccessory.tag = indexPath.row;
            [((UIButton*)cell.viewAccessory) addTarget:self action:@selector(buttonForDetailsClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
            return nil;
    }
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    int totalRows=(int)[self.tblTagList numberOfRowsInSection:0];
    //check if all rows are selected
    if([self.tblTagList indexPathsForSelectedRows].count==totalRows) {
        [self.btnSelectAllTag setImage:[UIImage imageNamed:@"Clear-icon.png"] forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    int totalRows=(int)[self.tblTagList numberOfRowsInSection:0];
    //check if all rows are selected
    if([self.tblTagList indexPathsForSelectedRows].count!=totalRows) {
        [self.btnSelectAllTag setImage:[UIImage imageNamed:@"Check-icon.png"] forState:UIControlStateNormal];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 3;
}

- (NSString*)bankEnumToString:(MEMORYBANK)bank {
    NSString *result = nil;
    
    switch(bank) {
        case RESERVED:
            result = @"RESERVED";
            break;
        case EPC:
            result = @"EPC";
            break;
        case TID:
            result = @"TID";
            break;
        case USER:
            result = @"USER";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}


@end
