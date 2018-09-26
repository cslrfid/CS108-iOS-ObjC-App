//
//  CSLInventoryVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

@interface CSLInventoryVC : UIViewController<CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    __weak IBOutlet UILabel *lbTagCount;
    __weak IBOutlet UILabel *lbTagRate;
    __weak IBOutlet UILabel *lbUniqueTagRate;
    __weak IBOutlet UIButton *btnInventory;
    __weak IBOutlet UITableView *tblTagList;
    
    NSDate * tagRangingStartTime;
   
}
@property (weak, nonatomic) IBOutlet UILabel *lbTagCount;
@property (weak, nonatomic) IBOutlet UILabel *lbTagRate;
@property (weak, nonatomic) IBOutlet UILabel *lbUniqueTagRate;
@property (weak, nonatomic) IBOutlet UIButton *btnInventory;
@property (weak, nonatomic) IBOutlet UITableView *tblTagList;

- (IBAction)btnInventoryPressed:(id)sender;



@end
