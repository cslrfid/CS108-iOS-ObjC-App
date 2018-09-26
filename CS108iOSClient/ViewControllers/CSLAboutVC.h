//
//  CSLAboutVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 23/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSLAboutVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lbAppVersion;
@property (weak, nonatomic) IBOutlet UILabel *lbBtFirmwareVersion;
@property (weak, nonatomic) IBOutlet UILabel *lbRfidFirmwareVersion;
@property (weak, nonatomic) IBOutlet UILabel *lbSiLabIcFirmwareVersion;
@property (weak, nonatomic) IBOutlet UILabel *lbSerialNumber;


@end
