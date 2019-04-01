//
//  CSLTemperatureTagSettingsVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 14/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLTemperatureTagSettingsVC.h"

@interface CSLTemperatureTagSettingsVC ()

@end

@implementation CSLTemperatureTagSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnSave.layer.borderWidth=1.0f;
    self.btnSave.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnSave.layer.cornerRadius=5.0f;
    
    [self.txtOcrssiMax setDelegate:self];
    [self.txtOcrssiMin setDelegate:self];
    [self.txtLowTemperatureThreshold setDelegate:self];
    [self.txtHighTemperatureThreshold setDelegate:self];
    [self.txtNumberOfTemperatureAveraging setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.tabBarController setTitle:@"Settings"];
    
    //reload previously stored settings
    [[CSLRfidAppEngine sharedAppEngine] reloadSettingsFromUserDefaults];
    
    //refresh UI with stored values
    [self.swEnableTemperatureAlert setOn:[CSLRfidAppEngine sharedAppEngine].temperatureSettings.isTemperatureAlertEnabled];
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit == CELCIUS) {
        self.txtHighTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit];
        self.txtLowTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit];
    }
    else {
        self.txtHighTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit]];
        self.txtLowTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit]];
    }
    self.txtOcrssiMax.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiUpperLimit];
    self.txtOcrssiMin.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiLowerLimit];
    self.txtNumberOfTemperatureAveraging.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.NumberOfRollingAvergage];
    ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit) ? (self.scTemperatureUnit.selectedSegmentIndex = 1) : (self.scTemperatureUnit.selectedSegmentIndex = 0);
    
    [self.scTemperatureUnit addTarget:self action:@selector(SegmentChangeViewValueChanged:) forControlEvents:UIControlEventValueChanged];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSavePressed:(id)sender {
    //store the UI input to the settings object on appEng
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.isTemperatureAlertEnabled=self.swEnableTemperatureAlert.isOn;
    if (self.scTemperatureUnit.selectedSegmentIndex == CELCIUS) {
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit=[self.txtHighTemperatureThreshold.text doubleValue];
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit=[self.txtLowTemperatureThreshold.text doubleValue];
    }
    else {
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit=[CSLTemperatureTagSettings convertFahrenheitToCelcius:[self.txtHighTemperatureThreshold.text doubleValue]];
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit=[CSLTemperatureTagSettings convertFahrenheitToCelcius:[self.txtLowTemperatureThreshold.text doubleValue]];
    }
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiUpperLimit=[self.txtOcrssiMax.text intValue];
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiLowerLimit=[self.txtOcrssiMin.text intValue];
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.NumberOfRollingAvergage=[self.txtNumberOfTemperatureAveraging.text intValue];
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit=(TEMPERATUREUNIT)self.scTemperatureUnit.selectedSegmentIndex;
    
    [[CSLRfidAppEngine sharedAppEngine] saveTemperatureTagSettingsToUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Settings" message:@"Settings saved." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)txtLowTemperatureThresholdChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtLowTemperatureThreshold.text];
    double val;
    double lowLimit, highLimit;
    if (self.scTemperatureUnit.selectedSegmentIndex == CELCIUS) {
        lowLimit=MIN_TEMP_VALUE;
        highLimit=MAX_TEMP_VALUE;
    }
    else {
        lowLimit=[CSLTemperatureTagSettings convertCelciusToFahrenheit:MIN_TEMP_VALUE];
        highLimit=[CSLTemperatureTagSettings convertCelciusToFahrenheit:MAX_TEMP_VALUE];;
    }
    if ([scan scanDouble:&val] && [scan isAtEnd] && [self.txtLowTemperatureThreshold.text doubleValue] >= lowLimit && [self.txtLowTemperatureThreshold.text doubleValue] <= highLimit)
    {
        NSLog(@"Low temperature threshold entered: OK");
        self.txtLowTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", val];
    }
    else {   //invalid input.  reset to stored configurations
        if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit == CELCIUS) {
            self.txtLowTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit];
        }
        else {
            self.txtLowTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertLowerLimit]];
        }
    }
}

- (IBAction)txtHighTemperatureThresholdChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtHighTemperatureThreshold.text];
    double val;
    double lowLimit, highLimit;
    if (self.scTemperatureUnit.selectedSegmentIndex == CELCIUS) {
        lowLimit=MIN_TEMP_VALUE;
        highLimit=MAX_TEMP_VALUE;
    }
    else {
        lowLimit=[CSLTemperatureTagSettings convertCelciusToFahrenheit:MIN_TEMP_VALUE];
        highLimit=[CSLTemperatureTagSettings convertCelciusToFahrenheit:MAX_TEMP_VALUE];;
    }
    if ([scan scanDouble:&val] && [scan isAtEnd] && [self.txtHighTemperatureThreshold.text doubleValue] >= lowLimit && [self.txtHighTemperatureThreshold.text doubleValue] <= highLimit)
    {
        NSLog(@"High temperature threshold entered: OK");
        self.txtHighTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", val];
    }
    else {   //invalid input.  reset to stored configurations
        if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit == CELCIUS) {
            self.txtHighTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit];
        }
        else {
            self.txtHighTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[CSLRfidAppEngine sharedAppEngine].temperatureSettings.temperatureAlertUpperLimit]];
        }
    }
}

- (IBAction)txtOcrssiMinChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtOcrssiMin.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtOcrssiMin.text intValue] >= 0 && [self.txtOcrssiMin.text intValue] <= 15) //valid int between 0 to 15
    {
        NSLog(@"On-chip RSSI low value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtOcrssiMin.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiLowerLimit];
}

- (IBAction)txtOcrssiMaxChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtOcrssiMax.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtOcrssiMax.text intValue] >= 0 && [self.txtOcrssiMax.text intValue] <= 15) //valid int between 0 to 15
    {
        NSLog(@"On-chip RSSI high value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtOcrssiMax.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiUpperLimit];
}

- (IBAction)txtNumberOfTemperatureAveragingChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtNumberOfTemperatureAveraging.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtNumberOfTemperatureAveraging.text intValue] >= 0 && [self.txtNumberOfTemperatureAveraging.text intValue] <= 10) //valid int between 0 to 10
    {
        NSLog(@"Temperature averaging value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtNumberOfTemperatureAveraging.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.NumberOfRollingAvergage];
}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {

}
- (void) didReceiveTagAccessData: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {

}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {
    
}


- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {

}

-(IBAction)SegmentChangeViewValueChanged:(UISegmentedControl *)SControl
{
    if (self.scTemperatureUnit.selectedSegmentIndex==CELCIUS) {
        self.txtLowTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertFahrenheitToCelcius:[self.txtLowTemperatureThreshold.text doubleValue]]];
        self.txtHighTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertFahrenheitToCelcius:[self.txtHighTemperatureThreshold.text doubleValue]]];
    }
    else {
        self.txtLowTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[self.txtLowTemperatureThreshold.text doubleValue]]];
        self.txtHighTemperatureThreshold.text=[NSString stringWithFormat:@"%3.1f", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[self.txtHighTemperatureThreshold.text doubleValue]]];
    }
   
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
