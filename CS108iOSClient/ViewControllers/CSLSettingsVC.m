//
//  CSLSettingsVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLSettingsVC.h"

@implementation CSLSettingsVC

@synthesize btnSaveConfig;
@synthesize btnSession;
@synthesize btnAlgorithm;
@synthesize btnLinkProfile;
@synthesize btnQOverride;
@synthesize txtPower;
@synthesize txtQValue;
@synthesize txtTagPopulation;
@synthesize btnTarget;
@synthesize swSound;
@synthesize btnPowerLevel;
@synthesize btnAntennaSettings;
@synthesize btnRfLna;
@synthesize btnIfLna;
@synthesize btnAgcGain;
@synthesize swLnaHighComp;
@synthesize swTagFocus;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title=@"Settings";
    

    btnSaveConfig.layer.borderWidth=1.0f;
    btnSaveConfig.layer.borderColor=[UIColor clearColor].CGColor;
    btnSaveConfig.layer.cornerRadius=5.0f;


    btnSession.layer.borderWidth=1.0f;
    btnSession.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnSession.layer.cornerRadius=5.0f;
    
    btnAlgorithm.layer.borderWidth=1.0f;
    btnAlgorithm.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnAlgorithm.layer.cornerRadius=5.0f;
    
    btnLinkProfile.layer.borderWidth=1.0f;
    btnLinkProfile.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnLinkProfile.layer.cornerRadius=5.0f;

    btnTarget.layer.borderWidth=1.0f;
    btnTarget.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnTarget.layer.cornerRadius=5.0f;
    
    btnPowerLevel.layer.borderWidth=1.0f;
    btnPowerLevel.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnPowerLevel.layer.cornerRadius=5.0f;
    
    btnAntennaSettings.layer.borderWidth=1.0f;
    btnAntennaSettings.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnAntennaSettings.layer.cornerRadius=5.0f;
    
    btnRfLna.layer.borderWidth=1.0f;
    btnRfLna.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnRfLna.layer.cornerRadius=5.0f;
    
    btnIfLna.layer.borderWidth=1.0f;
    btnIfLna.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnIfLna.layer.cornerRadius=5.0f;
    
    btnAgcGain.layer.borderWidth=1.0f;
    btnAgcGain.layer.borderColor=[UIColor lightGrayColor].CGColor;
    btnAgcGain.layer.cornerRadius=5.0f;
    
    [txtQValue setDelegate:self];
    [txtTagPopulation setDelegate:self];
    [txtPower setDelegate:self];
    
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463) {
        [btnAntennaSettings setHidden:false];
    }
    else {
        [btnAntennaSettings setHidden:true];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //reload previously stored settings
    [[CSLRfidAppEngine sharedAppEngine] reloadSettingsFromUserDefaults];
    
    //refresh UI with stored values
    txtPower.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.power];
    txtTagPopulation.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.tagPopulation];
    [btnQOverride setOn:[CSLRfidAppEngine sharedAppEngine].settings.isQOverride];
    txtQValue.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.QValue];
    [swSound setOn:[CSLRfidAppEngine sharedAppEngine].settings.enableSound];
    
    switch([CSLRfidAppEngine sharedAppEngine].settings.target) {
        case A :
            [btnTarget setTitle:@"A" forState:UIControlStateNormal];
            break;
        case B :
            [btnTarget setTitle:@"B" forState:UIControlStateNormal];
            break;
        case ToggleAB :
            [btnTarget setTitle:@"Toggle A/B" forState:UIControlStateNormal];
            break;
    }
    switch([CSLRfidAppEngine sharedAppEngine].settings.session) {
        case S0 :
            [btnSession setTitle:@"S0" forState:UIControlStateNormal];
            break;
        case S1 :
            [btnSession setTitle:@"S1" forState:UIControlStateNormal];
            break;
        case S2 :
            [btnSession setTitle:@"S2" forState:UIControlStateNormal];
            break;
        case S3 :
            [btnSession setTitle:@"S3" forState:UIControlStateNormal];
            break;
    }
    switch([CSLRfidAppEngine sharedAppEngine].settings.algorithm) {
        case FIXEDQ :
            [btnAlgorithm setTitle:@"FixedQ" forState:UIControlStateNormal];
            break;
        case DYNAMICQ :
            [btnAlgorithm setTitle:@"DynamicQ" forState:UIControlStateNormal];
            break;
    }
    switch([CSLRfidAppEngine sharedAppEngine].settings.linkProfile) {
        case MULTIPATH_INTERFERENCE_RESISTANCE :
            [btnLinkProfile setTitle:@"0. Multipath Interference Resistance" forState:UIControlStateNormal];
            break;
        case RANGE_DRM :
            [btnLinkProfile setTitle:@"1. Range/Dense Reader" forState:UIControlStateNormal];
            break;
        case RANGE_THROUGHPUT_DRM :
            [btnLinkProfile setTitle:@"2. Range/Throughput/Dense Reader" forState:UIControlStateNormal];
            break;
        case MAX_THROUGHPUT :
            [btnLinkProfile setTitle:@"3. Max Throughput" forState:UIControlStateNormal];
            break;
    }
    
    if ([CSLRfidAppEngine sharedAppEngine].settings.tagFocus)
        [swTagFocus setOn:true];
    else
        [swTagFocus setOn:false];
    if ([CSLRfidAppEngine sharedAppEngine].settings.rfLnaHighComp)
        [swLnaHighComp setOn:true];
    else
        [swLnaHighComp setOn:false];
    
    switch([CSLRfidAppEngine sharedAppEngine].settings.rfLna) {
        case 0 :
            [btnRfLna setTitle:@"1 dB" forState:UIControlStateNormal];
            break;
        case 2 :
            [btnRfLna setTitle:@"7 dB" forState:UIControlStateNormal];
            break;
        case 3 :
            [btnRfLna setTitle:@"13 dB" forState:UIControlStateNormal];
            break;
    }
    switch([CSLRfidAppEngine sharedAppEngine].settings.ifLna) {
        case 0 :
            [btnIfLna setTitle:@"24 dB" forState:UIControlStateNormal];
            break;
        case 1 :
            [btnIfLna setTitle:@"18 dB" forState:UIControlStateNormal];
            break;
        case 3 :
            [btnIfLna setTitle:@"12 dB" forState:UIControlStateNormal];
            break;
        case 7 :
            [btnIfLna setTitle:@"6 dB" forState:UIControlStateNormal];
            break;
    }
    switch([CSLRfidAppEngine sharedAppEngine].settings.ifAgc) {
        case 0 :
            [btnAgcGain setTitle:@"-12 dB" forState:UIControlStateNormal];
            break;
        case 4 :
            [btnAgcGain setTitle:@"-6 dB" forState:UIControlStateNormal];
            break;
        case 6 :
            [btnAgcGain setTitle:@"0 dB" forState:UIControlStateNormal];
            break;
        case 7 :
            [btnAgcGain setTitle:@"6 dB" forState:UIControlStateNormal];
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSessionPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Session"
                                                                   message:@"Please select session"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *s0 = [UIAlertAction actionWithTitle:@"S0" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnSession setTitle:@"S0" forState:UIControlStateNormal]; }]; // S0
    UIAlertAction *s1 = [UIAlertAction actionWithTitle:@"S1" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnSession setTitle:@"S1" forState:UIControlStateNormal]; }]; // S1
    UIAlertAction *s2 = [UIAlertAction actionWithTitle:@"S2" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnSession setTitle:@"S2" forState:UIControlStateNormal]; }]; // S2
    UIAlertAction *s3 = [UIAlertAction actionWithTitle:@"S3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnSession setTitle:@"S3" forState:UIControlStateNormal]; }]; // S3
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:s0];
    [alert addAction:s1];
    [alert addAction:s2];
    [alert addAction:s3];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnAlgorithmPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Query Algorithm"
                                                                   message:@"Please select algorithm"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *fixedQ = [UIAlertAction actionWithTitle:@"FixedQ" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnAlgorithm setTitle:@"FixedQ" forState:UIControlStateNormal]; }]; // FixedQ
    UIAlertAction *dynamicQ = [UIAlertAction actionWithTitle:@"DynamicQ" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnAlgorithm setTitle:@"DynamicQ" forState:UIControlStateNormal]; }]; // DynamicQ
   
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:fixedQ];
    [alert addAction:dynamicQ];

    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnLinkProfilePressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Link Profile"
                                                                   message:@"Please select profile"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *profile0 = [UIAlertAction actionWithTitle:@"0. Multipath Interference Resistance" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnLinkProfile setTitle:@"0. Multipath Interference Resistance" forState:UIControlStateNormal]; }]; // 0
    UIAlertAction *profile1 = [UIAlertAction actionWithTitle:@"1. Range/Dense Reader" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnLinkProfile setTitle:@"1. Range/Dense Reader" forState:UIControlStateNormal]; }]; // 1
    UIAlertAction *profile2 = [UIAlertAction actionWithTitle:@"2. Range/Throughput/Dense Reader" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnLinkProfile setTitle:@"2. Range/Throughput/Dense Reader" forState:UIControlStateNormal]; }]; // 2
    UIAlertAction *profile3 = [UIAlertAction actionWithTitle:@"3. Max Throughput" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         { [self.btnLinkProfile setTitle:@"3. Max Throughput" forState:UIControlStateNormal]; }]; // 3
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:profile0];
    [alert addAction:profile1];
    [alert addAction:profile2];
    [alert addAction:profile3];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnTargetPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Target"
                                                                   message:@"Please select target"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *A = [UIAlertAction actionWithTitle:@"A" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             { [self.btnTarget setTitle:@"A" forState:UIControlStateNormal]; }]; // A
    UIAlertAction *B = [UIAlertAction actionWithTitle:@"B" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               { [self.btnTarget setTitle:@"B" forState:UIControlStateNormal]; }]; // B
    UIAlertAction *ToggleAB = [UIAlertAction actionWithTitle:@"Toggle A/B" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnTarget setTitle:@"Toggle A/B" forState:UIControlStateNormal]; }]; // Toggle A/B
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:A];
    [alert addAction:B];
    [alert addAction:ToggleAB];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnQOverridePressed:(id)sender {
    
    if([btnQOverride isOn])
        txtQValue.enabled=true;
    else {
        //recalucate Q value based on tag populatioin
        txtQValue.text=[NSString stringWithFormat:@"%d", (int)(log2([txtTagPopulation.text intValue] * 2)+1)];
        txtQValue.enabled=false;
    }
    
}

