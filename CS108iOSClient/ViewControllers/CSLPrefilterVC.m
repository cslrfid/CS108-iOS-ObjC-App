//
//  CSLPrefilterVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-03-16.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import "CSLPrefilterVC.h"

@interface CSLPrefilterVC ()

@end

@implementation CSLPrefilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnBank.layer.borderWidth=1.0f;
    self.btnBank.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnBank.layer.cornerRadius=5.0f;
    self.btnSave.layer.cornerRadius=5.0f;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated {
    
    [self.tabBarController setTitle:@"Pre-filter"];
    [self.txtMask setDelegate:self];
    [self.txtOffset setDelegate:self];
    self.view.userInteractionEnabled=true;
    
    //reload previously stored settings
    [[CSLRfidAppEngine sharedAppEngine] reloadSettingsFromUserDefaults];
    
    //refresh UI with stored values
    [self.swFilterEnabled setOn:[CSLRfidAppEngine sharedAppEngine].settings.prefilterIsEnabled];
    switch([CSLRfidAppEngine sharedAppEngine].settings.prefilterBank) {
        case RESERVED :
            [self.btnBank setTitle:@"RESERVED" forState:UIControlStateNormal];
            break;
        case EPC :
            [self.btnBank setTitle:@"EPC" forState:UIControlStateNormal];
            break;
        case TID :
            [self.btnBank setTitle:@"TID" forState:UIControlStateNormal];
            break;
        case USER :
            [self.btnBank setTitle:@"USER" forState:UIControlStateNormal];
            break;
    }
    self.txtMask.text=[NSString stringWithFormat:@"%@", [CSLRfidAppEngine sharedAppEngine].settings.prefilterMask];
    self.txtOffset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.prefilterOffset];
    
}

- (IBAction)btnSavePressed:(id)sender {
    [CSLRfidAppEngine sharedAppEngine].settings.prefilterMask = self.txtMask.text;
    [CSLRfidAppEngine sharedAppEngine].settings.prefilterOffset = [self.txtOffset.text intValue];
    if ([self.btnBank.titleLabel.text compare:@"RESERVED"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.prefilterBank = RESERVED;
    if ([self.btnBank.titleLabel.text compare:@"EPC"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.prefilterBank = EPC;
    if ([self.btnBank.titleLabel.text compare:@"TID"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.prefilterBank = TID;
    if ([self.btnBank.titleLabel.text compare:@"USER"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.prefilterBank = USER;
    [CSLRfidAppEngine sharedAppEngine].settings.prefilterIsEnabled = self.swFilterEnabled.isOn;
    
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
        NSLog(@"Prefilter offset entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtOffset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.prefilterOffset];
    
}

- (IBAction)txtMaskChanged:(id)sender {
    
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtMask.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtMask.text=[CSLRfidAppEngine sharedAppEngine].settings.prefilterMask;
    }
}

- (IBAction)btnBankPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pre-filter"
                                                                   message:@"Please select bank"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *reserved = [UIAlertAction actionWithTitle:@"RESERVED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnBank setTitle:@"RESERVED" forState:UIControlStateNormal]; }]; // RESERVED
    UIAlertAction *epc = [UIAlertAction actionWithTitle:@"EPC" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnBank setTitle:@"EPC" forState:UIControlStateNormal]; }]; // EPC
    UIAlertAction *tid = [UIAlertAction actionWithTitle:@"TID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnBank setTitle:@"TID" forState:UIControlStateNormal]; }]; // TID
    UIAlertAction *user = [UIAlertAction actionWithTitle:@"USER" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnBank setTitle:@"USER" forState:UIControlStateNormal]; }]; // USER
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:reserved];
    [alert addAction:epc];
    [alert addAction:tid];
    [alert addAction:user];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}


@end
