//
//  CSLHomeVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLHomeVC.h"
#import "CSLSettingsVC.h"
#import "CSLTabVC.h"
#import "CSLInventoryVC.h"


@interface CSLHomeVC ()

@end

@implementation CSLHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnInventoryPressed:(id)sender {
    
    [self showTabInterfaceActiveView:CSL_VC_RFIDTAB_INVENTORY_VC_IDX];
    
}

- (void)showTabInterfaceActiveView:(int)identifier
{
    CSLTabVC * tabVC = (CSLTabVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_TabVC"];
    [tabVC setActiveView:identifier];
    
    if (tabVC != nil)
    {
        [[self navigationController] pushViewController:tabVC animated:YES];
    }
}


- (IBAction)btnSettingsPressed:(id)sender {
     CSLSettingsVC* settingsVC = (CSLSettingsVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SettingsVC"];
    
    if (settingsVC != nil)
    {
        [[self navigationController] pushViewController:settingsVC animated:YES];
    }
    
}
@end
