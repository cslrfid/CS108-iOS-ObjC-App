//
//  CSLTagLockVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 30/12/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLTagLockVC.h"

@interface CSLTagLockVC ()
{
    bool securityCommandAccepted;
}
@end

@implementation CSLTagLockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnEPCSecurity.layer.borderWidth=1.0f;
    self.btnEPCSecurity.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnEPCSecurity.layer.cornerRadius=5.0f;
    self.btnAccPwdSecurity.layer.borderWidth=1.0f;
    self.btnAccPwdSecurity.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnAccPwdSecurity.layer.cornerRadius=5.0f;
    self.btnKillPwdSecurity.layer.borderWidth=1.0f;
    self.btnKillPwdSecurity.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnKillPwdSecurity.layer.cornerRadius=5.0f;
    self.btnTidSecurity.layer.borderWidth=1.0f;
    self.btnTidSecurity.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnTidSecurity.layer.cornerRadius=5.0f;
    self.btnUserSecurity.layer.borderWidth=1.0f;
    self.btnUserSecurity.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnUserSecurity.layer.cornerRadius=5.0f;
    self.btnApplySecurity.layer.borderWidth=1.0f;
    self.btnApplySecurity.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnApplySecurity.layer.cornerRadius=5.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[CSLRfidAppEngine sharedAppEngine].tagSelected isEqualToString:@""]) {
        self.txtSelectedEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
    }
    
    [self.txtSelectedEPC setDelegate:self];
    [self.txtAccessPwd setDelegate:self];
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnApplySecurityPressed:(id)sender {
    @autoreleasepool {
        
        if ([self.txtSelectedEPC.text isEqualToString:@""]) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Tag Security" message:@"No EPC Selected" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        BOOL result=true;
        NSString* validationMsg=@"";
        UIAlertController *alert;
        UIAlertAction *ok;
        UInt32 lockCommandConfigBits;
        
        securityCommandAccepted=false;
        
        //input validation
        if (([[self.txtSelectedEPC text] length] % 4) != 0)
            validationMsg=[validationMsg stringByAppendingString:@"SelectedEPC "];
        if ([[self.txtAccessPwd text] length] != 8 && ([[self.txtSelectedEPC text] length] != 0))
            validationMsg=[validationMsg stringByAppendingString:@"AccessPWD "];
        
        if (![validationMsg isEqualToString:@""]) {
            alert = [UIAlertController alertControllerWithTitle:@"Tag Write" message:[@"Invalid Input: " stringByAppendingString:validationMsg] preferredStyle:UIAlertControllerStyleAlert];
            ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        //get access password
        UInt32 accPwd=0;
        NSScanner* scanner = [NSScanner scannerWithString:[self.txtAccessPwd text]];
        [scanner scanHexInt:&accPwd];
        
        //compose the 20bit security
        lockCommandConfigBits=0;
        if([[self.btnKillPwdSecurity currentTitle] isEqualToString:@"UNLOCK"]) {
            lockCommandConfigBits |= 0xC0000; //b'11000000000000000000
        }
        else if([[self.btnKillPwdSecurity currentTitle] isEqualToString:@"PERM_UNLOCK"]) {
            lockCommandConfigBits |= 0xC0100; //b'11000000000100000000
        }
        else if([[self.btnKillPwdSecurity currentTitle] isEqualToString:@"LOCK"]) {
            lockCommandConfigBits |= 0xC0200; //b'11000000001000000000
        }
        else if([[self.btnKillPwdSecurity currentTitle] isEqualToString:@"PERM_LOCK"]) {
            lockCommandConfigBits |= 0xC0300; //b'11000000001100000000
        }
        
        if([[self.btnAccPwdSecurity currentTitle] isEqualToString:@"UNLOCK"]) {
            lockCommandConfigBits |= 0x30000; //b'00110000000000000000
        }
        else if([[self.btnAccPwdSecurity currentTitle] isEqualToString:@"PERM_UNLOCK"]) {
            lockCommandConfigBits |= 0x30040; //b'00110000000001000000
        }
        else if([[self.btnAccPwdSecurity currentTitle] isEqualToString:@"LOCK"]) {
            lockCommandConfigBits |= 0x30080; //b'00110000000010000000
        }
        else if([[self.btnAccPwdSecurity currentTitle] isEqualToString:@"PERM_LOCK"]) {
            lockCommandConfigBits |= 0x030C0; //b'00110000000011000000
        }
        
        if([[self.btnEPCSecurity currentTitle] isEqualToString:@"UNLOCK"]) {
            lockCommandConfigBits |= 0x0C000; //b'00001100000000000000
        }
        else if([[self.btnEPCSecurity currentTitle] isEqualToString:@"PERM_UNLOCK"]) {
            lockCommandConfigBits |= 0x0C010; //b'00001100000000010000
        }
        else if([[self.btnEPCSecurity currentTitle] isEqualToString:@"LOCK"]) {
            lockCommandConfigBits |= 0x0C020; //b'00001100000000100000
        }
        else if([[self.btnEPCSecurity currentTitle] isEqualToString:@"PERM_LOCK"]) {
            lockCommandConfigBits |= 0x0C030; //b'00001100000000110000
        }
        
        if([[self.btnTidSecurity currentTitle] isEqualToString:@"UNLOCK"]) {
            lockCommandConfigBits |= 0x03000; //b'00000011000000000000
        }
        else if([[self.btnTidSecurity currentTitle] isEqualToString:@"PERM_UNLOCK"]) {
            lockCommandConfigBits |= 0x03004; //b'00000011000000000100
        }
        else if([[self.btnTidSecurity currentTitle] isEqualToString:@"LOCK"]) {
            lockCommandConfigBits |= 0x03008; //b'00000011000000001000
        }
        else if([[self.btnTidSecurity currentTitle] isEqualToString:@"PERM_LOCK"]) {
            lockCommandConfigBits |= 0x0300C; //b'00000011000000001100
        }
        
        if([[self.btnUserSecurity currentTitle] isEqualToString:@"UNLOCK"]) {
            lockCommandConfigBits |= 0x00C00; //b'00000000110000000000
        }
        else if([[self.btnUserSecurity currentTitle] isEqualToString:@"PERM_UNLOCK"]) {
            lockCommandConfigBits |= 0x00C01; //b'00000000110000000001
        }
        else if([[self.btnUserSecurity currentTitle] isEqualToString:@"LOCK"]) {
            lockCommandConfigBits |= 0x00C02; //b'00000000110000000010
        }
        else if([[self.btnUserSecurity currentTitle] isEqualToString:@"PERM_LOCK"]) {
            lockCommandConfigBits |= 0x00C03; //b'00000000110000000011
        }

        result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryLock:lockCommandConfigBits ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
        
        for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
            if (result && securityCommandAccepted)
                break;
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if (result && securityCommandAccepted)
            alert = [UIAlertController alertControllerWithTitle:@"Tag Security" message:@"ACCEPTED" preferredStyle:UIAlertControllerStyleAlert];
        else
            alert = [UIAlertController alertControllerWithTitle:@"Tag Security" message:@"FAILED" preferredStyle:UIAlertControllerStyleAlert];
        
        ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (IBAction)btnEPCSecurityPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EPC"
                                                                   message:@"Please select action"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *unlock = [UIAlertAction actionWithTitle:@"UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnEPCSecurity setTitle:@"UNLOCK" forState:UIControlStateNormal]; }]; // UNLOCK
    UIAlertAction *perm_unlock = [UIAlertAction actionWithTitle:@"PERM_UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnEPCSecurity setTitle:@"PERM_UNLOCK" forState:UIControlStateNormal]; }]; // PERM_UNLOCK
    UIAlertAction *lock = [UIAlertAction actionWithTitle:@"LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               { [self.btnEPCSecurity setTitle:@"LOCK" forState:UIControlStateNormal]; }]; // LOCK
    UIAlertAction *perm_lock = [UIAlertAction actionWithTitle:@"PERM_LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                           { [self.btnEPCSecurity setTitle:@"PERM_LOCK" forState:UIControlStateNormal]; }]; // PERM_LOCK
    UIAlertAction *unchanged = [UIAlertAction actionWithTitle:@"UNCHANGED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnEPCSecurity setTitle:@"UNCHANGED" forState:UIControlStateNormal]; }]; // UNCHANGED
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:unlock];
    [alert addAction:perm_unlock];
    [alert addAction:lock];
    [alert addAction:perm_lock];
    [alert addAction:unchanged];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnAccPwdSecurityPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Access Password"
                                                                   message:@"Please select action"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *unlock = [UIAlertAction actionWithTitle:@"UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnAccPwdSecurity setTitle:@"UNLOCK" forState:UIControlStateNormal]; }]; // UNLOCK
    UIAlertAction *perm_unlock = [UIAlertAction actionWithTitle:@"PERM_UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  { [self.btnAccPwdSecurity setTitle:@"PERM_UNLOCK" forState:UIControlStateNormal]; }]; // PERM_UNLOCK
    UIAlertAction *lock = [UIAlertAction actionWithTitle:@"LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                           { [self.btnAccPwdSecurity setTitle:@"LOCK" forState:UIControlStateNormal]; }]; // LOCK
    UIAlertAction *perm_lock = [UIAlertAction actionWithTitle:@"PERM_LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnAccPwdSecurity setTitle:@"PERM_LOCK" forState:UIControlStateNormal]; }]; // PERM_LOCK
    UIAlertAction *unchanged = [UIAlertAction actionWithTitle:@"UNCHANGED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnAccPwdSecurity setTitle:@"UNCHANGED" forState:UIControlStateNormal]; }]; // UNCHANGED
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:unlock];
    [alert addAction:perm_unlock];
    [alert addAction:lock];
    [alert addAction:perm_lock];
    [alert addAction:unchanged];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnKillPwdSecurityPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Kill Password"
                                                                   message:@"Please select action"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *unlock = [UIAlertAction actionWithTitle:@"UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnKillPwdSecurity setTitle:@"UNLOCK" forState:UIControlStateNormal]; }]; // UNLOCK
    UIAlertAction *perm_unlock = [UIAlertAction actionWithTitle:@"PERM_UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  { [self.btnKillPwdSecurity setTitle:@"PERM_UNLOCK" forState:UIControlStateNormal]; }]; // PERM_UNLOCK
    UIAlertAction *lock = [UIAlertAction actionWithTitle:@"LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                           { [self.btnKillPwdSecurity setTitle:@"LOCK" forState:UIControlStateNormal]; }]; // LOCK
    UIAlertAction *perm_lock = [UIAlertAction actionWithTitle:@"PERM_LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnKillPwdSecurity setTitle:@"PERM_LOCK" forState:UIControlStateNormal]; }]; // PERM_LOCK
    UIAlertAction *unchanged = [UIAlertAction actionWithTitle:@"UNCHANGED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnKillPwdSecurity setTitle:@"UNCHANGED" forState:UIControlStateNormal]; }]; // UNCHANGED
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:unlock];
    [alert addAction:perm_unlock];
    [alert addAction:lock];
    [alert addAction:perm_lock];
    [alert addAction:unchanged];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnTidSecurityPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TID"
                                                                   message:@"Please select action"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *unlock = [UIAlertAction actionWithTitle:@"UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnTidSecurity setTitle:@"UNLOCK" forState:UIControlStateNormal]; }]; // UNLOCK
    UIAlertAction *perm_unlock = [UIAlertAction actionWithTitle:@"PERM_UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  { [self.btnTidSecurity setTitle:@"PERM_UNLOCK" forState:UIControlStateNormal]; }]; // PERM_UNLOCK
    UIAlertAction *lock = [UIAlertAction actionWithTitle:@"LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                           { [self.btnTidSecurity setTitle:@"LOCK" forState:UIControlStateNormal]; }]; // LOCK
    UIAlertAction *perm_lock = [UIAlertAction actionWithTitle:@"PERM_LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnTidSecurity setTitle:@"PERM_LOCK" forState:UIControlStateNormal]; }]; // PERM_LOCK
    UIAlertAction *unchanged = [UIAlertAction actionWithTitle:@"UNCHANGED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnTidSecurity setTitle:@"UNCHANGED" forState:UIControlStateNormal]; }]; // UNCHANGED
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:unlock];
    [alert addAction:perm_unlock];
    [alert addAction:lock];
    [alert addAction:perm_lock];
    [alert addAction:unchanged];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnUserSecurityPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"USER"
                                                                   message:@"Please select action"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *unlock = [UIAlertAction actionWithTitle:@"UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnUserSecurity setTitle:@"UNLOCK" forState:UIControlStateNormal]; }]; // UNLOCK
    UIAlertAction *perm_unlock = [UIAlertAction actionWithTitle:@"PERM_UNLOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  { [self.btnUserSecurity setTitle:@"PERM_UNLOCK" forState:UIControlStateNormal]; }]; // PERM_UNLOCK
    UIAlertAction *lock = [UIAlertAction actionWithTitle:@"LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                           { [self.btnUserSecurity setTitle:@"LOCK" forState:UIControlStateNormal]; }]; // LOCK
    UIAlertAction *perm_lock = [UIAlertAction actionWithTitle:@"PERM_LOCK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnUserSecurity setTitle:@"PERM_LOCK" forState:UIControlStateNormal]; }]; // PERM_LOCK
    UIAlertAction *unchanged = [UIAlertAction actionWithTitle:@"UNCHANGED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                { [self.btnUserSecurity setTitle:@"UNCHANGED" forState:UIControlStateNormal]; }]; // UNCHANGED
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:unlock];
    [alert addAction:perm_unlock];
    [alert addAction:lock];
    [alert addAction:perm_lock];
    [alert addAction:unchanged];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
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
        securityCommandAccepted=true;
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
