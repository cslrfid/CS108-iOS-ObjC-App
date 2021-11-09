//
//  CSLTagKillVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-10-30.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLTagKillVC : UIViewController<CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSelectedEPC;
@property (weak, nonatomic) IBOutlet UITextField *txtKillPwd;
@property (weak, nonatomic) IBOutlet UIButton *btnKillTag;

- (IBAction)btnKillTagPressed:(id)sender;
- (IBAction)txtKillPwdEditied:(id)sender;
- (IBAction)txtSelectedEPCEdited:(id)sender;

@end

NS_ASSUME_NONNULL_END
