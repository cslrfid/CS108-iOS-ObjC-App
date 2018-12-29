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
    LMGaugeView *gaugeView;
    NSDate* tagLastFoundTime;
}

@end

@implementation CSLTagSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = CGRectApplyAffineTransform(self.ivGauge.bounds, self.ivGauge.transform);
    gaugeView = [[LMGaugeView alloc] initWithFrame:frame];
    gaugeView.value = 0;
    gaugeView.maxValue=100;
    gaugeView.minValue=0;
    gaugeView.numOfDivisions=10;
    gaugeView.numOfSubDivisions=10;
    gaugeView.unitOfMeasurement=@"Signal";
    gaugeView.ringThickness=30;
    
    self.ivGauge.contentMode = UIViewContentModeCenter;
    [self.ivGauge addSubview:gaugeView];
    
    
    self.btnSearch.layer.borderWidth=1.0f;
    self.btnSearch.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController setTitle:@"Tag Search"];
    
    if (![[CSLRfidAppEngine sharedAppEngine].tagSelected isEqualToString:@""]) {
        self.txtEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
    }
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
    
    rollingAvgRssi = [[CSLCircularQueue alloc] initWithCapacity:ROLLING_AVG_COUNT];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    //stop inventory if it is still running
    if (self.btnSearch.enabled)
    {
        if ([[self.btnSearch currentTitle] isEqualToString:@"STOP"])
            [self.btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //remove delegate assignment so that trigger key will not triggered when out of this page
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = nil;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=nil;
    
    [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=false;
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
        
        self->gaugeView.value=[self->rollingAvgRssi calculateRollingAverage];
        if (self->gaugeView.value > (self->gaugeView.maxValue * 0.8))
            self->gaugeView.ringColor=UIColor.redColor;
        else
            self->gaugeView.ringColor=[UIColor colorWithRed:76.0/255 green:217.0/255 blue:100.0/255 alpha:1];
        
        NSLog(@"Tag Search with average RRSI = %f",self->gaugeView.value);
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
                if ([[self->_btnSearch currentTitle] isEqualToString:@"START"])
                    [self->_btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                if ([[self->_btnSearch currentTitle] isEqualToString:@"STOP"])
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

    BOOL result=true;
    rollingAvgRssi = [[CSLCircularQueue alloc] initWithCapacity:ROLLING_AVG_COUNT];
    
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==CONNECTED && [[self.btnSearch currentTitle] isEqualToString:@"START"])
    {
        gaugeView.value=0;
        tagLastFoundTime=nil;
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        self.btnSearch.enabled=false;
        //reader configurations before search

        //start tag search
        result=[[CSLRfidAppEngine sharedAppEngine].reader startTagSearch:EPC maskPointer:32 maskLength:((UInt32)[self.txtEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtEPC text]]];

        
        if (result) {
            [self.btnSearch setTitle:@"STOP" forState:UIControlStateNormal];
            self.btnSearch.enabled=true;
        }
    }
    else if ([[self.btnSearch currentTitle] isEqualToString:@"STOP"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        if([[CSLRfidAppEngine sharedAppEngine].reader stopTagSearch])
        {
            [self.btnSearch setTitle:@"START" forState:UIControlStateNormal];
            self.btnSearch.enabled=true;
        }
        else
        {
            [self.btnSearch setTitle:@"STOP" forState:UIControlStateNormal];
            self.btnSearch.enabled=true;
        }
    }
    
    
}
@end
