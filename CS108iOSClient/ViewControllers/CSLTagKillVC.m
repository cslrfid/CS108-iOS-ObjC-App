//
//  CSLTagKillVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-10-30.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import "CSLTagKillVC.h"

@interface CSLTagKillVC ()
{
    bool killCommandAccepted;
}
@end

@implementation CSLTagKillVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnKillTag.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnKillTag.layer.cornerRadius=5.0f;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)txtSelectedEPCEdited:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtSelectedEPC.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtSelectedEPC.text = @"";
    }
}

- (IBAction)txtKillPwdEditied:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtKillPwd.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound) || [self.txtKillPwd.text length] != 8) {
        self.txtKillPwd.text = @"00000000";
    }
}

- (IBAction)btnKillTagPressed:(id)sender {
    
    if ([self.txtSelectedEPC.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Tag Kill" message:@"No EPC Selected" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    BOOL result=true;
    UIAlertController *alert;
    UIAlertAction *ok;
    
    killCommandAccepted=false;
    
    //get kill password
    UInt32 killPwd=0;
    NSScanner* scanner = [NSScanner scannerWithString:[self.txtKillPwd text]];
    [scanner scanHexInt:&killPwd];
    
    [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
    result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryKill:killPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
    
    for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
        if (result && killCommandAccepted)
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    if (result && killCommandAccepted)
        alert = [UIAlertController alertControllerWithTitle:@"Tag Kill" message:@"ACCEPTED" preferredStyle:UIAlertControllerStyleAlert];
    else
        alert = [UIAlertController alertControllerWithTitle:@"Tag Kill" message:@"FAILED" preferredStyle:UIAlertControllerStyleAlert];
    
    [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
    
    ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[CSLRfidAppEngine sharedAppEngine].tagSelected isEqualToString:@""]) {
        self.txtSelectedEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
    }
    
    [self.txtSelectedEPC setDelegate:self];
    [self.txtKillPwd setDelegate:self];
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;

}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    
}
- (void) didReceiveTagAccessData:(CSLBleReader *)sender tagReceived:(CSLBleTag *)tag {
    if ((tag.AccessError == 0xFF) &&
        !tag.CRCError &&
        tag.BackScatterError == 0xFF &&
        !tag.ACKTimeout &&
        !tag.CRCError) {
        killCommandAccepted=true;
    }
}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {

}

- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}



@end
