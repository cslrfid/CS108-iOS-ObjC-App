//
//  CSLMQTTClientSettings.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 7/1/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLMQTTClientSettings.h"

@interface CSLMQTTClientSettings ()

@end

@implementation CSLMQTTClientSettings

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnSave.layer.borderWidth=1.0f;
    self.btnSave.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnSave.layer.cornerRadius=5.0f;
    
    self.navigationItem.title=@"MQTT Settings";
}

- (void)viewWillAppear:(BOOL)animated {
    
    //reload previously stored settings
    [[CSLRfidAppEngine sharedAppEngine] reloadMQTTSettingsFromUserDefaults];
    
    //refresh UI with stored values
    [self.swMQTTEnabled setOn:[CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled];
    self.txtBrokerAddress.text= [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerAddress;
    self.txtBrokerPort.text= [NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerPort];
    self.txtClientID.text= [CSLRfidAppEngine sharedAppEngine].MQTTSettings.clientId;
    self.txtUserName.text= [CSLRfidAppEngine sharedAppEngine].MQTTSettings.userName;
    self.txtPassword.text= [CSLRfidAppEngine sharedAppEngine].MQTTSettings.password;
    [self.swEnableTLS setOn:[CSLRfidAppEngine sharedAppEngine].MQTTSettings.isTLSEnabled];
    self.txtQoS.text= [NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS];
    [self.swRetained setOn:[CSLRfidAppEngine sharedAppEngine].MQTTSettings.retained];
    
    [self.txtQoS setDelegate:self];
    [self.txtClientID setDelegate:self];
    [self.txtPassword setDelegate:self];
    [self.txtUserName setDelegate:self];
    [self.txtBrokerPort setDelegate:self];
    [self.txtBrokerAddress setDelegate:self];
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
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled=self.swMQTTEnabled.isOn;
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerAddress=self.txtBrokerAddress.text;
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerPort=[self.txtBrokerPort.text intValue];
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.clientId=self.txtClientID.text;
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.userName=self.txtUserName.text;
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.password=self.txtPassword.text;
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.isTLSEnabled=self.swEnableTLS.isOn;
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS=[self.txtQoS.text intValue];
    [CSLRfidAppEngine sharedAppEngine].MQTTSettings.retained=self.swRetained.isOn;
    
    [[CSLRfidAppEngine sharedAppEngine] saveMQTTSettingsToUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Settings" message:@"Settings saved." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
@end
