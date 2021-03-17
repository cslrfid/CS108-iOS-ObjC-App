//
//  CSLPostfilterVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-03-16.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLPostfilterVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtMask;
@property (weak, nonatomic) IBOutlet UITextField *txtOffset;
@property (weak, nonatomic) IBOutlet UISwitch *swNotMatchMask;
@property (weak, nonatomic) IBOutlet UISwitch *swFilterEnabled;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;


- (IBAction)txtMaskChanged:(id)sender;
- (IBAction)txtOffsetChanged:(id)sender;
- (IBAction)btnSavePressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
