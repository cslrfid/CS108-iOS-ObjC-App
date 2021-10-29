//
//  CSLTagAccessController.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 16/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLTagAccessVC.h"
#import "CSLTagLockVC.h"

@interface CSLTagAccessVC()

@end

@implementation CSLTagAccessVC

@synthesize txtSelectedEPC;
@synthesize txtAccessPwd;
@synthesize txtPC;
@synthesize txtEPC;
@synthesize txtAccPwd;
@synthesize txtKillPwd;
@synthesize txtTidUid;
@synthesize txtUser;
@synthesize swPC;
@synthesize swEPC;
@synthesize swAccPwd;
@synthesize swKillPwd;
@synthesize swTidUid;
@synthesize swUser;
@synthesize btnTidUidOffset;
@synthesize btnTidUidWord;
@synthesize btnUserOffset;
@synthesize btnUserWord;
@synthesize btnRead;
@synthesize btnWrite;
@synthesize txtPower;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.btnRead.layer.borderWidth=1.0f;
    self.btnRead.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnRead.layer.cornerRadius=5.0f;
    self.btnWrite.layer.borderWidth=1.0f;
    self.btnWrite.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnWrite.layer.cornerRadius=5.0f;
    self.btnSecurity.layer.borderWidth=1.0f;
    self.btnSecurity.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnSecurity.layer.cornerRadius=5.0f;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    [self.tabBarController setTitle:@"Access Control"];
    
    [self.actTagAccessSpinner stopAnimating];
    self.view.userInteractionEnabled=true;
    
    if (![[CSLRfidAppEngine sharedAppEngine].tagSelected isEqualToString:@""]) {
        self.txtSelectedEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
        self.txtEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
    }
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
    
    [txtSelectedEPC setDelegate:self];
    [txtAccessPwd setDelegate:self];
    [txtPC setDelegate:self];
    [txtEPC setDelegate:self];
    [txtAccPwd setDelegate:self];
    [txtKillPwd setDelegate:self];
    [txtTidUid setDelegate:self];
    [txtUser setDelegate:self];
    [txtPower setDelegate:self];
    
    //hide port selection on CS108
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        [self.lbPort setHidden:true];
        [self.txtPort setHidden:true];
    }
    else {
        [self.lbPort setHidden:false];
        [self.txtPort setHidden:false];
    }
    
    self.txtPower.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.power];
    
    // Do any additional setup after loading the view.
    //[((CSLTabVC*)self.tabBarController) setAntennaPortsAndPowerForTagAccess];
    //[((CSLTabVC*)self.tabBarController) setConfigurationsForTags];
    [CSLReaderConfigurations setAntennaPortsAndPowerForTagAccess:false];
    [CSLReaderConfigurations setConfigurationsForTags];
}

- (void)viewWillDisappear:(BOOL)animated {
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = nil;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=nil;
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
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TID-UID" message:@"Offset" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Offset";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text=[[self.btnTidUidOffset titleLabel].text substringFromIndex:7];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {
                                 UITextField *textField = [alert.textFields firstObject];
                                 if (([textField.text intValue] >= 0 && [textField.text intValue] <= 8) && ![textField.text isEqualToString:@""]) {
                                     textField.text=[NSString stringWithFormat:@"%d",[textField.text intValue]];
                                     [self.btnTidUidOffset setTitle:[NSString stringWithFormat:@"Offset=%@", textField.text] forState:UIControlStateNormal];
                                 }
                             }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    

    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnTidUidWordPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TID-UID" message:@"Word Count" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Word Count";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text=[[self.btnTidUidWord titleLabel].text substringFromIndex:5];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                         {
                             UITextField *textField = [alert.textFields firstObject];
                             if (([textField.text intValue] > 0 && [textField.text intValue] <= 8) && ![textField.text isEqualToString:@""]) {
                                textField.text=[NSString stringWithFormat:@"%d",[textField.text intValue]];
                                [self.btnTidUidWord setTitle:[NSString stringWithFormat:@"Word=%@", textField.text] forState:UIControlStateNormal];
                             }
                         }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnUserOffsetPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"USER" message:@"Offset" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Offset";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text=[[self.btnUserOffset titleLabel].text substringFromIndex:7];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                         {
                             UITextField *textField = [alert.textFields firstObject];
                             if (([textField.text intValue] >= 0 && [textField.text intValue] <= 32) && ![textField.text isEqualToString:@""]) {
                                 textField.text=[NSString stringWithFormat:@"%d",[textField.text intValue]];
                                 [self.btnUserOffset setTitle:[NSString stringWithFormat:@"Offset=%@", textField.text] forState:UIControlStateNormal];
                             }
                         }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
