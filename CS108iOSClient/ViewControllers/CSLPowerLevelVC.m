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
    
    self.btnSetPowerLevel.layer.borderWidth=1.0f;
    self.btnSetPowerLevel.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.btnSetPowerLevel.layer.cornerRadius=5.0f;
    
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
}

- (IBAction)txtDwellPressed:(id)sender {
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
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
@end
