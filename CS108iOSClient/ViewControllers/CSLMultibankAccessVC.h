//
//  CSLMultibankAccessVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 20/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLMultibankAccessVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *swEnableMultibank1;
@property (weak, nonatomic) IBOutlet UIButton *btnMultibank1Select;
@property (weak, nonatomic) IBOutlet UITextField *txtMultibank1Offset;
@property (weak, nonatomic) IBOutlet UITextField *txtMultibank1Size;

@property (weak, nonatomic) IBOutlet UISwitch *swEnableMultibank2;
@property (weak, nonatomic) IBOutlet UIButton *btnMultibank2Select;
@property (weak, nonatomic) IBOutlet UITextField *txtMultibank2Offset;
@property (weak, nonatomic) IBOutlet UITextField *txtMultibank2Size;
@property (weak, nonatomic) IBOutlet UIButton *btnMultibankSave;

@property (weak, nonatomic) IBOutlet UILabel *lbBank;
@property (weak, nonatomic) IBOutlet UILabel *lbOffset;
@property (weak, nonatomic) IBOutlet UILabel *lbSize;

- (IBAction)swEnableMultibank1Pressed:(id)sender;
- (IBAction)btnMultibank1SelectPressed:(id)sender;
- (IBAction)txtMultibank1OffsetPressed:(id)sender;
- (IBAction)txtMultibank1SizePressed:(id)sender;

- (IBAction)swEnableMultibank2Pressed:(id)sender;
- (IBAction)btnMultibank2SelectPressed:(id)sender;
- (IBAction)txtMultibank2OffsetPressed:(id)sender;
- (IBAction)txtMultibank2SizePressed:(id)sender;

- (IBAction)btnMultibankSavePressed:(id)sender;


@end

NS_ASSUME_NONNULL_END
