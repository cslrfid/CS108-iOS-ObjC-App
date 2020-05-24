//
//  CSLSettingsVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLReaderSettings.h"
#import "CSLMQTTClientSettings.h"
#import "CSLRfidAppEngine.h"
#import "CSLPowerLevelVC.h"
#import "CSLAntennaPortVC.h"

@interface CSLSettingsVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSaveConfig;
@property (weak, nonatomic) IBOutlet UIButton *btnSession;
@property (weak, nonatomic) IBOutlet UIButton *btnAlgorithm;
@property (weak, nonatomic) IBOutlet UIButton *btnLinkProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnTarget;
@property (weak, nonatomic) IBOutlet UISwitch *btnQOverride;
@property (weak, nonatomic) IBOutlet UITextField *txtQValue;
@property (weak, nonatomic) IBOutlet UITextField *txtTagPopulation;
@property (weak, nonatomic) IBOutlet UITextField *txtPower;
@property (weak, nonatomic) IBOutlet UISwitch *swSound;
@property (weak, nonatomic) IBOutlet UIButton *btnPowerLevel;
@property (weak, nonatomic) IBOutlet UIButton *btnAntennaSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnRfLna;
@property (weak, nonatomic) IBOutlet UIButton *btnIfLna;
@property (weak, nonatomic) IBOutlet UIButton *btnAgcGain;
@property (weak, nonatomic) IBOutlet UISwitch *swLnaHighComp;
@property (weak, nonatomic) IBOutlet UISwitch *swTagFocus;
@property (weak, nonatomic) IBOutlet UIButton *btnRegion;
@property (weak, nonatomic) IBOutlet UIButton *btnFrequencyChannel;
@property (weak, nonatomic) IBOutlet UIButton *btnFrequencyOrder;

- (IBAction)btnSessionPressed:(id)sender;
- (IBAction)btnAlgorithmPressed:(id)sender;
- (IBAction)btnLinkProfilePressed:(id)sender;
- (IBAction)btnTargetPressed:(id)sender;
- (IBAction)btnQOverridePressed:(id)sender;
- (IBAction)txtQValueChanged:(id)sender;
- (IBAction)txtTagPopulationChanged:(id)sender;
- (IBAction)txtPowerChanged:(id)sender;
- (IBAction)btnSaveConfigPressed:(id)sender;
- (IBAction)btnPowerLevelPressed:(id)sender;
- (IBAction)btnAntennaSettingsPressed:(id)sender;
- (IBAction)btnRfLnaPressed:(id)sender;
- (IBAction)btnIfLnaPressed:(id)sender;
- (IBAction)btnAgcGainPressed:(id)sender;
- (IBAction)btnRegionPressed:(id)sender;
- (IBAction)btnFrequencyChannelPressed:(id)sender;
- (IBAction)btnFrequencyOrderPressed:(id)sender;


@end
