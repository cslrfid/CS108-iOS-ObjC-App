//
//  CSLFilterTabVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-03-16.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

#define CSL_VC_RFIDTAB_PREFILTER_VC_IDX 0
#define CSL_VC_RFIDTAB_PREFILTER_IDX 1

@interface CSLFilterTabVC : UITabBarController <UITabBarControllerDelegate>
{
    int m_SelectedTabView;
}

- (void)setActiveView:(int)identifier;

@end
