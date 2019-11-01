//
//  CSLAntennaPortVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2019-11-01.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLAntennaPortVC.h"

@interface CSLAntennaPortVC ()

@end

@implementation CSLAntennaPortVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title=@"Antenna Ports";
    
    self.btnAntennaPorts.layer.borderWidth=1.0f;
    self.btnAntennaPorts.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnAntennaPorts.layer.cornerRadius=5.0f;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnAntennaPortsPressed:(id)sender {
}
@end
