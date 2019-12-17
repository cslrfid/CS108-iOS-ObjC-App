//
//  CSLTagSearchVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/12/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"
#import "LMGaugeView.h"
#import "CSLTabVC.h"

#define ROLLING_AVG_COUNT 10

NS_ASSUME_NONNULL_BEGIN

@interface CSLTagSearchVC : UIViewController<CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet LMGaugeView *gaugeView;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UITextField *txtEPC;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actSearchSpinner;



- (IBAction)btnSearchPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