- (IBAction)txtQValueChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:txtQValue.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [txtQValue.text intValue] >= 0 && [txtQValue.text intValue] <= 15) //valid int between 0 to 15
    {
        NSLog(@"Q value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        txtQValue.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.QValue];
    
}

- (IBAction)txtTagPopulationChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:txtTagPopulation.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [txtTagPopulation.text intValue] >= 1 && [txtTagPopulation.text intValue] <= 8192) //valid int between 1 to 8192
    {
        NSLog(@"Tag population entered: OK");
        //recalucate Q value based on tag populatioin if q override is disabled
        if(![btnQOverride isOn]) {
            txtQValue.text=[NSString stringWithFormat:@"%d", (int)(log2([txtTagPopulation.text intValue] * 2)+1)];
        }
    }
    else    //invalid input.  reset to stored configurations
        txtTagPopulation.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.tagPopulation];
    
}

- (IBAction)txtPowerChanged:(id)sender {
    NSScanner* scan = [NSScanner scannerWithString:txtPower.text];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd] && [txtPower.text intValue] >= 0 && [txtPower.text intValue] <= 300) //valid int between 0 to 300
    {
        NSLog(@"Power value entered: OK");
    }
    else    //invalid input.  reset to stored configurations
        txtPower.text=[NSString stringWithFormat:@"%d", [CSLRfidAppEngine sharedAppEngine].settings.power];
    
}

