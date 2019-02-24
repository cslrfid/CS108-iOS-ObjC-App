//
//  CSLMultibankAccessVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 20/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLMultibankAccessVC.h"

@interface CSLMultibankAccessVC ()

@end

@implementation CSLMultibankAccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnMultibank1Select.layer.borderWidth=1.0f;
    self.btnMultibank1Select.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnMultibank1Select.layer.cornerRadius=5.0f;
    self.btnMultibank2Select.layer.borderWidth=1.0f;
    self.btnMultibank2Select.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnMultibank2Select.layer.cornerRadius=5.0f;
    self.btnMultibankSave.layer.borderWidth=1.0f;
    self.btnMultibankSave.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnMultibankSave.layer.cornerRadius=5.0f;
    
    [self.txtMultibank1Offset setDelegate:self];
    [self.txtMultibank1Size setDelegate:self];
    [self.txtMultibank2Offset setDelegate:self];
    [self.txtMultibank2Size setDelegate:self];

}

- (void)viewWillAppear:(BOOL)animated {
    
    //reload previously stored settings
    [[CSLRfidAppEngine sharedAppEngine] reloadMQTTSettingsFromUserDefaults];
    
    //refresh UI with stored values
    [self.swEnableMultibank1 setOn:[CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled];
    switch([CSLRfidAppEngine sharedAppEngine].settings.multibank1) {
        case RESERVED :
            [self.btnMultibank1Select setTitle:@"RESERVED" forState:UIControlStateNormal];
            break;
        case EPC :
            [self.btnMultibank1Select setTitle:@"EPC" forState:UIControlStateNormal];
            break;
        case TID :
            [self.btnMultibank1Select setTitle:@"TID" forState:UIControlStateNormal];
            break;
        case USER :
            [self.btnMultibank1Select setTitle:@"USER" forState:UIControlStateNormal];
            break;
    }
    self.txtMultibank1Offset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset];
    self.txtMultibank1Size.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length];
    [self.swEnableMultibank2 setOn:[CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled];
    switch([CSLRfidAppEngine sharedAppEngine].settings.multibank2) {
        case RESERVED :
            [self.btnMultibank2Select setTitle:@"RESERVED" forState:UIControlStateNormal];
            break;
        case EPC :
            [self.btnMultibank2Select setTitle:@"EPC" forState:UIControlStateNormal];
            break;
        case TID :
            [self.btnMultibank2Select setTitle:@"TID" forState:UIControlStateNormal];
            break;
        case USER :
            [self.btnMultibank2Select setTitle:@"USER" forState:UIControlStateNormal];
            break;
    }
    self.txtMultibank2Offset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset];
    self.txtMultibank2Size.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length];
    
    if (![self.swEnableMultibank1 isOn]) {
        [self.btnMultibank1Select setEnabled:false];
        [self.txtMultibank1Offset setEnabled:false];
        [self.txtMultibank1Size setEnabled:false];
        [self.swEnableMultibank2 setHidden:true];
        [self.btnMultibank2Select setHidden:true];
        [self.txtMultibank2Offset setHidden:true];
        [self.txtMultibank2Size setHidden:true];
        [self.lbBank setHidden:true];
        [self.lbOffset setHidden:true];
        [self.lbSize setHidden:true];
    }
    else {
        [self.btnMultibank1Select setEnabled:true];
        [self.txtMultibank1Offset setEnabled:true];
        [self.txtMultibank1Size setEnabled:true];
        [self.swEnableMultibank2 setHidden:false];
        [self.btnMultibank2Select setHidden:false];
        [self.txtMultibank2Offset setHidden:false];
        [self.txtMultibank2Size setHidden:false];
        [self.lbBank setHidden:false];
        [self.lbOffset setHidden:false];
        [self.lbSize setHidden:false];
    }
    if (![self.swEnableMultibank2 isOn]) {
        [self.btnMultibank2Select setEnabled:false];
        [self.txtMultibank2Offset setEnabled:false];
        [self.txtMultibank2Size setEnabled:false];
    }
    else {
        [self.btnMultibank2Select setEnabled:true];
        [self.txtMultibank2Offset setEnabled:true];
        [self.txtMultibank2Size setEnabled:true];
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

- (IBAction)swEnableMultibank1Pressed:(id)sender {
    if (![self.swEnableMultibank1 isOn]) {
        [self.btnMultibank1Select setEnabled:false];
        [self.txtMultibank1Offset setEnabled:false];
        [self.txtMultibank1Size setEnabled:false];
        [self.swEnableMultibank2 setHidden:true];
        [self.btnMultibank2Select setHidden:true];
        [self.txtMultibank2Offset setHidden:true];
        [self.txtMultibank2Size setHidden:true];
        [self.lbBank setHidden:true];
        [self.lbOffset setHidden:true];
        [self.lbSize setHidden:true];
    }
    else {
        [self.btnMultibank1Select setEnabled:true];
        [self.txtMultibank1Offset setEnabled:true];
        [self.txtMultibank1Size setEnabled:true];
        [self.swEnableMultibank2 setHidden:false];
        [self.btnMultibank2Select setHidden:false];
        [self.txtMultibank2Offset setHidden:false];
        [self.txtMultibank2Size setHidden:false];
        [self.lbBank setHidden:false];
        [self.lbOffset setHidden:false];
        [self.lbSize setHidden:false];
    }
}

- (IBAction)btnMultibank1SelectPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Multibank 1"
                                                                   message:@"Please select bank"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *reserved = [UIAlertAction actionWithTitle:@"RESERVED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnMultibank1Select setTitle:@"RESERVED" forState:UIControlStateNormal]; }]; // RESERVED
    UIAlertAction *epc = [UIAlertAction actionWithTitle:@"EPC" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnMultibank1Select setTitle:@"EPC" forState:UIControlStateNormal]; }]; // EPC
    UIAlertAction *tid = [UIAlertAction actionWithTitle:@"TID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnMultibank1Select setTitle:@"TID" forState:UIControlStateNormal]; }]; // TID
    UIAlertAction *user = [UIAlertAction actionWithTitle:@"USER" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnMultibank1Select setTitle:@"USER" forState:UIControlStateNormal]; }]; // USER
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:reserved];
    [alert addAction:epc];
    [alert addAction:tid];
    [alert addAction:user];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)txtMultibank1OffsetPressed:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtMultibank1Offset.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtMultibank1Offset.text intValue] >= 0 && [self.txtMultibank1Offset.text intValue] <= 32) //valid int between 0 to 32
    {
        NSLog(@"Bank1 offset value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtMultibank1Offset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset];
}

- (IBAction)txtMultibank1SizePressed:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtMultibank1Size.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtMultibank1Size.text intValue] >= 0 && [self.txtMultibank1Size.text intValue] <= 32) //valid int between 0 to 32
    {
        NSLog(@"Bank1 size value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtMultibank1Size.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length];
}


- (IBAction)swEnableMultibank2Pressed:(id)sender {
    if (![self.swEnableMultibank2 isOn]) {
        [self.btnMultibank2Select setEnabled:false];
        [self.txtMultibank2Offset setEnabled:false];
        [self.txtMultibank2Size setEnabled:false];
    }
    else {
        [self.btnMultibank2Select setEnabled:true];
        [self.txtMultibank2Offset setEnabled:true];
        [self.txtMultibank2Size setEnabled:true];
    }
}

- (IBAction)btnMultibank2SelectPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Multibank 2"
                                                                   message:@"Please select bank"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *reserved = [UIAlertAction actionWithTitle:@"RESERVED" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               { [self.btnMultibank2Select setTitle:@"RESERVED" forState:UIControlStateNormal]; }]; // RESERVED
    UIAlertAction *epc = [UIAlertAction actionWithTitle:@"EPC" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                          { [self.btnMultibank2Select setTitle:@"EPC" forState:UIControlStateNormal]; }]; // EPC
    UIAlertAction *tid = [UIAlertAction actionWithTitle:@"TID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                          { [self.btnMultibank2Select setTitle:@"TID" forState:UIControlStateNormal]; }]; // TID
    UIAlertAction *user = [UIAlertAction actionWithTitle:@"USER" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                           { [self.btnMultibank2Select setTitle:@"USER" forState:UIControlStateNormal]; }]; // USER
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:reserved];
    [alert addAction:epc];
    [alert addAction:tid];
    [alert addAction:user];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)txtMultibank2OffsetPressed:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtMultibank2Offset.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtMultibank2Offset.text intValue] >= 0 && [self.txtMultibank2Offset.text intValue] <= 32) //valid int between 0 to 32
    {
        NSLog(@"Bank2 offset value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtMultibank2Offset.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset];
}

- (IBAction)txtMultibank2SizePressed:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:self.txtMultibank2Size.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [self.txtMultibank2Size.text intValue] >= 0 && [self.txtMultibank2Size.text intValue] <= 32) //valid int between 0 to 32
    {
        NSLog(@"Bank2 size value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        self.txtMultibank2Size.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length];
}

- (IBAction)btnMultibankSavePressed:(id)sender {
    //store the UI input to the settings object on appEng
    [CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled=self.swEnableMultibank1.isOn;
    if ([self.btnMultibank1Select.titleLabel.text compare:@"RESERVED"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1 = RESERVED;
    if ([self.btnMultibank1Select.titleLabel.text compare:@"EPC"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1 = EPC;
    if ([self.btnMultibank1Select.titleLabel.text compare:@"TID"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1 = TID;
    if ([self.btnMultibank1Select.titleLabel.text compare:@"USER"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank1 = USER;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset = [self.txtMultibank1Offset.text intValue];
    [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length = [self.txtMultibank1Size.text intValue];
    [CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled=self.swEnableMultibank2.isOn;
    if ([self.btnMultibank2Select.titleLabel.text compare:@"RESERVED"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank2 = RESERVED;
    if ([self.btnMultibank2Select.titleLabel.text compare:@"EPC"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank2 = EPC;
    if ([self.btnMultibank2Select.titleLabel.text compare:@"TID"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank2 = TID;
    if ([self.btnMultibank2Select.titleLabel.text compare:@"USER"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.multibank2 = USER;
    [CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset = [self.txtMultibank2Offset.text intValue];
    [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length = [self.txtMultibank2Size.text intValue];
    
    [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Settings" message:@"Settings saved." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
@end
