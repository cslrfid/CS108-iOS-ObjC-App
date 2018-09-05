//
//  ViewController.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 25/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CSLBleReader.h"

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate>

{
    CSLBleReader* reader;
    IBOutlet UIButton *btnConnect;
    IBOutlet UIButton *btnInventory;
    __weak IBOutlet UIActivityIndicatorView *spinner;
    __weak IBOutlet UITableView *tagListing;
    __weak IBOutlet UITextField *txtTagCount;
    __weak IBOutlet UITextField *txtTagRate;
    
    NSDate * tagRangingStartTime;

}

@property (weak, nonatomic) IBOutlet UIPickerView *readerPicker;
@property (weak, nonatomic) IBOutlet UITableView *tagListing;


- (IBAction)connectButtonPressed:(id)sender;
- (IBAction)startInventory:(id)sender;


@end

