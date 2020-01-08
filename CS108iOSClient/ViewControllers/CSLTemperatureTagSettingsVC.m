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
    [self.txtMoistureValue setDelegate:self];
    
    self.btnSensorType.layer.borderWidth=1.0f;
    self.btnSensorType.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnSensorType.layer.cornerRadius=5.0f;
    
    self.btnMoistureCompare.layer.borderWidth=1.0f;
    self.btnMoistureCompare.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnMoistureCompare.layer.cornerRadius=5.0f;
    
    self.btnPowerLevel.layer.borderWidth=1.0f;
    self.btnPowerLevel.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnPowerLevel.layer.cornerRadius=5.0f;
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
    
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==XERXES) {
        [self.btnSensorType setTitle:@"Axzon Xerxes - Temperature" forState:UIControlStateNormal];
    }
    else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==MAGNUSS3 && [CSLRfidAppEngine sharedAppEngine].temperatureSettings.reading==TEMPERATURE)
        [self.btnSensorType setTitle:@"Axzon Magnus S3 - Temperature" forState:UIControlStateNormal];
    else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==MAGNUSS3 && [CSLRfidAppEngine sharedAppEngine].temperatureSettings.reading==MOISTURE)
        [self.btnSensorType setTitle:@"Axzon Magnus S3 - Moisture" forState:UIControlStateNormal];
    else
        [self.btnSensorType setTitle:@"Axzon Magnus S2 - Moisture" forState:UIControlStateNormal];
    
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==LOWPOWER)
        [self.btnPowerLevel setTitle:@"Low (16dBm)" forState:UIControlStateNormal];
    else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==HIGHPOWER)
        [self.btnPowerLevel setTitle:@"High (30dBm)" forState:UIControlStateNormal];
    else if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel==MEDIUMPOWER)
        [self.btnPowerLevel setTitle:@"Medium (23dBm)" forState:UIControlStateNormal];
    else
        [self.btnPowerLevel setTitle:@"Follow System Setting" forState:UIControlStateNormal];
    
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.tagIdFormat==HEX)
        [self.swDisplayTagInAscii setOn:false];
    else
        [self.swDisplayTagInAscii setOn:true];
    
    if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.moistureAlertCondition==GREATER)
        [self.btnMoistureCompare setTitle:@">" forState:UIControlStateNormal];
    else
        [self.btnMoistureCompare setTitle:@"<" forState:UIControlStateNormal];
    
    [self.txtMoistureValue setText:[NSString stringWithFormat:@"%d",[CSLRfidAppEngine sharedAppEngine].temperatureSettings.moistureAlertValue]];
    
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
    if ([self.btnSensorType.currentTitle containsString:@"Xerxes"])
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType=XERXES;
    else
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType=[self.btnSensorType.currentTitle containsString:@"S3"] ? MAGNUSS3 : MAGNUSS2;
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.reading=[self.btnSensorType.currentTitle containsString:@"Temperature"] ? TEMPERATURE : MOISTURE;
    
    if ([self.btnPowerLevel.currentTitle isEqualToString:@"Low (16dBm)"])
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel=LOWPOWER;
    else if ([self.btnPowerLevel.currentTitle isEqualToString:@"High (30dBm)"])
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel=HIGHPOWER;
    else if ([self.btnPowerLevel.currentTitle isEqualToString:@"Medium (23dBm)"])
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel=MEDIUMPOWER;
    else
        [CSLRfidAppEngine sharedAppEngine].temperatureSettings.powerLevel=SYSTEMSETTING;
    
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.tagIdFormat=(TAGIDFORMAT)self.swDisplayTagInAscii.isOn;
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.moistureAlertCondition=[self.btnMoistureCompare.currentTitle containsString:@">"] ? GREATER : LESSTHAN;
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings.moistureAlertValue=[self.txtMoistureValue.text intValue];
    [[CSLRfidAppEngine sharedAppEngine] saveTemperatureTagSettingsToUserDefaults];
    
    //refresh configurations and clear previous readings on sensor read table view
    //[((CSLTemperatureTabVC*)self.tabBarController) setConfigurationsForTemperatureTags];
    //initialize averaging buffer

    CSLTemperatureReadVC* sensorVC = [self.tabBarController viewControllers][CSL_VC_TEMPTAB_READTEMP_VC_IDX];
    [sensorVC.btnSelectAllTag sendActionsForControlEvents:UIControlEventTouchUpInside];
    [sensorVC.btnRemoveAllTag sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self.actSaveConfig startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    [sensorVC viewWillDisappear:YES]; [sensorVC viewDidLoad]; [sensorVC viewWillAppear:YES];
    [self.actSaveConfig stopAnimating];
    
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
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtOcrssiMin.text intValue] >= 0 && [self.txtOcrssiMin.text intValue] <= 31) //valid int between 0 to 15
    {
        NSLog(@"On-chip RSSI low value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtOcrssiMin.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.rssiLowerLimit];
}

- (IBAction)txtOcrssiMaxChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtOcrssiMax.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtOcrssiMax.text intValue] >= 0 && [self.txtOcrssiMax.text intValue] <= 31) //valid int between 0 to 15
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

