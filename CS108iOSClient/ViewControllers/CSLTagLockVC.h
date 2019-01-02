//
//  CSLTagLockVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 30/12/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLTagLockVC : UIViewController<CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *txtSelectedEPC;
@property (weak, nonatomic) IBOutlet UITextField *txtAccessPwd;
@property (weak, nonatomic) IBOutlet UIButton *btnEPCSecurity;
@property (weak, nonatomic) IBOutlet UIButton *btnAccPwdSecurity;
@property (weak, nonatomic) IBOutlet UIButton *btnKillPwdSecurity;
@property (weak, nonatomic) IBOutlet UIButton *btnTidSecurity;
@property (weak, nonatomic) IBOutlet UIButton *btnUserSecurity;
@property (weak, nonatomic) IBOutlet UIButton *btnApplySecurity;

- (IBAction)btnApplySecurityPressed:(id)sender;
- (IBAction)btnEPCSecurityPressed:(id)sender;
- (IBAction)btnAccPwdSecurityPressed:(id)sender;
- (IBAction)btnKillPwdSecurityPressed:(id)sender;
- (IBAction)btnTidSecurityPressed:(id)sender;
- (IBAction)btnUserSecurityPressed:(id)sender;




@end

NS_ASSUME_NONNULL_END
