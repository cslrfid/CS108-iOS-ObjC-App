//
//  CSLAntennaPortVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2019-11-01.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSLAntennaPortVC : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *btnAntennaPorts;
- (IBAction)btnAntennaPortsPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