- (IBAction)btnSensorTypePressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sensor Type"
                                                                   message:@"Please select"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *s3Temp = [UIAlertAction actionWithTitle:@"Axzon Magnus S3 - Temperature" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnSensorType setTitle:@"Axzon Magnus S3 - Temperature" forState:UIControlStateNormal]; }]; // S3 - temperature
    UIAlertAction *s3Moist = [UIAlertAction actionWithTitle:@"Axzon Magnus S3 - Moisture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  { [self.btnSensorType setTitle:@"Axzon Magnus S3 - Moisture" forState:UIControlStateNormal]; }]; // S3 - Moisture
    UIAlertAction *s2Moist = [UIAlertAction actionWithTitle:@"Axzon Magnus S2 - Moisture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnSensorType setTitle:@"Axzon Magnus S2 - Moisture" forState:UIControlStateNormal]; }]; // Magnus - Moisture
    UIAlertAction *xerxesTemp = [UIAlertAction actionWithTitle:@"Axzon Xerxes - Temperature" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                              { [self.btnSensorType setTitle:@"Axzon Xerxes - Temperature" forState:UIControlStateNormal]; }]; // S2 - Moisture
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:s3Temp];
    [alert addAction:s3Moist];
    [alert addAction:s2Moist];
    [alert addAction:xerxesTemp];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnMoistureComparePressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Moisture Alert"
                                                                   message:@"Compare Condition"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *greater = [UIAlertAction actionWithTitle:@">" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnMoistureCompare setTitle:@">" forState:UIControlStateNormal]; }]; // >
    UIAlertAction *lessThan = [UIAlertAction actionWithTitle:@"<" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                              { [self.btnMoistureCompare setTitle:@"<" forState:UIControlStateNormal]; }]; // <

    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:greater];
    [alert addAction:lessThan];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnMoistureValueChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtMoistureValue.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtMoistureValue.text intValue] >= 0 && [self.txtMoistureValue.text intValue] <= 100) //valid int between 0 to 100
    {
        NSLog(@"Moisture alert value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtMoistureValue.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].temperatureSettings.moistureAlertValue];
}

- (IBAction)btnPowerLevelChanged:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Power Level"
                                                                   message:@"Please select"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *sysSetting = [UIAlertAction actionWithTitle:@"Follow System Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnPowerLevel setTitle:@"Follow System Setting" forState:UIControlStateNormal]; }]; // Follow System Setting
    UIAlertAction *low = [UIAlertAction actionWithTitle:@"Low (16dBm)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                              { [self.btnPowerLevel setTitle:@"Low (16dBm)" forState:UIControlStateNormal]; }]; // Low (16dBm)
    UIAlertAction *medium = [UIAlertAction actionWithTitle:@"Medium (23dBm)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                              { [self.btnPowerLevel setTitle:@"Medium (23dBm)" forState:UIControlStateNormal]; }]; // Medium (23dBm)
    UIAlertAction *high = [UIAlertAction actionWithTitle:@"High (30dBm)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                              { [self.btnPowerLevel setTitle:@"High (30dBm)" forState:UIControlStateNormal]; }]; // High (30dBm)
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:sysSetting];
    [alert addAction:low];
    [alert addAction:medium];
    [alert addAction:high];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
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
