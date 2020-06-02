//
//  CSLInventoryVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"
#import "CSLTagListCell.h"
#import "CSLTabVC.h"

@interface CSLInventoryVC : UIViewController<CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate, MQTTSessionDelegate> {
    NSDate * tagRangingStartTime;
   
}
@property (weak, nonatomic) IBOutlet UILabel *lbTagCount;
@property (weak, nonatomic) IBOutlet UILabel *lbTagRate;
@property (weak, nonatomic) IBOutlet UILabel *lbUniqueTagRate;
@property (weak, nonatomic) IBOutlet UIButton *btnInventory;
@property (weak, nonatomic) IBOutlet UITableView *tblTagList;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *lbClear;
@property (weak, nonatomic) IBOutlet UILabel *lbMode;
@property (weak, nonatomic) IBOutlet UIView *uivSendTagData;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInventorySpinner;
@property (weak, nonatomic) IBOutlet UILabel *lbElapsedTime;

- (IBAction)btnInventoryPressed:(id)sender;
- (IBAction)btnClearTable:(id)sender;
- (IBAction)btnSendTagData:(id)sender;
- (IBAction)btnSaveData:(id)sender;



@end
