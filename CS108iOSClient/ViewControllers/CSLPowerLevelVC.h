//
//  CSLPowerLevelVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2019-10-31.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSLPowerLevelVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSetPowerLevel;
@property (weak, nonatomic) IBOutlet UITextField *txtPower1;
@property (weak, nonatomic) IBOutlet UITextField *txtPower2;
@property (weak, nonatomic) IBOutlet UITextField *txtPower3;
@property (weak, nonatomic) IBOutlet UITextField *txtPower4;
@property (weak, nonatomic) IBOutlet UITextField *txtPower5;
@property (weak, nonatomic) IBOutlet UITextField *txtPower6;
@property (weak, nonatomic) IBOutlet UITextField *txtPower7;
@property (weak, nonatomic) IBOutlet UITextField *txtPower8;
@property (weak, nonatomic) IBOutlet UITextField *txtPower9;
@property (weak, nonatomic) IBOutlet UITextField *txtPower10;
@property (weak, nonatomic) IBOutlet UITextField *txtPower11;
@property (weak, nonatomic) IBOutlet UITextField *txtPower12;
@property (weak, nonatomic) IBOutlet UITextField *txtPower13;
@property (weak, nonatomic) IBOutlet UITextField *txtPower14;
@property (weak, nonatomic) IBOutlet UITextField *txtPower15;
@property (weak, nonatomic) IBOutlet UITextField *txtPower16;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell1;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell2;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell3;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell4;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell5;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell6;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell7;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell8;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell9;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell10;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell11;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell12;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell13;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell14;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell15;
@property (weak, nonatomic) IBOutlet UITextField *txtDwell16;
@property (weak, nonatomic) IBOutlet UITextField *txtNumberOfPowerLevel;
@property (strong, nonatomic) IBOutletCollection(UIStackView) NSArray *svPowerLevel;
@property (weak, nonatomic) IBOutlet UIStackView *svNumberOfPowerLevel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lbPort1To4;


- (IBAction)txtPowerPressed:(id)sender;
- (IBAction)txtDwellPressed:(id)sender;
- (IBAction)txtNumberOfPowerLevelPressed:(id)sender;

- (IBAction)btnSetPowerLevelPressed:(id)sender;


@end

NS_ASSUME_NONNULL_END
