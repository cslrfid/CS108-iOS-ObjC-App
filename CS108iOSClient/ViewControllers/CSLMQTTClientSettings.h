//
//  CSLMQTTClientSettings.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 7/1/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLMQTTClientSettings.h"
#import "CSLRfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLMQTTClientSettings : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtBrokerAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtBrokerPort;
@property (weak, nonatomic) IBOutlet UITextField *txtClientID;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UISwitch *swEnableTLS;
@property (weak, nonatomic) IBOutlet UITextField *txtQoS;
@property (weak, nonatomic) IBOutlet UISwitch *swRetained;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UISwitch *swMQTTEnabled;


- (IBAction)btnSavePressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
