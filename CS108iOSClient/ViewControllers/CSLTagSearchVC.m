//
//  CSLTagSearchVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/12/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLTagSearchVC.h"

@interface CSLTagSearchVC () {
    CSLCircularQueue* rollingAvgRssi;
    NSDate* tagLastFoundTime;
    NSTimer* gaugeRefreshTimer;
}

@end

@implementation CSLTagSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //CGRect frame = CGRectApplyAffineTransform(self.gauageView.bounds, self.gauageView.transform);
    //gaugeView = [[LMGaugeView alloc] initWithFrame:frame];
    self.gaugeView.value = 0;
    self.gaugeView.maxValue=100;
    self.gaugeView.minValue=0;
    self.gaugeView.numOfDivisions=10;
    self.gaugeView.numOfSubDivisions=10;
    self.gaugeView.unitOfMeasurement=@"Signal";
    self.gaugeView.ringThickness=30;
    
    self.gaugeView.contentMode = UIViewContentModeCenter;
    //[self.gauageView addSubview:self.gaugeView];
    
    
    self.btnSearch.layer.borderWidth=1.0f;
    self.btnSearch.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnSearch.layer.cornerRadius=5.0f;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController setTitle:@"Tag Search"];
    
    [self.actSearchSpinner stopAnimating];
    self.view.userInteractionEnabled=true;
    
    if (![[CSLRfidAppEngine sharedAppEngine].tagSelected isEqualToString:@""]) {
        self.txtEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
    }
    
    [self.txtEPC setDelegate:self];
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
    
    rollingAvgRssi = [[CSLCircularQueue alloc] initWithCapacity:ROLLING_AVG_COUNT];
    
    // Do any additional setup after loading the view.
    [((CSLTabVC*)self.tabBarController) setAntennaPortsAndPowerForTags];
    [((CSLTabVC*)self.tabBarController) setConfigurationsForTags];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    //stop inventory if it is still running
    if (self.btnSearch.enabled)
    {
        if ([[self.btnSearch currentTitle] isEqualToString:@"Stop"])
            [self.btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //remove delegate assignment so that trigger key will not triggered when out of this page
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = nil;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=nil;
    
    [gaugeRefreshTimer invalidate];
    gaugeRefreshTimer=nil;
    
    [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=false;
}

//Selector for timer event on updating UI and sound effect
- (void)refreshGauge {
    @autoreleasepool {
        if ([self.gaugeView.ringColor isEqual:UIColor.redColor])
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:1052];
        else
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
        
        if ([[NSDate date] timeIntervalSinceDate:tagLastFoundTime] > 1.0) {
            //no tag found in the last 1 second.  Reset gauge
            [self->rollingAvgRssi removeAllObjects];
            self.gaugeView.value=0;
            
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (tag.rssi==0) {
            [self->rollingAvgRssi removeAllObjects];
        }
        else if ([self->rollingAvgRssi count] >= ROLLING_AVG_COUNT) {
            [self->rollingAvgRssi deqObject];
            [self->rollingAvgRssi enqObject:tag];
        }
        else {
            [self->rollingAvgRssi enqObject:tag];
        }
        
        self->_gaugeView.value=[self->rollingAvgRssi calculateRollingAverage];
        if (self->_gaugeView.value > (self->_gaugeView.maxValue * 0.8))
            self->_gaugeView.ringColor=UIColor.redColor;
        else
            self->_gaugeView.ringColor=[UIColor colorWithRed:76.0/255 green:217.0/255 blue:100.0/255 alpha:1];
        
        NSLog(@"Tag Search with average RRSI = %f",self->_gaugeView.value);
        self->tagLastFoundTime=[NSDate date];
    });
}
- (void) didReceiveTagAccessData:(CSLBleReader *)sender tagReceived:(CSLBleTag *)tag {

}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_btnSearch.enabled)
        {
            if (state) {
                if ([[self->_btnSearch currentTitle] isEqualToString:@"Start"])
                    [self->_btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                if ([[self->_btnSearch currentTitle] isEqualToString:@"Stop"])
                    [self->_btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    });
}

- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)btnSearchPressed:(id)sender {

    if ([self.txtEPC.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Tag Search" message:@"No EPC Selected" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    BOOL result=true;
    rollingAvgRssi = [[CSLCircularQueue alloc] initWithCapacity:ROLLING_AVG_COUNT];
    
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==CONNECTED && [[self.btnSearch currentTitle] isEqualToString:@"Start"])
    {
        
        //timer event on updating UI
        gaugeRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(refreshGauge)
                                                         userInfo:nil
                                                          repeats:YES];
        
        
        self.gaugeView.value=0;
        tagLastFoundTime=nil;
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        self.btnSearch.enabled=false;
        //reader configurations before search

        //start tag search
        [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
        result=[[CSLRfidAppEngine sharedAppEngine].reader startTagSearch:EPC maskPointer:32 maskLength:((UInt32)[self.txtEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtEPC text]]];

        
        if (result) {
            [self.btnSearch setTitle:@"Stop" forState:UIControlStateNormal];
            self.btnSearch.enabled=true;
        }
    }
    else if ([[self.btnSearch currentTitle] isEqualToString:@"Stop"])
    {
        [gaugeRefreshTimer invalidate];
        gaugeRefreshTimer=nil;
        
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        if([[CSLRfidAppEngine sharedAppEngine].reader stopTagSearch])
        {
            [self.btnSearch setTitle:@"Start" forState:UIControlStateNormal];
            self.btnSearch.enabled=true;
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        else
        {
            [self.btnSearch setTitle:@"Stop" forState:UIControlStateNormal];
            self.btnSearch.enabled=true;
        }
    }
    
    
}
@end
