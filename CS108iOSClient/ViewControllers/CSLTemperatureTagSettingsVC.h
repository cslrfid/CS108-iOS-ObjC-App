//
//  CSLTemperatureTagSettingsVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 14/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"
#import "CSLTemperatureTabVC.h"
#import "CSLTemperatureReadVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLTemperatureTagSettingsVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *swEnableTemperatureAlert;
@property (weak, nonatomic) IBOutlet UITextField *txtLowTemperatureThreshold;
@property (weak, nonatomic) IBOutlet UITextField *txtHighTemperatureThreshold;
@property (weak, nonatomic) IBOutlet UITextField *txtOcrssiMin;
@property (weak, nonatomic) IBOutlet UITextField *txtOcrssiMax;
@property (weak, nonatomic) IBOutlet UITextField *txtNumberOfTemperatureAveraging;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scTemperatureUnit;
@property (weak, nonatomic) IBOutlet UIButton *btnSensorType;
@property (weak, nonatomic) IBOutlet UIButton *btnMoistureCompare;
@property (weak, nonatomic) IBOutlet UITextField *txtMoistureValue;
@property (weak, nonatomic) IBOutlet UIButton *btnPowerLevel;
@property (weak, nonatomic) IBOutlet UISwitch *swDisplayTagInAscii;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actSaveConfig;
@property (weak, nonatomic) IBOutlet UIView *uivOcrssiMin;
@property (weak, nonatomic) IBOutlet UIView *uivOcrssiMax;
@property (weak, nonatomic) IBOutlet UIView *uivMoistureAlert;

- (IBAction)btnSavePressed:(id)sender;
- (IBAction)txtLowTemperatureThresholdChanged:(id)sender;
- (IBAction)txtHighTemperatureThresholdChanged:(id)sender;
- (IBAction)txtOcrssiMinChanged:(id)sender;
- (IBAction)txtOcrssiMaxChanged:(id)sender;
- (IBAction)txtNumberOfTemperatureAveragingChanged:(id)sender;
- (IBAction)btnSensorTypePressed:(id)sender;
- (IBAction)btnMoistureComparePressed:(id)sender;
- (IBAction)btnMoistureValueChanged:(id)sender;
- (IBAction)btnPowerLevelChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
