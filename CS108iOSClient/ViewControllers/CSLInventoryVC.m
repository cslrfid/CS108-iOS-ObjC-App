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

- (NSString*)bankEnumToString:(MEMORYBANK)bank;

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
    
    btnInventory.layer.borderWidth=1.0f;
    btnInventory.layer.borderColor=[UIColor clearColor].CGColor;
    btnInventory.layer.cornerRadius=5.0f;
    
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
    
    tblTagList.estimatedRowHeight=45.0;
    tblTagList.rowHeight = UITableViewAutomaticDimension;
    
    // Do any additional setup after loading the view.
    //[((CSLTabVC*)self.tabBarController) setAntennaPortsAndPowerForTags];
    //[((CSLTabVC*)self.tabBarController) setConfigurationsForTags];
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
            
        if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
            if ([CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage < 0 || [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage > 100)
                self.lbStatus.text=@"Battery: -";
            else
                self.lbStatus.text=[NSString stringWithFormat:@"Battery: %d%%", [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage];
        }
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
    [[NSRunLoop mainRunLoop] addTimer:scrRefreshTimer forMode:NSRunLoopCommonModes];
    
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
        session.willQoS=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS;
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
    
    // Do any additional setup after loading the view.
    [((CSLTabVC*)self.tabBarController) setAntennaPortsAndPowerForTags];
    [((CSLTabVC*)self.tabBarController) setConfigurationsForTags];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.actInventorySpinner stopAnimating];
    self.view.userInteractionEnabled=true;
    
    //stop inventory if it is still running
    if (btnInventory.enabled)
    {
        if ([[btnInventory currentTitle] isEqualToString:@"Stop"])
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
    
    if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [[btnInventory currentTitle] isEqualToString:@"Start"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        
        [[CSLRfidAppEngine sharedAppEngine].reader startBarcodeReading];
        [btnInventory setTitle:@"Stop" forState:UIControlStateNormal];
        btnInventory.enabled=true;
        
    }
    else if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [[btnInventory currentTitle] isEqualToString:@"Stop"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        
        [[CSLRfidAppEngine sharedAppEngine].reader stopBarcodeReading];
        [btnInventory setTitle:@"Start" forState:UIControlStateNormal];
        btnInventory.enabled=true;
    }
    else if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==CONNECTED && [[btnInventory currentTitle] isEqualToString:@"Start"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        
        // Do any additional setup after loading the view.
        //[((CSLTabVC*)self.tabBarController) setConfigurationsForTags];

        //start inventory
        tagRangingStartTime=[NSDate date];
        [[CSLRfidAppEngine sharedAppEngine].reader startInventory];
        [btnInventory setTitle:@"Stop" forState:UIControlStateNormal];
        btnInventory.enabled=true;
    }
    else if ([[btnInventory currentTitle] isEqualToString:@"Stop"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        if([[CSLRfidAppEngine sharedAppEngine].reader stopInventory])
        {
            [btnInventory setTitle:@"Start" forState:UIControlStateNormal];
            btnInventory.enabled=true;
        }
        else
        {
            [btnInventory setTitle:@"Stop" forState:UIControlStateNormal];
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
                MQTTQosLevel level=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS;
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
                if ([[self->btnInventory currentTitle] isEqualToString:@"Start"])
                    [self->btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                if ([[self->btnInventory currentTitle] isEqualToString:@"Stop"])
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
    
    CSLTagListCell * cell;
    //for rfid data
    if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLBleTag class]]) {
        
        NSString* epc=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
        NSString* data1=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).DATA1;
        NSString* data1bank=[self bankEnumToString:[CSLRfidAppEngine sharedAppEngine].settings.multibank1];
        NSString* data2=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).DATA2;
        NSString* data2bank=[self bankEnumToString:[CSLRfidAppEngine sharedAppEngine].settings.multibank2];
        int rssi=(int)((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).rssi;
        int portNumber=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).portNumber;
        
        cell=[tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"CSLTagListCell" bundle:nil] forCellReuseIdentifier:@"TagCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        }
              
        if (data1 != NULL && data2 != NULL ) {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), epc];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\n%@=%@\nRSSI: %d | Port: %d", data1bank, data1, data2bank, data2, rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\n%@=%@\nRSSI: %d", data1bank, data1, data2bank, data2, rssi];
        }
        else if (data1 != NULL) {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), epc];
            cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d", data1bank, data1, rssi];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d | Port: %d", data1bank, data1, rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d", data1bank, data1, rssi];
        }
        else {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), epc];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"RSSI: %d | Port: %d", rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"RSSI: %d", rssi];
            
        }
    }
    //for barcode data
    else if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLReaderBarcode class]]) {
        NSString* bc=((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).barcodeValue;

        cell=[tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"CSLTagListCell" bundle:nil] forCellReuseIdentifier:@"TagCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        }

        cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), bc];
        cell.lbCellBank.text= [NSString stringWithFormat:@"[%@]", ((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).codeId];
        
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


