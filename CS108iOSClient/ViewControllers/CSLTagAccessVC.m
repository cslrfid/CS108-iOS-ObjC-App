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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.btnRead.layer.borderWidth=1.0f;
    self.btnRead.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnWrite.layer.borderWidth=1.0f;
    self.btnWrite.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    [self.tabBarController setTitle:@"Access Control"];
    
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
        BOOL result=true;
        Byte tidWordCount =[[[self.btnTidUidWord titleLabel].text substringFromIndex:5] intValue];
        Byte tidOffset = [[[self.btnTidUidOffset titleLabel].text substringFromIndex:7] intValue];
        Byte userWordCount = [[[self.btnUserWord titleLabel].text substringFromIndex:5] intValue];
        Byte userOffset = [[[self.btnUserOffset titleLabel].text substringFromIndex:7] intValue];
        Byte EPCWordCount = [[self.txtSelectedEPC text] length] / 4;
        
        //clear UI
        if ([self.swTidUid isOn])
            self.txtTidUid.text=@"";
        if ([self.swUser isOn])
            self.txtUser.text=@"";
        if ([self.swEPC isOn])
            self.txtEPC.text=@"";
        if ([self.swPC isOn])
            self.txtPC.text=@"";
        if ([self.swAccPwd isOn])
            self.txtAccPwd.text=@"";
        if ([self.swKillPwd isOn])
            self.txtKillPwd.text=@"";

        [self.txtTidUid setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtUser setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtEPC setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtPC setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        
        //get access password
        UInt32 accPwd=0;
        NSScanner* scanner = [NSScanner scannerWithString:[self.txtAccPwd text]];
        [scanner scanHexInt:&accPwd];
        
        bankSelected=TID;
        //read PC+EPC if TID is not needed.  Otherwise, read PC+EPC+TID all in one shot
        if ([self.swEPC isOn] || [self.swPC isOn] || [self.swTidUid isOn]) {
            if ([self.swTidUid isOn]) {
                result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:TID dataOffset:tidOffset dataCount:tidWordCount ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            }
            else if ([self.swEPC isOn] || [self.swPC isOn]) {
                result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:EPC dataOffset:2 dataCount:EPCWordCount ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            }
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtEPC.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
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
        }
        bankSelected=RESERVED;
        //read access password and kill password
        if ([self.swAccPwd isOn] || [self.swKillPwd isOn]) {
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:RESERVED dataOffset:0 dataCount:4 ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtAccPwd.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            if([self.txtAccPwd.text length] == 0 && [self.swAccPwd isOn]) {
                [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtAccPwd.text length] != 0 && [self.swAccPwd isOn]) {
                [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
            if([self.txtKillPwd.text length] == 0 && [self.swKillPwd isOn]) {
                [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtKillPwd.text length] != 0 && [self.swKillPwd isOn]) {
                [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
        }
        
        bankSelected=USER;
        //read USER
        if ([self.swUser isOn]) {
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryRead:USER dataOffset:userOffset dataCount:userWordCount ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
        
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtUser.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            if([self.txtUser.text length] == 0 && [self.swUser isOn]) {
                [self.txtUser setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            } else if ([self.txtUser.text length] != 0 && [self.swUser isOn]) {
                [self.txtUser setBackgroundColor:UIColorFromRGB(0xD1F2EB)];
            }
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tag Read" message:@"Completed" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)btnWritePressed:(id)sender {
    @autoreleasepool {
        BOOL result=true;
        Byte userWordCount = [[[self.btnUserWord titleLabel].text substringFromIndex:5] intValue];
        Byte userOffset = [[[self.btnUserOffset titleLabel].text substringFromIndex:7] intValue];
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
        if ([[self.txtAccPwd text] length] != 8)
            validationMsg=[validationMsg stringByAppendingString:@"AccPWD "];
        if ([[self.txtKillPwd text] length] != 8)
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
        
        //get access password
        UInt32 accPwd=0;
        NSScanner* scanner = [NSScanner scannerWithString:[self.txtAccPwd text]];
        [scanner scanHexInt:&accPwd];
        
        bankSelected=EPC;
        memItem=mPC;
        //write PC if it is enabled
        if ([self.swPC isOn]) {
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:EPC dataOffset:1 dataCount:((UInt32)[self.txtPC text].length / 4) writeData:[CSLBleReader convertHexStringToData:[self.txtPC text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtPC backgroundColor] != UIColorFromRGB(0xFFFFFF))
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            //set UI color to red if no tag access reponse returned
            if([self.txtEPC backgroundColor] == UIColorFromRGB(0xFFFFFF)) {
                [self.txtEPC setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
        }
        
        bankSelected=EPC;
        memItem=mEPC;
        //write EPC if it is enabled
        if ([self.swEPC isOn]) {
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:EPC dataOffset:2 dataCount:((UInt32)[self.txtEPC text].length / 4) writeData:[CSLBleReader convertHexStringToData:[self.txtEPC text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtEPC backgroundColor] != UIColorFromRGB(0xFFFFFF))
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            //set UI color to red if no tag access reponse returned
            if([self.txtEPC backgroundColor] == UIColorFromRGB(0xFFFFFF)) {
                [self.txtEPC setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
        }
        
        bankSelected=RESERVED;
        memItem=mACCPWD;
        //write access password
        if ([self.swAccPwd isOn]) {
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:RESERVED dataOffset:2 dataCount:2 writeData:[CSLBleReader convertHexStringToData:[self.txtAccPwd text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtAccPwd.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            //set UI color to red if no tag access reponse returned
            if([self.txtAccPwd backgroundColor] == UIColorFromRGB(0xFFFFFF)) {
                [self.txtAccPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
        }
        //write kill password
        bankSelected=RESERVED;
        memItem=mKILLPWD;
        if ([self.swKillPwd isOn]) {
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:RESERVED dataOffset:0 dataCount:2 writeData:[CSLBleReader convertHexStringToData:[self.txtKillPwd text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtAccPwd.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            //set UI color to red if no tag access reponse returned
            if([self.txtKillPwd backgroundColor] == UIColorFromRGB(0xFFFFFF)) {
                [self.txtKillPwd setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
        }
        
        bankSelected=USER;
        memItem=mUSER;
        //write USER
        if ([self.swUser isOn]) {
            result=[[CSLRfidAppEngine sharedAppEngine].reader startTagMemoryWrite:USER dataOffset:userOffset dataCount:userWordCount writeData:[CSLBleReader convertHexStringToData:[self.txtUser text]] ACCPWD:accPwd maskBank:EPC maskPointer:32 maskLength:((UInt32)[self.txtSelectedEPC text].length * 4) maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]];
            
            for (int i=0;i<COMMAND_TIMEOUT_5S;i++) {  //receive data or time out in 5 seconds
                if([self.txtUser.text length] != 0)
                    break;
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            //set UI color to red if no tag access reponse returned
            if([self.txtUser backgroundColor] == UIColorFromRGB(0xFFFFFF)) {
                [self.txtUser setBackgroundColor:UIColorFromRGB(0xFFB3B3)];
            }
        }
        
        alert = [UIAlertController alertControllerWithTitle:@"Tag Write" message:@"Completed" preferredStyle:UIAlertControllerStyleAlert];
        ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
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
                if (self->swTidUid.isOn)
                    self->txtTidUid.text=tag.DATA1;
            }
            else if (self->bankSelected == USER) {
                self->txtUser.text=tag.DATA1;
            }
            else if (self->bankSelected == RESERVED) {
                if ([tag.DATA1 length] == 16) {
                    if (self->swKillPwd.isOn)
                        self->txtKillPwd.text=[tag.DATA1 substringToIndex:8];
                    if (self->swAccPwd.isOn)
                        self->txtAccPwd.text=[tag.DATA1 substringFromIndex:8];
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
