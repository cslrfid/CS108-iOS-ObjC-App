//
//  CSLTemperatureDetailsVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 4/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLTemperatureDetailsVC.h"

@interface CSLTemperatureDetailsVC ()

@end

@implementation CSLTemperatureDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBarController setTitle:@"Sensors Details"];
    
    self.btnTagStatus.layer.borderWidth=1.0f;
    self.btnTagStatus.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnTagStatus.layer.cornerRadius=5.0f;
    
    self.uivTemperatureDetails.layer.borderWidth=1.0f;
    self.uivTemperatureDetails.layer.borderColor=(UIColorFromRGB(0xAAAAAA)).CGColor;
    self.uivTemperatureDetails.layer.cornerRadius=5.0f;
    
    self.lbTemperature.text=@"";
    self.lbEPC.text=@"";
    self.lbTimestamp.text=@"";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController setTitle:@"Sensor Details"];
    
    if([CSLRfidAppEngine sharedAppEngine].CSLBleTagSelected != nil) {
        
        // Do any additional setup after loading the view.
        CSLBleTag* lastGoodRead=[[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer objectForKey:((CSLBleTag*)[CSLRfidAppEngine sharedAppEngine].CSLBleTagSelected).EPC];
        NSString* epc= lastGoodRead.EPC;
        NSString* data1=lastGoodRead.DATA1;
        NSString* data2=lastGoodRead.DATA2;
        
        //tag read timestamp
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/YY HH:mm:ss"];
        NSDate* date=lastGoodRead.timestamp;
        NSString *stringFromDate = [dateFormatter stringFromDate:date];
        
        double temperatureValue=[[[CSLRfidAppEngine sharedAppEngine].temperatureSettings getTemperatureValueAveraging:epc] doubleValue];
        
        if (temperatureValue > MIN_TEMP_VALUE && temperatureValue < MAX_TEMP_VALUE) {
            if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit == CELCIUS)
                self.lbTemperature.text=[NSString stringWithFormat:@"%3.1f\u00BA%@", temperatureValue, [CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit ? @"F" : @"C"];
            else
                self.lbTemperature.text=[NSString stringWithFormat:@"%3.1f\u00BA%@", [CSLTemperatureTagSettings convertCelciusToFahrenheit:temperatureValue], [CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit ? @"F" : @"C"];
                                         }
        else
            self.lbTemperature.text = @"  -  ";
        self.lbEPC.text=epc;
        self.lbTimestamp.text=stringFromDate;
        
        //temperature alert
        if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.isTemperatureAlertEnabled) {
            if (temperatureValue < [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit) {
                self.btnTagStatus.backgroundColor=UIColorFromRGB(0x74b9ff);
                [self.btnTagStatus setTitle:@"Low" forState:UIControlStateNormal];
            }
            else if (temperatureValue > [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit) {
                self.btnTagStatus.backgroundColor=UIColorFromRGB(0xd63031);
                [self.btnTagStatus setTitle:@"High" forState:UIControlStateNormal];
            }
            else {
                self.btnTagStatus.backgroundColor=UIColorFromRGB(0x26A65B);
                [self.btnTagStatus setTitle:@"Normal" forState:UIControlStateNormal];
            }
        }
        else {
            self.btnTagStatus.backgroundColor=UIColorFromRGB(0x26A65B);
            [self.btnTagStatus setTitle:@"Normal" forState:UIControlStateNormal];
        }
        
        if (data2.length >= 16)
            self.lbCalibration.text=[data2 substringToIndex:15];
        if (data1.length >= 12) {
            self.lbSensorCode.text=[data1 substringWithRange:NSMakeRange(0, 4)];
            self.lbOCRSSI.text=[data1 substringWithRange:NSMakeRange(4, 4)];
            self.lbTemperatureCode.text=[data1 substringWithRange:NSMakeRange(8, 4)];
        }
    }
    else {
        self.lbTemperature.text=@"  -  ";
        self.lbSensorCode.text=@"";
        self.lbOCRSSI.text=@"";
        self.lbTemperatureCode.text=@"";
        self.lbCalibration.text=@"";
        self.lbTimestamp.text=@"";
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {    
    [CSLRfidAppEngine sharedAppEngine].CSLBleTagSelected=nil;
}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
}
- (void) didReceiveTagAccessData: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {

}

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {

}

- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
