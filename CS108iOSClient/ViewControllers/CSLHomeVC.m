//
//  CSLHomeVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLHomeVC.h"
#import "CSLSettingsVC.h"
#import "CSLTabVC.h"
#import "CSLInventoryVC.h"
#import "CSLDeviceTV.h"
#import "CSLRfidAppEngine.h"
#import "CSLAboutVC.h"
#import "CSLMoreFunctionsVC.h"
#import "CSLTemperatureReadVC.h"
#import "CSLTemperatureTabVC.h"



@interface CSLHomeVC () {
    NSTimer * scrRefreshTimer;
}
@end

@implementation CSLHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //timer event on updating UI

}
- (void)refreshBatteryInfo {
    @autoreleasepool {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus!=NOT_CONNECTED)
        {
            if ([CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage < 0 || [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage > 100)
                self.lbReaderStatus.text=@"Battery: -";
            else
                self.lbReaderStatus.text=[NSString stringWithFormat:@"Battery: %d%%", [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage];
        }
        else
            self.lbReaderStatus.text=@"";
            
    }
}
- (void)viewWillAppear:(BOOL)animated {
    
    [self.actHomeSpinner stopAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    self.view.userInteractionEnabled=true;
    
    //reload configurations from Users Defaults to memory
    [[CSLRfidAppEngine sharedAppEngine] reloadSettingsFromUserDefaults];
    
    //check if reader is connected
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus!=NOT_CONNECTED) {
        self.lbConnectReader.text=[NSString stringWithFormat:@"Connected: %@", [CSLRfidAppEngine sharedAppEngine].reader.deviceName];
        [self.btnConnectReader.imageView setImage:[UIImage imageNamed:@"connected"]];
        [self.btnConnectReader.imageView setNeedsDisplay];
    }
    else {
        self.lbConnectReader.text=@"Press to Connect";
        [self.btnConnectReader.imageView setImage:[UIImage imageNamed:@"disconnected"]];
        [self.btnConnectReader.imageView setNeedsDisplay];
    }
    
    //remove tag buffer
    [CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer=nil;
    [CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer =[[NSMutableArray alloc] init];
    //refresh MQTT (all previosu connections will drop) and temperature tag settings
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings = [[CSLMQTTSettings alloc] init];
    [[CSLRfidAppEngine sharedAppEngine] reloadMQTTSettingsFromUserDefaults];
    [CSLRfidAppEngine sharedAppEngine].temperatureSettings = [[CSLTemperatureTagSettings alloc] init];
    [[CSLRfidAppEngine sharedAppEngine] reloadTemperatureTagSettingsFromUserDefaults];
    [CSLRfidAppEngine sharedAppEngine].settings = [[CSLReaderSettings alloc] init];
    [[CSLRfidAppEngine sharedAppEngine] reloadSettingsFromUserDefaults];
    
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
    scrRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(refreshBatteryInfo)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=nil;
    [scrRefreshTimer invalidate];
    scrRefreshTimer=nil;
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

    //if no device is connected, the settings page will not be loaded
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==NOT_CONNECTED || [CSLRfidAppEngine sharedAppEngine].reader.connectStatus==SCANNING) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reader NOT connected" message:@"Please connect to reader first." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self.actHomeSpinner startAnimating];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
        [self showTabInterfaceActiveView:CSL_VC_RFIDTAB_INVENTORY_VC_IDX];
    }

    
}

- (void)showTabInterfaceActiveView:(int)identifier
{
    CSLTabVC * tabVC = (CSLTabVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_TabVC"];
    [tabVC setActiveView:identifier];
    
    if (tabVC != nil)
    {
        [[self navigationController] pushViewController:tabVC animated:YES];
    }
}

- (void)showTemperatureTabInterfaceActiveView:(int)identifier
{
    CSLTemperatureTabVC * tabVC = (CSLTemperatureTabVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_TempTabVC"];
    [tabVC setActiveView:identifier];
    
    if (tabVC != nil)
    {
        [[self navigationController] pushViewController:tabVC animated:YES];
    }
}


- (IBAction)btnSettingsPressed:(id)sender {
    CSLSettingsVC* settingsVC;
    
    //if no device is connected, the settings page will not be loaded
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==NOT_CONNECTED || [CSLRfidAppEngine sharedAppEngine].reader.connectStatus==SCANNING) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reader NOT connected" message:@"Please connect to reader first." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        settingsVC = (CSLSettingsVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SettingsVC"];
        
        if (settingsVC != nil)
        {
            [[self navigationController] pushViewController:settingsVC animated:YES];
        }
    }
}

- (IBAction)btnConnectReaderPressed:(id)sender {
    CSLDeviceTV* deviceTV;
    
    //if device is connected, will ask user if they want to disconnect it
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus!=NOT_CONNECTED && [CSLRfidAppEngine sharedAppEngine].reader.connectStatus!=SCANNING) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[CSLRfidAppEngine sharedAppEngine].reader.deviceName message:@"Disconnect reader?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
                                 
            //stop scanning for device
            [[CSLRfidAppEngine sharedAppEngine].reader barcodeReader:false];
            [[CSLRfidAppEngine sharedAppEngine].reader powerOnRfid:false];
            [[CSLRfidAppEngine sharedAppEngine].reader disconnectDevice];
            //connect to device selected
            self.lbConnectReader.text=@"Press to Connect";
            [self.btnConnectReader.imageView setImage:[UIImage imageNamed:@"disconnected"]];
            [self.btnConnectReader.imageView setNeedsDisplay];

        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            [self.btnConnectReader.imageView setImage:[UIImage imageNamed:@"connected"]];
            [self.btnConnectReader.imageView setNeedsDisplay];
        }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else {
        deviceTV = (CSLDeviceTV*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_DeviceTV"];
        
        if (deviceTV != nil)
        {
            [[self navigationController] pushViewController:deviceTV animated:YES];
        }
    }
}

