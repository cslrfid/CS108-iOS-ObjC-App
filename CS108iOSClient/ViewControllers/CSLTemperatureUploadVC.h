//
//  CSLTemperatureUploadVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 16/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLTemperatureUploadVC : UIViewController<MQTTSessionDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgMQTTStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnMQTTStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbMQTTMessage;
@property (weak, nonatomic) IBOutlet UITextField *txtMQTTPublishTopic;
@property (weak, nonatomic) IBOutlet UIButton *btnMQTTUpload;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actMQTTConnectIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveToFile;

- (IBAction)btnMQTTUpload:(id)sender;
- (IBAction)btnSaveToFilePressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
