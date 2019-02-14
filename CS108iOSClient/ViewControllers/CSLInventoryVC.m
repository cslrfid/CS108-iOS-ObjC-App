//
//  CSLInventoryVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLInventoryVC.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CSLInventoryVC ()
{
    NSTimer * scrRefreshTimer;
    UISwipeGestureRecognizer* swipeGestureRecognizer;
    UIImageView *tempImageView;
    MQTTCFSocketTransport *transport;
    MQTTSession* session;
    BOOL isMQTTConnected;
}
@end

@implementation CSLInventoryVC

@synthesize btnInventory;
@synthesize lbTagRate;
@synthesize lbUniqueTagRate;
@synthesize lbTagCount;
@synthesize tblTagList;
@synthesize lbStatus;
@synthesize lbClear;
@synthesize lbMode;
@synthesize uivSendTagData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBarController setTitle:@"Inventory"];
    
    tblTagList.layer.borderWidth=1.0f;
    tblTagList.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    btnInventory.layer.borderWidth=1.0f;
    btnInventory.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleSwipes:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]
                              initWithTarget:self
                              action:@selector(handleSwipes:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    tblTagList.estimatedRowHeight=44.0;
    tblTagList.rowHeight = UITableViewAutomaticDimension;
}

- (void)handleSwipes:(UISwipeGestureRecognizer*)gestureRecognizer {
    @autoreleasepool {
        
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
            return;
        
        if ([[tempImageView accessibilityIdentifier] containsString:@"tagList-bg-rfid-swipe"]) {
            tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagList-bg-barcode-swipe"]];
            [tempImageView setAccessibilityIdentifier:@"tagList-bg-barcode-swipe"];
            [tempImageView setFrame:self.tblTagList.frame];
            self.tblTagList.backgroundView = tempImageView;
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:kSystemSoundID_Vibrate];
            [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=true;
            lbMode.text=@"Mode: BC";
            [lbClear sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else {
            tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagList-bg-rfid-swipe"]];
            [tempImageView setAccessibilityIdentifier:@"tagList-bg-rfid-swipe"];
            [tempImageView setFrame:self.tblTagList.frame];
            self.tblTagList.backgroundView = tempImageView;
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:kSystemSoundID_Vibrate];
            [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=false;
            lbMode.text=@"Mode: RFID";
            [lbClear sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

//Selector for timer event on updating UI
- (void)refreshTagListing {
    @autoreleasepool {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
        {
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
            //update table
            [tblTagList reloadData];
            
            //update inventory count
            lbTagCount.text=[NSString stringWithFormat: @"%ld", (long)[tblTagList numberOfRowsInSection:0]];
            
            //update tag rate
            NSLog(@"Total Tag Count: %ld, Unique Tag Coun t: %ld, time elapsed: %ld", ((long)[CSLRfidAppEngine sharedAppEngine].reader.rangingTagCount), ((long)[CSLRfidAppEngine sharedAppEngine].reader.uniqueTagCount), (long)[[NSDate date] timeIntervalSinceDate:tagRangingStartTime]);
            lbTagRate.text = [NSString stringWithFormat: @"%ld", ((long)[CSLRfidAppEngine sharedAppEngine].reader.rangingTagCount)];
            lbUniqueTagRate.text = [NSString stringWithFormat: @"%ld", ((long)[CSLRfidAppEngine sharedAppEngine].reader.uniqueTagCount)];
            [CSLRfidAppEngine sharedAppEngine].reader.rangingTagCount =0;
            [CSLRfidAppEngine sharedAppEngine].reader.uniqueTagCount =0;
            
        }
        else if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode) {
            //update table
            [tblTagList reloadData];
        }
            

        if ([CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage < 0 || [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage > 100)
            self.lbStatus.text=@"Battery: -";
        else
            self.lbStatus.text=[NSString stringWithFormat:@"Battery: %d%%", [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage];
        
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController setTitle:@"Inventory"];
    
    //clear UI
    lbTagRate.text=@"0";
    lbTagCount.text=@"0";
    [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
    
    tblTagList.dataSource=self;
    tblTagList.delegate=self;
    tblTagList.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTagList.bounds.size.width, 0.01f)];
    [tblTagList reloadData];
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
    
    tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagList-bg-rfid-swipe"]];
    [tempImageView setAccessibilityIdentifier:@"tagList-bg-rfid-swipe"];
    [tempImageView setFrame:self.tblTagList.frame];
    self.tblTagList.backgroundView = tempImageView;
    
    //timer event on updating UI
    scrRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(refreshTagListing)
                                                     userInfo:nil
                                                      repeats:YES];
    
    if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled) {
        transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerAddress;
        transport.port = [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerPort;
        transport.tls = [CSLRfidAppEngine sharedAppEngine].MQTTSettings.isTLSEnabled;
        
        session = [[MQTTSession alloc] init];
        session.transport = transport;
        session.userName=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.userName;
        session.password=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.password;
        session.keepAliveInterval = 60;
        session.clientId=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.clientId;
        session.willFlag=true;
        session.willMsg=[@"offline" dataUsingEncoding:NSUTF8StringEncoding];
        session.willTopic=[NSString stringWithFormat:@"devices/%@/messages/events/", session.clientId];
        session.willQoS=([CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS) ? MQTTQosLevelAtLeastOnce : MQTTQosLevelAtMostOnce;
        session.willRetainFlag=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.retained;
        
        [self->uivSendTagData setHidden:false];
        
        [session connectWithConnectHandler:^(NSError *error) {
            if (error == nil) {
                NSLog(@"Connected to MQTT Broker");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MQTT broker" message:@"Connected" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                self->isMQTTConnected=true;
            }
            else {
                NSLog(@"Fail connecting to MQTT Broker");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MQTT broker" message:[NSString stringWithFormat:@"Error: %@", error.debugDescription] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                self->isMQTTConnected=false;
            }
        }];
    }
    else {
                [self->uivSendTagData setHidden:true];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    //stop inventory if it is still running
    if (btnInventory.enabled)
    {
        if ([[btnInventory currentTitle] isEqualToString:@"STOP"])
            [btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];

    }
    
    //remove delegate assignment so that trigger key will not triggered when out of this page
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = nil;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=nil;
    
    tblTagList.dataSource=nil;
    tblTagList.delegate=nil;
    
    [scrRefreshTimer invalidate];
    scrRefreshTimer=nil;
    
    [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=false;
    [self.view removeGestureRecognizer:swipeGestureRecognizer];
    
    [session disconnect];
    [transport close];
    session=nil;
    transport=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnInventoryPressed:(id)sender {
    
    if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [[btnInventory currentTitle] isEqualToString:@"START"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        
        /*
        //clear UI
        lbTagRate.text=@"0";
        lbTagCount.text=@"0";
        [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
        [tblTagList reloadData];
        */
        
        [[CSLRfidAppEngine sharedAppEngine].reader startBarcodeReading];
        [btnInventory setTitle:@"STOP" forState:UIControlStateNormal];
        btnInventory.enabled=true;
        
    }
    else if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [[btnInventory currentTitle] isEqualToString:@"STOP"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        
        [[CSLRfidAppEngine sharedAppEngine].reader stopBarcodeReading];
        [btnInventory setTitle:@"START" forState:UIControlStateNormal];
        btnInventory.enabled=true;
    }
    else if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==CONNECTED && [[btnInventory currentTitle] isEqualToString:@"START"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        //reader configurations before inventory
        
        /*
        //clear UI
        lbTagRate.text=@"0";
        lbTagCount.text=@"0";
        [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
        [tblTagList reloadData];
        */
        
        //set inventory configurations

        
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setLinkProfile:[CSLRfidAppEngine sharedAppEngine].settings.linkProfile];
        [[CSLRfidAppEngine sharedAppEngine].reader setQueryConfigurations:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? A : [CSLRfidAppEngine sharedAppEngine].settings.target) querySession:[CSLRfidAppEngine sharedAppEngine].settings.session querySelect:ALL];
        [[CSLRfidAppEngine sharedAppEngine].reader selectAlgorithmParameter:[CSLRfidAppEngine sharedAppEngine].settings.algorithm];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters0:[CSLRfidAppEngine sharedAppEngine].settings.QValue maximumQ:15 minimumQ:0 ThresholdMultiplier:4];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters1:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters2:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? true : false) RunTillZero:false];
        [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:0 crcErrorRead:1 QTMode:0 tagDelay:0 inventoryMode:1];
        
        
        //start inventory
        tagRangingStartTime=[NSDate date];
        [[CSLRfidAppEngine sharedAppEngine].reader startInventory];
        [btnInventory setTitle:@"STOP" forState:UIControlStateNormal];
        btnInventory.enabled=true;
    }
    else if ([[btnInventory currentTitle] isEqualToString:@"STOP"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        if([[CSLRfidAppEngine sharedAppEngine].reader stopInventory])
        {
            [btnInventory setTitle:@"START" forState:UIControlStateNormal];
            btnInventory.enabled=true;
        }
        else
        {
            [btnInventory setTitle:@"STOP" forState:UIControlStateNormal];
            btnInventory.enabled=true;
        }
    }
    
    
}

- (IBAction)btnClearTable:(id)sender {    
    //clear UI
    lbTagRate.text=@"0";
    lbTagCount.text=@"0";
    [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
    [tblTagList reloadData];
}

- (IBAction)btnSendTagData:(id)sender {
    //check MQTT settings.  Connect to broker and send tag data
    __block BOOL allTagPublishedSuccess=true;
    if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled && isMQTTConnected==true) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MQTT broker" message:@"Send Tag Data?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            for (CSLBleTag* tag in [CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer) {
                //build an info object and convert to json
                NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSUUID UUID] UUIDString],
                                      @"messageId",
                                      [NSString stringWithFormat:@"%d",tag.rssi],
                                      @"rssi",
                                      tag.EPC,
                                      @"EPC",
                                      nil];
                
                NSError * err;
                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&err];
                BOOL retain=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.retained;
                MQTTQosLevel level=([CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS) ? MQTTQosLevelAtLeastOnce : MQTTQosLevelAtMostOnce;
                NSString* topic=[NSString stringWithFormat:@"devices/%@/messages/events/", self->session.clientId];
                
                [self->session publishData:jsonData onTopic:topic retain:retain qos:level publishHandler:^(NSError *error) {
                    if (error != nil) {
                        NSLog(@"Failed sending EPC=%@ to MQTT broker. Error message: %@", tag.EPC, error.debugDescription);
                        allTagPublishedSuccess=false;
                    }
                }];
            }
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
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
        if (self->btnInventory.enabled)
        {
            if (state) {
                if ([[self->btnInventory currentTitle] isEqualToString:@"START"])
                    [self->btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                if ([[self->btnInventory currentTitle] isEqualToString:@"STOP"])
                    [self->btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell;
    //for rfid data
    if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLBleTag class]]) {
        NSString* epc=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
        cell=[tableView dequeueReusableCellWithIdentifier:epc];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:epc];
        }
        
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
        cell.textLabel.text = [NSString stringWithFormat:@"%5d \u25CF %@ \u25CF RSSI: %d", (int)(indexPath.row + 1), epc, (int)((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).rssi];
    }
    //for barcode data
    else if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLReaderBarcode class]]) {
        NSString* bc=((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).barcodeValue;
        cell=[tableView dequeueReusableCellWithIdentifier:bc];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bc];
        }
        
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
        cell.textLabel.text = [NSString stringWithFormat:@"%5d \u25CF %@ [%@]", (int)(indexPath.row + 1), bc, ((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).codeId];
    }
    else
        return nil;
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLBleTag class]])
        [CSLRfidAppEngine sharedAppEngine].tagSelected= ((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
    else if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLReaderBarcode class]])
        [CSLRfidAppEngine sharedAppEngine].tagSelected= ((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).barcodeValue;
    else
        [CSLRfidAppEngine sharedAppEngine].tagSelected=@"";
        
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tag Selected" message:[CSLRfidAppEngine sharedAppEngine].tagSelected  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


@end