- (IBAction)btnAboutPressed:(id)sender {
    CSLAboutVC* aboutVC;

    //if no device is connected, the settings page will not be loaded
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==NOT_CONNECTED || [CSLRfidAppEngine sharedAppEngine].reader.connectStatus==SCANNING) {
        
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"App Version" message:[NSString stringWithFormat:@"v%@ Build %@", appVersionString, appBuildString] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [[self navigationController] popViewControllerAnimated:YES]; }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        aboutVC = (CSLAboutVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_AboutVC"];
        
        if (aboutVC != nil)
        {
            [[self navigationController] pushViewController:aboutVC animated:YES];
        }
    }
    
}

- (IBAction)btnTagAccessPressed:(id)sender {
    
    //if no device is connected, the settings page will not be loaded
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==NOT_CONNECTED || [CSLRfidAppEngine sharedAppEngine].reader.connectStatus==SCANNING) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reader NOT connected" message:@"Please connect to reader first." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        [self showTabInterfaceActiveView:CSL_VC_RFIDTAB_ACCESS_VC_IDX];
    }

    
    
}


- (IBAction)btnTagSearchPressed:(id)sender {
    
    //if no device is connected, the settings page will not be loaded
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==NOT_CONNECTED || [CSLRfidAppEngine sharedAppEngine].reader.connectStatus==SCANNING) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reader NOT connected" message:@"Please connect to reader first." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        [self showTabInterfaceActiveView:CSL_VC_RFIDTAB_SEARCH_VC_IDX];
    }
    
    
    
}

- (IBAction)btnFunctionsPressed:(id)sender {
    
    CSLMoreFunctionsVC * funcVC;
    //if no device is connected, the settings page will not be loaded
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==NOT_CONNECTED || [CSLRfidAppEngine sharedAppEngine].reader.connectStatus==SCANNING) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reader NOT connected" message:@"Please connect to reader first." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        funcVC = (CSLMoreFunctionsVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_FuncVC"];
        
        if (funcVC != nil)
        {
            [[self navigationController] pushViewController:funcVC animated:YES];
        }
    }

    
}

- (IBAction)btnReadTemperaturePressed:(id)sender {
    //if no device is connected, the settings page will not be loaded
    if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==NOT_CONNECTED || [CSLRfidAppEngine sharedAppEngine].reader.connectStatus==SCANNING) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reader NOT connected" message:@"Please connect to reader first." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self.actHomeSpinner startAnimating];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
        self.view.userInteractionEnabled=false;
        [self showTemperatureTabInterfaceActiveView:CSL_VC_TEMPTAB_READTEMP_VC_IDX];
    }

    
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {  //define delegate method to be implemented within another class
}
- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {  //define delegate method to be implemented within another class
}
- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct; 
}
- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {

}
- (void) didReceiveTagAccessData: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {

}

@end
