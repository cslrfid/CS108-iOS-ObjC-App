//
//  CSLTemperatureReadVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 28/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"
#import "CSLTemperatureTagListCell.h"
#import "CSLTemperatureTabVC.h"
#import "CSLTemperatureTagSettingsVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLTemperatureReadVC : UIViewController<CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate, MQTTSessionDelegate>


@property (weak, nonatomic) IBOutlet UIButton *btnInventory;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectAllTag;
@property (weak, nonatomic) IBOutlet UIButton *btnRemoveAllTag;
@property (weak, nonatomic) IBOutlet UILabel *lbBatteryLevel;
@property (weak, nonatomic) IBOutlet UITableView *tblTagList;
@property (weak, nonatomic) IBOutlet UILabel *lbTagCount;
@property (weak, nonatomic) IBOutlet UILabel *lbInventory;

- (IBAction)btnInventoryPressed:(id)sender;
- (IBAction)btnSelectAllTagPressed:(id)sender;
- (IBAction)btnRemoveAllTagPressed:(id)sender;
- (IBAction)uivInventoryPressed:(id)sender;
- (IBAction)uivRemoveAllTagPressed:(id)sender;
- (IBAction)uivSelectAllTagPressed:(id)sender;

- (void)buttonForDetailsClicked:(UIButton*)sender;

@end

NS_ASSUME_NONNULL_END