- (IBAction)btnUserWordPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"USER" message:@"Word Count" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Word Count";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text=[[self.btnUserWord titleLabel].text substringFromIndex:5];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                         {
                             UITextField *textField = [alert.textFields firstObject];
                             if (([textField.text intValue] > 0 && [textField.text intValue] <= 32) && ![textField.text isEqualToString:@""]) {
                                 textField.text=[NSString stringWithFormat:@"%d",[textField.text intValue]];
                                 [self.btnUserWord setTitle:[NSString stringWithFormat:@"Word=%@", textField.text] forState:UIControlStateNormal];
                             }
                         }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnReadPressed:(id)sender {

    @autoreleasepool {
        self.btnWrite.enabled=false;
        self.btnSecurity.enabled=false;
        
        BOOL result=true;
        Byte tidWordCount =[[[self.btnTidUidWord titleLabel].text substringFromIndex:5] intValue];
        Byte tidOffset = [[[self.btnTidUidOffset titleLabel].text substringFromIndex:7] intValue];
        Byte userWordCount = [[[self.btnUserWord titleLabel].text substringFromIndex:5] intValue];
        Byte userOffset = [[[self.btnUserOffset titleLabel].text substringFromIndex:7] intValue];
        Byte EPCWordCount = [[self.txtSelectedEPC text] length] / 4;
        
        //clear UI
        //if ([self.swTidUid isOn])
            self.txtTidUid.text=@"";
        //if ([self.swUser isOn])
            self.txtUser.text=@"";
        //if ([self.swEPC isOn])
            self.txtEPC.text=@"";
        //if ([self.swPC isOn])
            self.txtPC.text=@"";
        //if ([self.swAccPwd isOn])
            self.txtAccPwd.text=@"";
        //if ([self.swKillPwd isOn])
            self.txtKillPwd.text=@"";

        [self.txtTidUid setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtUser setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtEPC setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtPC setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        //refresh UI
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
        
        //get access password
        UInt32 accPwd=0;
        NSScanner* scanner = [NSScanner scannerWithString:[self.txtAccessPwd text]];
        [scanner scanHexInt:&accPwd];
        
        //read PC+EPC if TID is not needed.  Otherwise, read PC+EPC+TID all in one shot
        if ([self.swEPC isOn] || [self.swPC isOn] || [self.swTidUid isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=TID;
            if ([self.swTidUid isOn]) {
                result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:TID dataOffset:tidOffset dataCount:tidWordCount ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            }
            else if ([self.swEPC isOn] || [self.swPC isOn]) {
                result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:EPC dataOffset:2 dataCount:EPCWordCount ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            }
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtEPC.text length] != 0 || [self.txtPC.text length] != 0 || [self.txtTidUid.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            if([self.txtEPC.text length] == 0 && [self.swEPC isOn]) {
                [self.txtEPC setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtEPC.text length] != 0 && [self.swEPC isOn]) {
                [self.txtEPC setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
            if([self.txtPC.text length] == 0 && [self.swPC isOn]) {
                [self.txtPC setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtPC.text length] != 0 && [self.swPC isOn]) {
                [self.txtPC setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
            if([self.txtTidUid.text length] == 0 && [self.swTidUid isOn]) {
                [self.txtTidUid setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtTidUid.text length] != 0 && [self.swTidUid isOn]) {
                [self.txtTidUid setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }

        //read access password and kill password
        if ([self.swAccPwd isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=RESERVED;
            memItem=mACCPWD;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:RESERVED dataOffset:2 dataCount:2 ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtAccPwd.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            if([self.txtAccPwd.text length] == 0 && [self.swAccPwd isOn]) {
                [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtAccPwd.text length] != 0 && [self.swAccPwd isOn]) {
                [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        if ([self.swKillPwd isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=RESERVED;
            memItem=mKILLPWD;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:RESERVED dataOffset:0 dataCount:2 ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtKillPwd.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            if([self.txtKillPwd.text length] == 0 && [self.swKillPwd isOn]) {
                [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtKillPwd.text length] != 0 && [self.swKillPwd isOn]) {
                [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        //read USER
        if ([self.swUser isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=USER;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:USER dataOffset:userOffset dataCount:userWordCount ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
        
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtUser.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            if([self.txtUser.text length] == 0 && [self.swUser isOn]) {
                [self.txtUser setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtUser.text length] != 0 && [self.swUser isOn]) {
                [self.txtUser setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tag Read" message:@"Completed" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
        self.btnWrite.enabled=true;
        self.btnSecurity.enabled=true;
        
    }
}

- (IBAction)btnWritePressed:(id)sender {
    @autoreleasepool {
        self.btnRead.enabled=false;
        self.btnSecurity.enabled=false;
        
        BOOL result=true;
        Byte userWordCount = [[[self.btnUserWord titleLabel].text substringFromIndex:5] intValue];
        Byte userOffset = [[[self.btnUserOffset titleLabel].text substringFromIndex:7] intValue];
        Byte tidWordCount = [[[self.btnTidUidWord titleLabel].text substringFromIndex:5] intValue];
        Byte tidOffset = [[[self.btnTidUidOffset titleLabel].text substringFromIndex:7] intValue];
        NSString* validationMsg=@"";
        UIAlertController *alert;
        UIAlertAction *ok;
        
        //input validation
        if ([self.swPC isOn] && [[self.txtPC text] length] != 4)
            validationMsg=[validationMsg stringByAppendingString:@"PC "];
        if ([self.swEPC isOn] && ((([[self.txtEPC text] length] % 4) != 0) || ([[self.txtEPC text] length] == 0)))
            validationMsg=[validationMsg stringByAppendingString:@"EPC "];
        if ([self.swUser isOn] && ([[self.txtUser text] length] != (userWordCount * 4) || ([[self.txtUser text] length] == 0)))
            validationMsg=[validationMsg stringByAppendingString:@"USER "];
        if ([self.swTidUid isOn] && ([[self.txtTidUid text] length] != (tidWordCount * 4) || ([[self.txtTidUid text] length] == 0) || (tidOffset < 2) ))
            validationMsg=[validationMsg stringByAppendingString:@"TID-UID "];
        if ([self.swAccPwd isOn] && [[self.txtAccPwd text] length] != 8)
            validationMsg=[validationMsg stringByAppendingString:@"AccPWD "];
        if ([self.swKillPwd isOn] && [[self.txtKillPwd text] length] != 8)
            validationMsg=[validationMsg stringByAppendingString:@"KillPWD "];
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
        
        //clear UI
        [self.txtTidUid setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtUser setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtEPC setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtPC setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        //refresh UI
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
        
        //get access password
        UInt32 accPwd=0;
        NSScanner* scanner = [NSScanner scannerWithString:[self.txtAccessPwd text]];
        [scanner scanHexInt:&accPwd];
        
        //write PC if it is enabled
        if ([self.swPC isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=EPC;
            memItem=mPC;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:EPC dataOffset:1 dataCount:((UInt32)[self.txtPC text].length / 4) writeData:[CSLBleReader convertHexStringToData:[self.txtPC text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if(![[self.txtPC backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)])
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            //set UI color to red if no tag access reponse returned
            if([[self.txtPC backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)]) {
                [self.txtPC setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        //write EPC if it is enabled
        if ([self.swEPC isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=EPC;
            memItem=mEPC;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:EPC dataOffset:2 dataCount:((UInt32)[self.txtEPC text].length / 4) writeData:[CSLBleReader convertHexStringToData:[self.txtEPC text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if(![[self.txtEPC backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)])
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            //set UI color to red if no tag access reponse returned
            if([[self.txtEPC backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)]) {
                [self.txtEPC setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        //write access password
        if ([self.swAccPwd isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=RESERVED;
            memItem=mACCPWD;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:RESERVED dataOffset:2 dataCount:2 writeData:[CSLBleReader convertHexStringToData:[self.txtAccPwd text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if(![[self.txtAccPwd backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)])
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            //set UI color to red if no tag access reponse returned
            if([[self.txtAccPwd backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)]) {
                [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        //write kill password
        if ([self.swKillPwd isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=RESERVED;
            memItem=mKILLPWD;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:RESERVED dataOffset:0 dataCount:2 writeData:[CSLBleReader convertHexStringToData:[self.txtKillPwd text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if(![[self.txtKillPwd backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)])
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            //set UI color to red if no tag access reponse returned
            if([[self.txtKillPwd backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)]) {
                [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        //write TID (bank2)
        if ([self.swTidUid isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=TID;
            memItem=mTID;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:TID dataOffset:tidOffset dataCount:tidWordCount writeData:[CSLBleReader convertHexStringToData:[self.txtTidUid text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if(![[self.txtTidUid backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)])
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            //set UI color to red if no tag access reponse returned
            if([[self.txtTidUid backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)]) {
                [self.txtTidUid setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        //write USER
        if ([self.swUser isOn]) {
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
            bankSelected=USER;
            memItem=mUSER;
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:USER dataOffset:userOffset dataCount:userWordCount writeData:[CSLBleReader convertHexStringToData:[self.txtUser text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if(![[self.txtUser backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)])
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            //set UI color to red if no tag access reponse returned
            if([[self.txtUser backgroundColor] isEqual:UIColorFromRGB(0xFFFFFF)]) {
                [self.txtUser setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
            //refresh UI
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        
        alert = [UIAlertController alertControllerWithTitle:@"Tag Write" message:@"Completed" preferredStyle:UIAlertControllerStyleAlert];
        ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
        self.btnRead.enabled=true;
        self.btnSecurity.enabled=true;
    }
    
}

- (IBAction)btnSecurityPressed:(id)sender {
    
    CSLTagLockVC* tagLockVC;
    tagLockVC = (CSLTagLockVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_TagLockVC"];
    
    if (tagLockVC != nil)
    {
        [[self navigationController] pushViewController:tagLockVC animated:YES];
    }
    
}

- (IBAction)txtSelectedEPCChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtSelectedEPC.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtSelectedEPC.text = @"";
    }
}

- (IBAction)txtAccessPwdChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtAccessPwd.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound) || [self.txtAccessPwd.text length] != 8) {
        self.txtAccessPwd.text = @"00000000";
    }
    
}

- (IBAction)txtPCChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtPC.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound) || [self.txtPC.text length] != 4) {
        self.txtPC.text = @"";
    }
}

- (IBAction)txtEPCChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtEPC.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtEPC.text = @"";
    }
    
}

- (IBAction)txtAccPwdChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtAccPwd.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound) || [self.txtAccPwd.text length] != 8) {
        self.txtAccPwd.text = @"00000000";
    }
    
}

- (IBAction)txtKillPwdChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtKillPwd.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound) || [self.txtKillPwd.text length] != 8) {
        self.txtKillPwd.text = @"00000000";
    }
}

- (IBAction)txtTidUidChanged:(id)sender {

}

- (IBAction)txtUserChanged:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtUser.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtUser.text = @"";
    }
}

- (IBAction)txtPowerChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtPower.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtPower.text intValue] >= 0 && [self.txtPower.text intValue] <= 320) //valid int between 0 to 320
    {
        NSLog(@"Power value entered: OK");
        [CSLRfidAppEngine sharedAppEngine].settings.power=[self.txtPower.text intValue];
        [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
        
        //set power and port
        if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
        }
        else {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:[CSLRfidAppEngine sharedAppEngine].settings.tagAccessPort];
        }
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
    }
    else    //invalid input.  reset to stored configurations
        self.txtPower.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.power];
    
}

- (IBAction)txtPortChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtPort.text];
    int val; bool isIntValue;
    isIntValue=[scan scanInt:&val];
    if (isIntValue && [scan isAtEnd] && [self.txtPort.text intValue] >= 1 && [self.txtPort.text intValue] <= 4 && [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[val] boolValue]) //valid int between 1 to 4 and port is enabled globally
    {
        NSLog(@"Port value entered: OK");
        [CSLRfidAppEngine sharedAppEngine].settings.tagAccessPort=[self.txtPort.text intValue]-1;
        [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
        
        //set power and port
        if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
        }
        else {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:[CSLRfidAppEngine sharedAppEngine].settings.tagAccessPort];
        }
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
    }
    else    //invalid input.  reset to stored configurations
        self.txtPort.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.tagAccessPort+1];
}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {

}
- (void) didReceiveTagAccessData:(CSLBleReader *)sender tagReceived:(CSLBleTag *)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tag.AccessCommand == READ) {      //read command
            if (self->bankSelected == TID) {
                if (self->swEPC.isOn)
                    self->txtEPC.text=tag.EPC;
                if (self->swPC.isOn)
                    self->txtPC.text=[NSString stringWithFormat:@"%04X", tag.PC];
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError &&
                    self->swTidUid.isOn) {
                    self->txtTidUid.text=[tag.DATA copy];
                }
            }
            else if (self->bankSelected == USER) {
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError &&
                    self->swUser.isOn) {
                        self->txtUser.text=[tag.DATA copy];
                }
            }
            else if (self->bankSelected == RESERVED && self->memItem==mACCPWD) {
                if ([tag.DATA length] == 8 &&
                    (tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    if (self->swAccPwd.isOn)
                        self->txtAccPwd.text=[tag.DATA copy];
                }
            }
            else if (self->bankSelected == RESERVED && self->memItem==mKILLPWD) {
                if ([tag.DATA length] == 8 &&
                    (tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    if (self->swKillPwd.isOn)
                        self->txtKillPwd.text=[tag.DATA copy];
                }
            }
            
        }
        else if (tag.AccessCommand == WRITE) {      //write command
            if (self->bankSelected == EPC && self->memItem == mEPC) {
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    [self.txtEPC setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
                }
            }
            else if (self->bankSelected == EPC && self->memItem == mPC) {
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    [self.txtPC setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
                }
            }
            else if (self->bankSelected == RESERVED && self->memItem == mACCPWD) {
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
                }
            }
            else if (self->bankSelected == RESERVED && self->memItem == mKILLPWD) {
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
                }
            }
            else if (self->bankSelected == USER && self->memItem == mUSER) {
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    [self.txtUser setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
                }
            }
            else if (self->bankSelected == TID && self->memItem == mTID) {
                if ((tag.AccessError == 0xFF) &&
                    !tag.CRCError &&
                    tag.BackScatterError == 0xFF &&
                    !tag.ACKTimeout &&
                    !tag.CRCError) {
                    [self.txtTidUid setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
                }
            }
        }
    });
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
