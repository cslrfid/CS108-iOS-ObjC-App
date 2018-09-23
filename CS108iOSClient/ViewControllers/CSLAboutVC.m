//
//  CSLAboutVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 23/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLAboutVC.h"
#import "CSLRfidAppEngine.h"

@interface CSLAboutVC ()

@end

@implementation CSLAboutVC

@synthesize lbAppVersion;
@synthesize lbBtFirmwareVersion;
@synthesize lbRfidFirmwareVersion;
@synthesize lbSerialNumber;
@synthesize lbSiLabIcFirmwareVersion;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title=@"About";
    
    lbBtFirmwareVersion.text=[CSLRfidAppEngine sharedAppEngine].readerInfo.BtFirmwareVersion;
    lbAppVersion.text=[CSLRfidAppEngine sharedAppEngine].readerInfo.appVersion;
    lbRfidFirmwareVersion.text=[CSLRfidAppEngine sharedAppEngine].readerInfo.RfidFirmwareVersion;
    lbSiLabIcFirmwareVersion.text=[CSLRfidAppEngine sharedAppEngine].readerInfo.SiLabICFirmwareVersion;
    lbSerialNumber.text=[CSLRfidAppEngine sharedAppEngine].readerInfo.deviceSerialNumber;
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

@end
