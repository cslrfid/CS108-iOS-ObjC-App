//
//  CSLHomeVC.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSLHomeVC : UIViewController
{
    
}

- (IBAction)btnInventoryPressed:(id)sender;
- (IBAction)btnSettingsPressed:(id)sender;
- (IBAction)btnConnectReaderPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnConnectReader;
@property (weak, nonatomic) IBOutlet UILabel *lbConnectReader;

@end
