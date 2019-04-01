//
//  CSLTemperatureDetailsVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 4/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"
#import "CSLTemperatureTagListCell.h"
#import "CSLTemperatureTabVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLTemperatureDetailsVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lbEPC;
@property (weak, nonatomic) IBOutlet UIButton *btnTagStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lbTimestamp;

@property (weak, nonatomic) IBOutlet UIView *uivTemperatureDetails;
@property (weak, nonatomic) IBOutlet UILabel *lbCalibration;
@property (weak, nonatomic) IBOutlet UILabel *lbSensorCode;
@property (weak, nonatomic) IBOutlet UILabel *lbOCRSSI;
@property (weak, nonatomic) IBOutlet UILabel *lbTemperatureCode;

@end

NS_ASSUME_NONNULL_END
