//
//  CSLDeviceTV.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

@interface CSLDeviceTV : UITableViewController <UITableViewDelegate,CSLBleScanDelegate>
{
    
    IBOutlet UITableView *tblDeviceList;
    __weak IBOutlet UIActivityIndicatorView *actSpinner;
    
}


@end
