//
//  CSLSettingsVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLReaderSettings.h"
#import "CSLRfidAppEngine.h"

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

- (IBAction)btnSessionPressed:(id)sender;
- (IBAction)btnAlgorithmPressed:(id)sender;
- (IBAction)btnLinkProfilePressed:(id)sender;
- (IBAction)btnTargetPressed:(id)sender;
- (IBAction)btnQOverridePressed:(id)sender;
- (IBAction)txtQValueChanged:(id)sender;
- (IBAction)txtTagPopulationChanged:(id)sender;
- (IBAction)txtPowerChanged:(id)sender;
- (IBAction)btnSaveConfigPressed:(id)sender;

@end
