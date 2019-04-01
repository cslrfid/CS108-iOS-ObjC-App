//
//  CSLTemperatureTabVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 28/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

#define CSL_VC_TEMPTAB_READTEMP_VC_IDX 0
#define CSL_VC_TEMPTAB_DETAILS_VC_IDX 1
#define CSL_VC_TEMPTAB_REGISTRATION_VC_IDX 2
#define CSL_VC_TEMPTAB_SETTINGS_VC_IDX 3
#define CSL_VC_TEMPTAB_UPLOAD_VC_IDX 3

NS_ASSUME_NONNULL_BEGIN

@interface CSLTemperatureTabVC : UITabBarController<UITabBarControllerDelegate>
{
    int m_SelectedTabView;
}

- (void)setActiveView:(int)identifier;

@end

NS_ASSUME_NONNULL_END
