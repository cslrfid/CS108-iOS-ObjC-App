//
//  CSLTabVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

#define CSL_VC_RFIDTAB_INVENTORY_VC_IDX 0
#define CSL_VC_RFIDTAB_SEARCH_VC_IDX 1
#define CSL_VC_RFIDTAB_ACCESS_VC_IDX 2

@interface CSLTabVC : UITabBarController <UITabBarControllerDelegate>
{
    int m_SelectedTabView;
}

- (void)setActiveView:(int)identifier;
- (void)setConfigurationsForTags;
- (void)setAntennaPortsAndPowerForTags;
- (void) setAntennaPortsAndPowerForTagAccess;
@end
