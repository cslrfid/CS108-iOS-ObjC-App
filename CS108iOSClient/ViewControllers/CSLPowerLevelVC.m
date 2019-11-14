//
//  CSLPowerLevelVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2019-10-31.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLPowerLevelVC.h"
#import "CSLRfidAppEngine.h"

@interface CSLPowerLevelVC ()

@end

@implementation CSLPowerLevelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Power Level";
    // Do any additional setup after loading the view.
    [self.txtNumberOfPowerLevel setDelegate:self];
    int count=1;
    for (UIStackView* sv in self.svPowerLevel)
    {
        [(UITextField*)[sv viewWithTag:10*count+1] setDelegate:self];
        [(UITextField*)[sv viewWithTag:10*count+2] setDelegate:self];
        count++;
    }
    self.btnSetPowerLevel.layer.borderWidth=1.0f;
    self.btnSetPowerLevel.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnSetPowerLevel.layer.cornerRadius=5.0f;
    
    
    //load settings from users defaults
    count=1;
    for (UIStackView* sv in self.svPowerLevel)
    {
        ((UITextField*)[sv viewWithTag:10*count+1]).text=[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[count-1];
        ((UITextField*)[sv viewWithTag:10*count+2]).text=[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[count-1];
        count++;
    }
    
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463) {
        //set # power number level to 4
        self.txtNumberOfPowerLevel.text=@"4";
        //Hide the power level input
        for (UIView* view in self.svNumberOfPowerLevel.subviews) {
            [view setHidden:true];
        }
        //set the text power to port
        for (UILabel* label in self.lbPort1To4) {
            label.text=[label.text stringByReplacingOccurrencesOfString:@"Power" withString:@"Port"];
        }
        
        for (int i=0;i<=3;i++) {
            for (UIView* view in ((UIStackView*)self.svPowerLevel[i]).subviews) {
                [view setHidden:false];
            }
        }
        for (int i=4;i<=15;i++) {
            for (UIView* view in ((UIStackView*)self.svPowerLevel[i]).subviews) {
                [view setHidden:true];
            }
        }
    }
    else {
        //set # power number level to what's in the users defaults
        self.txtNumberOfPowerLevel.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel];
        //Unhide the power level input
        for (UIView* view in self.svNumberOfPowerLevel.subviews) {
            [view setHidden:false];
        }
        //set the text power to port
        for (UILabel* label in self.lbPort1To4) {
            label.text=[label.text stringByReplacingOccurrencesOfString:@"Port" withString:@"Power"];
        }
        //Unhide and hide the correct level
        for (int i=0;i<=[CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel-1;i++) {
            for (UIView* view in ((UIStackView*)self.svPowerLevel[i]).subviews) {
                [view setHidden:false];
            }
        }
        for (int i=[CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel;i<=15;i++) {
            for (UIView* view in ((UIStackView*)self.svPowerLevel[i]).subviews) {
                [view setHidden:true];
            }
        }
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

- (IBAction)txtPowerPressed:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:((UITextField*)sender).text];
    int val;
    if (!([scan scanInt:&val] && [scan isAtEnd] && [((UITextField*)sender).text intValue] >= 0 && [((UITextField*)sender).text intValue] <= 320))
    {
        //invalid input
        ((UITextField*)sender).text=[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[(int)(([sender tag] / 10)-1)];
    }
}

- (IBAction)txtDwellPressed:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:((UITextField*)sender).text];
    int val;
    if (!([scan scanInt:&val] && [scan isAtEnd] && [((UITextField*)sender).text intValue] >= 0 && [((UITextField*)sender).text intValue] <= 65535))
    {
        //invalid input
        ((UITextField*)sender).text=[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[(int)(([sender tag] / 10)-1)];
    }
}

- (IBAction)txtNumberOfPowerLevelPressed:(id)sender {
    int powerLevel=[self.txtNumberOfPowerLevel.text intValue];
    if (powerLevel < 0 || powerLevel > 16)
    {
        self.txtNumberOfPowerLevel.text = [NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel];
        return;
    }
    
    int count=1;
    for (UIStackView* sv in self.svPowerLevel)
    {
        if (powerLevel >= count) {
            for (UIView* view in sv.subviews) {
                [view setHidden:false];
            }
        }
        else {
            for (UIView* view in sv.subviews) {
                [view setHidden:true];
            }
        }
        count++;
    }
}

- (IBAction)btnSetPowerLevelPressed:(id)sender {
    int count=1;

    //store the UI input to the settings object on appEng
    [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel=[self.txtNumberOfPowerLevel.text intValue];
    
    [CSLRfidAppEngine sharedAppEngine].settings.powerLevel=[[NSMutableArray alloc] init];
    [CSLRfidAppEngine sharedAppEngine].settings.dwellTime=[[NSMutableArray alloc] init];
    
    for (UIStackView* sv in self.svPowerLevel) {
        [[CSLRfidAppEngine sharedAppEngine].settings.powerLevel addObject:[(UITextField*)[sv viewWithTag:10*count+1] text]];
        [[CSLRfidAppEngine sharedAppEngine].settings.dwellTime addObject:[(UITextField*)[sv viewWithTag:10*count+2] text]];
        count++;
    }
    
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
