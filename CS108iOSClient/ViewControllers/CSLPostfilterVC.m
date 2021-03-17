//
//  CSLPostfilterVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-03-16.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import "CSLPostfilterVC.h"

@interface CSLPostfilterVC ()

@end

@implementation CSLPostfilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnSave.layer.cornerRadius=5.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.tabBarController setTitle:@"Post-filter"];
    [self.txtMask setDelegate:self];
    [self.txtOffset setDelegate:self];
    self.view.userInteractionEnabled=true;
    
    //reload previously stored settings
    [[CSLRfidAppEngine sharedAppEngine] reloadSettingsFromUserDefaults];
    
    //refresh UI with stored values
    [self.swFilterEnabled setOn:[CSLRfidAppEngine sharedAppEngine].settings.postfilterIsEnabled];
    [self.swNotMatchMask setOn:[CSLRfidAppEngine sharedAppEngine].settings.postfilterIsNotMatchMaskEnabled];
    self.txtMask.text=[NSString stringWithFormat:@"%@", [CSLRfidAppEngine sharedAppEngine].settings.postfilterMask];
    self.txtOffset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.postfilterOffset];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSavePressed:(id)sender {
    [CSLRfidAppEngine sharedAppEngine].settings.postfilterMask = self.txtMask.text;
    [CSLRfidAppEngine sharedAppEngine].settings.postfilterOffset = [self.txtOffset.text intValue];
    [CSLRfidAppEngine sharedAppEngine].settings.postfilterIsNotMatchMaskEnabled = self.swNotMatchMask.isOn;
    [CSLRfidAppEngine sharedAppEngine].settings.postfilterIsEnabled = self.swFilterEnabled.isOn;
    
    [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Settings" message:@"Settings saved." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)txtOffsetChanged:(id)sender {
    //data validatiion
    NSScanner* scan = [NSScanner scannerWithString:self.txtOffset.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtOffset.text intValue] >= 0 && [self.txtOffset.text intValue] <= 255) //valid int between 0 to 255
    {
        NSLog(@"Postfilter offset entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtOffset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.postfilterOffset];
}

- (IBAction)txtMaskChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtMask.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtMask.text=[CSLRfidAppEngine sharedAppEngine].settings.postfilterMask;
    }
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}

@end
