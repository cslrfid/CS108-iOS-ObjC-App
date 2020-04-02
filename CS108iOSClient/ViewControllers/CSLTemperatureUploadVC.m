//
//  CSLTemperatureUploadVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 16/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLTemperatureUploadVC.h"

@interface CSLTemperatureUploadVC () {

    NSTimer* scrMQTTStatusRefresh;
}

@end

@implementation CSLTemperatureUploadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.txtMQTTPublishTopic setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tabBarController setTitle:@"Data Upload"];
    
    self.btnMQTTStatus.layer.borderWidth=1.0f;
    self.btnMQTTStatus.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnMQTTStatus.layer.cornerRadius=5.0f;
    self.btnMQTTUpload.layer.borderWidth=1.0f;
    self.btnMQTTUpload.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnMQTTUpload.layer.cornerRadius=5.0f;
    
    //clear UI
    [self.imgMQTTStatus setImage:nil];
    [self.btnMQTTStatus setHidden:true];
    [self.btnMQTTUpload setEnabled:false];
    self.lbMQTTMessage.text=[NSString stringWithFormat:@"Number of Records: %d", (int)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count]];
    
    if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled) {
        if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.mqttStatus!=MQTTStatusConnected) {
            [CSLRfidAppEngine sharedAppEngine].MQTTSettings.mqttStatus=MQTTStatusNotConnected;
            
            [self.actMQTTConnectIndicator startAnimating];
            [[CSLRfidAppEngine sharedAppEngine].MQTTSettings connectToMQTTBroker:self.txtMQTTPublishTopic.text];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //wait for 5s for connection
                if([CSLRfidAppEngine sharedAppEngine].MQTTSettings.mqttStatus==MQTTStatusConnected || [CSLRfidAppEngine sharedAppEngine].MQTTSettings.mqttStatus==MQTTStatusError)
                    break;
                [NSThread sleepForTimeInterval:0.1f];
            }
            [self.actMQTTConnectIndicator stopAnimating];
            if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.mqttStatus==MQTTStatusConnected) {
                [self.imgMQTTStatus setImage:[UIImage imageNamed:@"cloud-connected"]];
                [self.btnMQTTStatus setHidden:false];
                [self.btnMQTTStatus setTitle:@"CONNECTED" forState:UIControlStateNormal];
                [self.btnMQTTStatus setBackgroundColor:UIColorFromRGB(0x26A65B)];  //green
            }
            else {
                [self.imgMQTTStatus setImage:[UIImage imageNamed:@"cloud-offline"]];
                [self.btnMQTTStatus setHidden:false];
                [self.btnMQTTStatus setTitle:@"DISCONNECTED" forState:UIControlStateNormal];
                [self.btnMQTTStatus setBackgroundColor:UIColorFromRGB(0xd63031)];  //red
            }
        }
        else {
            [self.imgMQTTStatus setImage:[UIImage imageNamed:@"cloud-connected"]];
            [self.btnMQTTStatus setHidden:false];
            [self.btnMQTTStatus setTitle:@"CONNECTED" forState:UIControlStateNormal];
            [self.btnMQTTStatus setBackgroundColor:UIColorFromRGB(0x26A65B)];  //green
        }
    }
    else {
        [self.imgMQTTStatus setImage:[UIImage imageNamed:@"cloud-offline"]];
        [self.btnMQTTStatus setHidden:false];
        [self.btnMQTTStatus setTitle:@"OFFLINE" forState:UIControlStateNormal];
        [self.btnMQTTStatus setBackgroundColor:UIColorFromRGB(0xA3A3A3)];  //grey
    }
    
    if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.mqttStatus==MQTTStatusConnected && [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count] > 0) {
        [self.btnMQTTUpload setEnabled:true];
    }
    
    if ([[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count] > 0)
        self.btnSaveToFile.enabled=true;
    else
        self.btnSaveToFile.enabled=false;
    
    //timer event on updating MQTT status UI
    scrMQTTStatusRefresh = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                       target:self
                                                     selector:@selector(refreshMQTTStatus)
                                                     userInfo:nil
                                                      repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:scrMQTTStatusRefresh forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated {
    [scrMQTTStatusRefresh invalidate];
    scrMQTTStatusRefresh=nil;
}

- (void)refreshMQTTStatus {
    if (![CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled) {
        [self.imgMQTTStatus setImage:[UIImage imageNamed:@"cloud-offline"]];
        [self.btnMQTTStatus setHidden:false];
        [self.btnMQTTStatus setTitle:@"OFFLINE" forState:UIControlStateNormal];
        [self.btnMQTTStatus setBackgroundColor:UIColorFromRGB(0xA3A3A3)];  //grey
        [self.btnMQTTUpload setEnabled:false];
    }
    else {
        if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.mqttStatus==MQTTStatusConnected) {
            [self.imgMQTTStatus setImage:[UIImage imageNamed:@"cloud-connected"]];
            [self.btnMQTTStatus setHidden:false];
            [self.btnMQTTStatus setTitle:@"CONNECTED" forState:UIControlStateNormal];
            [self.btnMQTTStatus setBackgroundColor:UIColorFromRGB(0x26A65B)];  //green
            if([[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count]) {
                [self.btnMQTTUpload setEnabled:true];
            }
        }
        else {
            [self.imgMQTTStatus setImage:[UIImage imageNamed:@"cloud-offline"]];
            [self.btnMQTTStatus setHidden:false];
            [self.btnMQTTStatus setTitle:@"DISCONNECTED" forState:UIControlStateNormal];
            [self.btnMQTTStatus setBackgroundColor:UIColorFromRGB(0xd63031)];  //red
            [self.btnMQTTUpload setEnabled:false];
            [[CSLRfidAppEngine sharedAppEngine].MQTTSettings connectToMQTTBroker:self.txtMQTTPublishTopic.text];    //reconnect
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
    [[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
}

- (IBAction)btnMQTTUpload:(id)sender {
    [self.btnMQTTUpload setEnabled:false];
    
    if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled && [CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled==true) {
        
        [self.imgMQTTStatus setHidden:true];
        [self.actMQTTConnectIndicator startAnimating];
        [CSLRfidAppEngine sharedAppEngine].MQTTSettings.publishTopicCounter=0;
        
        for (CSLBleTag* tag in [CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer) {
            CSLBleTag* lastGoodRead=[[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer objectForKey:tag.EPC];
            //tag read timestamp
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd/MM/YY HH:mm:ss"];
            NSDate* date=lastGoodRead.timestamp;
            NSString *stringFromDate = [dateFormatter stringFromDate:date];
            
            //build an info object and convert to json
            NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [[NSUUID UUID] UUIDString],
                                  @"messageid",
                                  tag.EPC,
                                  @"epc",
                                  [NSString stringWithFormat:@"%.1f",[[[CSLRfidAppEngine sharedAppEngine].temperatureSettings getTemperatureValueAveraging:tag.EPC] doubleValue]],
                                  @"temperature",
                                  lastGoodRead.DATA2,
                                  @"calibration",
                                  [lastGoodRead.DATA1 substringWithRange:NSMakeRange(0, 4)],
                                  @"sensorcode",
                                  [lastGoodRead.DATA1 substringWithRange:NSMakeRange(4, 4)],
                                  @"ocrssi",
                                  [lastGoodRead.DATA1 substringWithRange:NSMakeRange(8, 4)],
                                  @"temperaturecode",
                                  [NSString stringWithFormat:@"%d",tag.rssi],
                                  @"rssi",
                                  stringFromDate,
                                  @"timestamp",
                                  nil];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&err];
            NSString* topic=[self.txtMQTTPublishTopic.text stringByReplacingOccurrencesOfString:@"{deviceId}" withString:[CSLRfidAppEngine sharedAppEngine].MQTTSettings.clientId];
            
            [[CSLRfidAppEngine sharedAppEngine].MQTTSettings publishData:jsonData onTopic:topic];
        }

        for (int i=0;i<COMMAND_TIMEOUT_10S;i++) { //wait for 5s for connection
            if([CSLRfidAppEngine sharedAppEngine].MQTTSettings.publishTopicCounter==[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count])
                break;
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Data Upload"
                                                    message:[NSString stringWithFormat:@"Uploaded %d/%d Record(s).", [CSLRfidAppEngine sharedAppEngine].MQTTSettings.publishTopicCounter, (int)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count]]
                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self.imgMQTTStatus setHidden:false];
        [self.actMQTTConnectIndicator stopAnimating];
        
    }
    [self.btnMQTTUpload setEnabled:true];
}

- (IBAction)btnSaveToFilePressed:(id)sender {
    
    NSString* fileContent = @"TIMESTAMP,EPC,TEMPERATURE,CALIBRATION,SENSORCODE,ON-CHIP RSSI,TEMPERATURE CODE,RSSI\n";

    for (CSLBleTag* tag in [CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer) {
        CSLBleTag* lastGoodRead=[[CSLRfidAppEngine sharedAppEngine].temperatureSettings.lastGoodReadBuffer objectForKey:tag.EPC];
        //tag read timestamp
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/YY HH:mm:ss"];
        NSDate* date=lastGoodRead.timestamp;
        NSString *stringFromDate = [dateFormatter stringFromDate:date];
        
        NSNumber* average=[[CSLRfidAppEngine sharedAppEngine].temperatureSettings getTemperatureValueAveraging:tag.EPC];
        NSString* averageText;
        if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.reading==TEMPERATURE) {
            if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.unit == CELCIUS)
                averageText = [NSString stringWithFormat:@"%3.1f\u00BA", [average doubleValue]];
            else
                averageText = [NSString stringWithFormat:@"%3.1f\u00BA", [CSLTemperatureTagSettings convertCelciusToFahrenheit:[average doubleValue]]];
            //build the text file content
            fileContent=[fileContent stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@\n", stringFromDate, tag.EPC, averageText, lastGoodRead.DATA2, [lastGoodRead.DATA1 substringWithRange:NSMakeRange(0, 4)], [lastGoodRead.DATA1 substringWithRange:NSMakeRange(4, 4)], [lastGoodRead.DATA1 substringWithRange:NSMakeRange(8, 4)], [NSString stringWithFormat:@"%d",tag.rssi]]];
        }
        else {
            if ([CSLRfidAppEngine sharedAppEngine].temperatureSettings.sensorType==MAGNUSS3)
                averageText = [NSString stringWithFormat:@"%3.1f%%", (((490.00 - [average doubleValue]) / (490.00 - 5.00)) * 100.00)];
            else
                averageText = [NSString stringWithFormat:@"%3.1f%%", (((31 - [average doubleValue]) / (31)) * 100.00)];
            //build the text file content
            fileContent=[fileContent stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@\n", stringFromDate, tag.EPC, averageText, @"", lastGoodRead.DATA1, lastGoodRead.DATA2, @"", [NSString stringWithFormat:@"%d",tag.rssi]]];
        }
        
    }
    
    NSArray *objectsToShare = @[fileContent];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