- (IBAction)btnSaveConfigPressed:(id)sender {
    
    //store the UI input to the settings object on appEng
    [CSLRfidAppEngine sharedAppEngine].settings.power=[txtPower.text intValue];
    [CSLRfidAppEngine sharedAppEngine].settings.tagPopulation=[txtTagPopulation.text intValue];
    [CSLRfidAppEngine sharedAppEngine].settings.isQOverride=btnQOverride.isOn;
    [CSLRfidAppEngine sharedAppEngine].settings.QValue = [txtQValue.text intValue];
    if ([btnTarget.titleLabel.text compare:@"A"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.target = A;
    if ([btnTarget.titleLabel.text compare:@"B"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.target = B;
    if ([btnTarget.titleLabel.text compare:@"Toggle A/B"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.target = ToggleAB;
    if ([btnSession.titleLabel.text compare:@"S0"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.session = S0;
    if ([btnSession.titleLabel.text compare:@"S1"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.session = S1;
    if ([btnSession.titleLabel.text compare:@"S2"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.session = S2;
    if ([btnSession.titleLabel.text compare:@"S3"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.session = S3;
    if ([btnAlgorithm.titleLabel.text compare:@"FixedQ"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.algorithm = FIXEDQ;
    if ([btnAlgorithm.titleLabel.text compare:@"DynamicQ"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.algorithm = DYNAMICQ;
    if ([btnLinkProfile.titleLabel.text compare:@"0. Multipath Interference Resistance"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.linkProfile = MULTIPATH_INTERFERENCE_RESISTANCE;
    if ([btnLinkProfile.titleLabel.text compare:@"1. Range/Dense Reader"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.linkProfile = RANGE_DRM;
    if ([btnLinkProfile.titleLabel.text compare:@"2. Range/Throughput/Dense Reader"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.linkProfile = RANGE_THROUGHPUT_DRM;
    if ([btnLinkProfile.titleLabel.text compare:@"3. Max Throughput"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.linkProfile = MAX_THROUGHPUT;
    [CSLRfidAppEngine sharedAppEngine].settings.enableSound=swSound.isOn;
    
    if (swTagFocus.isOn)
        [CSLRfidAppEngine sharedAppEngine].settings.tagFocus = 1;
    else
        [CSLRfidAppEngine sharedAppEngine].settings.tagFocus = 0;
    
    if (swLnaHighComp.isOn)
        [CSLRfidAppEngine sharedAppEngine].settings.rfLnaHighComp = 1;
    else
        [CSLRfidAppEngine sharedAppEngine].settings.rfLnaHighComp = 0;
    
    if ([btnRfLna.titleLabel.text compare:@"1 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.rfLna = 0;
    if ([btnRfLna.titleLabel.text compare:@"7 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.rfLna = 2;
    if ([btnRfLna.titleLabel.text compare:@"13 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.rfLna = 3;
    
    if ([btnIfLna.titleLabel.text compare:@"24 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifLna = 0;
    if ([btnIfLna.titleLabel.text compare:@"18 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifLna = 1;
    if ([btnIfLna.titleLabel.text compare:@"12 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifLna = 3;
    if ([btnIfLna.titleLabel.text compare:@"6 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifLna = 7;
    
    if ([btnAgcGain.titleLabel.text compare:@"-12 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifAgc = 0;
    if ([btnAgcGain.titleLabel.text compare:@"-6 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifAgc = 4;
    if ([btnAgcGain.titleLabel.text compare:@"0 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifAgc = 6;
    if ([btnAgcGain.titleLabel.text compare:@"6 dB"] == NSOrderedSame)
        [CSLRfidAppEngine sharedAppEngine].settings.ifAgc = 7;
    
    
    [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Settings" message:@"Settings saved." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnPowerLevelPressed:(id)sender {
    
    CSLPowerLevelVC* powerLevelVC;
    powerLevelVC = (CSLPowerLevelVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_PowerLevelVC"];
    
    if (powerLevelVC != nil)
    {
        [[self navigationController] pushViewController:powerLevelVC animated:YES];
    }
    
    
}

- (IBAction)btnAgcGainPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IF-AGC"
                                                                   message:@"Please select"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *dBm12 = [UIAlertAction actionWithTitle:@"-12 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnAgcGain setTitle:@"-12 dB" forState:UIControlStateNormal]; }]; // -12 dB
    UIAlertAction *dBm6 = [UIAlertAction actionWithTitle:@"-6 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnAgcGain setTitle:@"-6 dB" forState:UIControlStateNormal]; }]; // -6 dB
    UIAlertAction *dB0 = [UIAlertAction actionWithTitle:@"0 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnAgcGain setTitle:@"0 dB" forState:UIControlStateNormal]; }]; // 0 dB
    UIAlertAction *dB6 = [UIAlertAction actionWithTitle:@"6 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnAgcGain setTitle:@"6 dB" forState:UIControlStateNormal]; }]; // 6 dB
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:dBm12];
    [alert addAction:dBm6];
    [alert addAction:dB0];
    [alert addAction:dB6];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnIfLnaPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IF-LNA"
                                                                   message:@"Please select"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *dB24 = [UIAlertAction actionWithTitle:@"24 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnIfLna setTitle:@"24 dB" forState:UIControlStateNormal]; }]; // 24 dB
    UIAlertAction *dB18 = [UIAlertAction actionWithTitle:@"18 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnIfLna setTitle:@"18 dB" forState:UIControlStateNormal]; }]; // 18 dB
    UIAlertAction *dB12 = [UIAlertAction actionWithTitle:@"12 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnIfLna setTitle:@"12 dB" forState:UIControlStateNormal]; }]; // 12 dB
    UIAlertAction *dB6 = [UIAlertAction actionWithTitle:@"6 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                        { [self.btnIfLna setTitle:@"6 dB" forState:UIControlStateNormal]; }]; // 6 dB
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:dB24];
    [alert addAction:dB18];
    [alert addAction:dB12];
    [alert addAction:dB6];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnRfLnaPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RF-LNA"
                                                                   message:@"Please select"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *dB1 = [UIAlertAction actionWithTitle:@"1 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                          { [self.btnRfLna setTitle:@"1 dB" forState:UIControlStateNormal]; }]; // 1 dB
    UIAlertAction *dB7 = [UIAlertAction actionWithTitle:@"7 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                          { [self.btnRfLna setTitle:@"7 dB" forState:UIControlStateNormal]; }]; // 7 dB
    UIAlertAction *dB13 = [UIAlertAction actionWithTitle:@"13 dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                          { [self.btnRfLna setTitle:@"13 dB" forState:UIControlStateNormal]; }]; // 13 dB
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // cancel
    
    [alert addAction:dB1];
    [alert addAction:dB7];
    [alert addAction:dB13];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnAntennaSettingsPressed:(id)sender {
    
    CSLAntennaPortVC* antennaPortVC;
    antennaPortVC = (CSLAntennaPortVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_AntennaPortVC"];
    
    if (antennaPortVC != nil)
    {
        [[self navigationController] pushViewController:antennaPortVC animated:YES];
    }
    
}

- (IBAction)btnRadioSettingsPressed:(id)sender {
}

- (IBAction)btnMQTTClientPressed:(id)sender {
    CSLMQTTClientSettings* mqttSettings;
    mqttSettings = (CSLMQTTClientSettings*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_MQTTSettingsVC"];
    
    if (mqttSettings != nil)
    {
        [[self navigationController] pushViewController:mqttSettings animated:YES];
    }
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
