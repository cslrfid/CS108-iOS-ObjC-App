//
//  CSLTagAccessController.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 16/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLTagAccessVC.h"

@interface CSLTagAccessVC()

@end

@implementation CSLTagAccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [self.tabBarController setTitle:@"Access Control"];
    
    self.btnRead.layer.borderWidth=1.0f;
    self.btnRead.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnWrite.layer.borderWidth=1.0f;
    self.btnWrite.layer.borderColor=[UIColor lightGrayColor].CGColor;
 
    if (![[CSLRfidAppEngine sharedAppEngine].tagSelected isEqualToString:@""]) {
        self.txtSelectedEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)swPCPressed:(id)sender {
}

- (IBAction)swEPCPressed:(id)sender {
}
- (IBAction)swAccPwdPressed:(id)sender {
}
- (IBAction)swKillPwdPressed:(id)sender {
}
- (IBAction)swTidUidPressed:(id)sender {
}
- (IBAction)swUserPressed:(id)sender {
}

- (IBAction)btnTidUidOffsetPressed:(id)sender {
}

- (IBAction)btnTidUidWordPressed:(id)sender {
}

- (IBAction)btnUserOffsetPressed:(id)sender {
}
- (IBAction)btnUserWordPressed:(id)sender {
}

- (IBAction)btnReadPressed:(id)sender {
}

- (IBAction)btnWritePressed:(id)sender {
}

- (IBAction)txtSelectedEPCChanged:(id)sender {
}

- (IBAction)txtAccessPwdChanged:(id)sender {
}

- (IBAction)txtPCChanged:(id)sender {
}

- (IBAction)txtEPCChanged:(id)sender {
}

- (IBAction)txtAccPwdChanged:(id)sender {
}

- (IBAction)txtKillPwdChanged:(id)sender {
}

- (IBAction)txtTidUidChanged:(id)sender {
}

- (IBAction)txtUserChanged:(id)sender {
}
 

@end
