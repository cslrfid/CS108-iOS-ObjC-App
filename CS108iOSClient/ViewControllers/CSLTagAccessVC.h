//
//  CSLTagAccessVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 16/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"
#import "CSLTabVC.h"

typedef NS_ENUM(Byte, MEMORYITEM)
{
    mKILLPWD,
    mACCPWD,
    mPC,
    mEPC,
    mTID,
    mUSER
};

//NS_ASSUME_NONNULL_BEGIN

@interface CSLTagAccessVC : UIViewController<CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate> {
    MEMORYBANK bankSelected;
    MEMORYITEM memItem;
}

@property (weak, nonatomic) IBOutlet UITextField *txtSelectedEPC;
@property (weak, nonatomic) IBOutlet UITextField *txtAccessPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtPC;
@property (weak, nonatomic) IBOutlet UITextField *txtEPC;
@property (weak, nonatomic) IBOutlet UITextField *txtAccPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtKillPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtTidUid;
@property (weak, nonatomic) IBOutlet UITextField *txtUser;
@property (weak, nonatomic) IBOutlet UISwitch *swPC;
@property (weak, nonatomic) IBOutlet UISwitch *swEPC;
@property (weak, nonatomic) IBOutlet UISwitch *swAccPwd;
@property (weak, nonatomic) IBOutlet UISwitch *swKillPwd;
@property (weak, nonatomic) IBOutlet UISwitch *swTidUid;
@property (weak, nonatomic) IBOutlet UISwitch *swUser;
@property (weak, nonatomic) IBOutlet UIButton *btnTidUidOffset;
@property (weak, nonatomic) IBOutlet UIButton *btnTidUidWord;
@property (weak, nonatomic) IBOutlet UIButton *btnUserOffset;
@property (weak, nonatomic) IBOutlet UIButton *btnUserWord;
@property (weak, nonatomic) IBOutlet UIButton *btnRead;
@property (weak, nonatomic) IBOutlet UIButton *btnWrite;
@property (weak, nonatomic) IBOutlet UIButton *btnSecurity;
@property (weak, nonatomic) IBOutlet UITextField *txtPower;
@property (weak, nonatomic) IBOutlet UILabel *lbPort;
@property (weak, nonatomic) IBOutlet UITextField *txtPort;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actTagAccessSpinner;
@property (weak, nonatomic) IBOutlet UIButton *btnKill;

- (IBAction)swPCPressed:(id)sender;
- (IBAction)swEPCPressed:(id)sender;
- (IBAction)swAccPwdPressed:(id)sender;
- (IBAction)swKillPwdPressed:(id)sender;
- (IBAction)swTidUidPressed:(id)sender;
- (IBAction)swUserPressed:(id)sender;

- (IBAction)btnTidUidOffsetPressed:(id)sender;
- (IBAction)btnTidUidWordPressed:(id)sender;
- (IBAction)btnUserOffsetPressed:(id)sender;
- (IBAction)btnUserWordPressed:(id)sender;

- (IBAction)btnReadPressed:(id)sender;
- (IBAction)btnWritePressed:(id)sender;
- (IBAction)btnSecurityPressed:(id)sender;
- (IBAction)btnKillPressed:(id)sender;


- (IBAction)txtSelectedEPCChanged:(id)sender;
- (IBAction)txtAccessPwdChanged:(id)sender;
- (IBAction)txtPCChanged:(id)sender;
- (IBAction)txtEPCChanged:(id)sender;
- (IBAction)txtAccPwdChanged:(id)sender;
- (IBAction)txtKillPwdChanged:(id)sender;
- (IBAction)txtTidUidChanged:(id)sender;
- (IBAction)txtUserChanged:(id)sender;

- (IBAction)txtPowerChanged:(id)sender;
- (IBAction)txtPortChanged:(id)sender;


@end


//NS_ASSUME_NONNULL_END
