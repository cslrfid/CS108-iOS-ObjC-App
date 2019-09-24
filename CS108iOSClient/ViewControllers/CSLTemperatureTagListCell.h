//
//  CSLTemperatureTagListCell.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLRfidAppEngine.h"
#import "CSLTemperatureTabVC.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSLTemperatureTagListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbEPC;
@property (weak, nonatomic) IBOutlet UILabel *lbTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lbRssi;
@property (weak, nonatomic) IBOutlet UIButton *lbTagStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UIView *viewAccessory;
@property (weak, nonatomic) IBOutlet UIButton *accessory;
@property (weak, nonatomic) IBOutlet UIView *viTemperatureCell;

+ (double) calculateCalibratedTemperatureValue:(NSString*) tempCodeInHexString calibration:(NSString*) calibrationInHexString;
+ (double) calculateCalibratedTemperatureValueForXerxes:(UInt16)tempCode TemperatureCode2:(UInt16)tempCode2 Temperature2:(UInt16)temp2 TemperatureCode1:(UInt16)tempCode1 Temperature1:(UInt16)temp1;
- (void) spinTemperatureValueIndicator;
@end

NS_ASSUME_NONNULL_END
