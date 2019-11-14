//
//  CSLAntennaPortVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2019-11-01.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLAntennaPortVC.h"
#import "CSLRfidAppEngine.h"

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
    
    int count=0;
    for (UISwitch* sw in self.swAntennaPort) {
        NSLog(@"Switch %d: %@", count, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[count] boolValue] ? @"ON" : @"OFF");
        [sw setOn:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[count] boolValue]];
        count++;
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

- (IBAction)btnAntennaPortsPressed:(id)sender {
    
    int count=0;
    
    [CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled=[[NSMutableArray alloc] init];


    for (UISwitch* sw in self.swAntennaPort) {
        [[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled addObject:[[NSNumber alloc] initWithBool:[sw isOn]]];
        count++;
    }
    
    [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Settings" message:@"Settings saved." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

}
@end
