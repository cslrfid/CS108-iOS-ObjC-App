//
//  CSLTabVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLTabVC.h"

@implementation CSLTabVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
}

- (void)setActiveView:(int)identifier
{
    [self setSelectedViewController:[[self viewControllers] objectAtIndex:identifier]];
    m_SelectedTabView = identifier;
}

-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self setSelectedViewController:[[self viewControllers] objectAtIndex:tabBarController.selectedIndex]];
    m_SelectedTabView = (int)tabBarController.selectedIndex;
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = [[self viewControllers] objectAtIndex:tabBarController.selectedIndex];
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate= [[self viewControllers] objectAtIndex:tabBarController.selectedIndex];
    
}

- (BOOL)  tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    NSUInteger controllerIndex = [self.viewControllers indexOfObject:viewController];
    if (controllerIndex == tabBarController.selectedIndex) {
        return NO;
    }
    else {
        [(UIActivityIndicatorView*)[[[self selectedViewController] view] viewWithTag:99] startAnimating];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
        [[self selectedViewController] view].userInteractionEnabled=false;
    }
    
    // Get the views.
    UIView *fromView = tabBarController.selectedViewController.view;
    UIView *toView = [tabBarController.viewControllers[controllerIndex] view];
    
    // Get the size of the view area.
    CGRect viewSize = fromView.frame;
    BOOL scrollRight = controllerIndex > tabBarController.selectedIndex;
    
    // Add the to view to the tab bar view.
    [fromView.superview addSubview:toView];
    
    // Position it off screen.
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    toView.frame = CGRectMake((scrollRight ? screenWidth : -screenWidth), viewSize.origin.y, screenWidth, viewSize.size.height);
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         // Animate the views on and off the screen. This will appear to slide.
                         fromView.frame = CGRectMake((scrollRight ? -screenWidth : screenWidth), viewSize.origin.y, screenWidth, viewSize.size.height);
                         toView.frame = CGRectMake(0, viewSize.origin.y, screenWidth, viewSize.size.height);
                     }
     
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             // Remove the old view from the tabbar view.
                             [fromView removeFromSuperview];
                             tabBarController.selectedIndex = controllerIndex;
                         }
                     }];
    
    return YES;
}
- (void) setAntennaPortsAndPowerForTags {
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        if([CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel == 0) {
            //use global settings
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
            //disable all other ports
            for (int i=1;i<16;i++) {
                [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                              InventoryMode:0
                                                              InventoryAlgo:0
                                                                     StartQ:0
                                                                ProfileMode:0
                                                                    Profile:0
                                                              FrequencyMode:0
                                                           FrequencyChannel:0
                                                               isEASEnabled:0];
            }
        }
        else {
            //iterate through all the power level
            for (int i=0;i<16;i++) {
                int dwell=[[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[i] intValue];
                //enforcing dwell time != 0 when tag focus is enabled
                if ([CSLRfidAppEngine sharedAppEngine].settings.tagFocus) {
                    dwell=2000;
                }
                [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
                NSLog(@"Power level %d: %@", i, (i >= [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel) ? @"OFF" : @"ON");
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:((i >= [CSLRfidAppEngine sharedAppEngine].settings.numberOfPowerLevel) ? FALSE : TRUE)
                                                              InventoryMode:0
                                                              InventoryAlgo:0
                                                                     StartQ:0
                                                                ProfileMode:0
                                                                    Profile:0
                                                              FrequencyMode:0
                                                           FrequencyChannel:0
                                                               isEASEnabled:0];
                [[CSLRfidAppEngine sharedAppEngine].reader setPower:[[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[i] intValue] / 10];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:dwell];
                [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:dwell == 0 ? 65535 : 0];
            }
        }
    }
    else {
        //iterate through all the power level
        for (int i=0;i<4;i++) {
            int dwell=[[CSLRfidAppEngine sharedAppEngine].settings.dwellTime[i] intValue];
            //enforcing dwell time != 0 when tag focus is enabled
            if ([CSLRfidAppEngine sharedAppEngine].settings.tagFocus) {
                dwell=2000;
            }
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            NSLog(@"Antenna %d: %@", i, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue] ? @"ON" : @"OFF");
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue]
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[[CSLRfidAppEngine sharedAppEngine].settings.powerLevel[i] intValue] / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:dwell];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:dwell == 0 ? 65535 : 0];
        }
    }

}

- (void) setAntennaPortsAndPowerForTagAccess {
    
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        //disable power level ramping
        [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                      InventoryMode:0
                                                      InventoryAlgo:0
                                                             StartQ:0
                                                        ProfileMode:0
                                                            Profile:0
                                                      FrequencyMode:0
                                                   FrequencyChannel:0
                                                       isEASEnabled:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        //disable all other ports
        for (int i=1;i<16;i++) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
        }
    }
    else {
        //enable power output on selected port
        for (int i=0;i<4;i++) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            NSLog(@"Antenna %d: %@", i, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue] ? @"ON" : @"OFF");
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:[CSLRfidAppEngine sharedAppEngine].settings.tagAccessPort == i ? true : false
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        }
    }

}

- (void) setAntennaPortsAndPowerForTagSearch {
    
    [[CSLRfidAppEngine sharedAppEngine].reader setAntennaCycle:COMMAND_ANTCYCLE_CONTINUOUS];
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS108) {
        //disable power level ramping
        [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:TRUE
                                                      InventoryMode:0
                                                      InventoryAlgo:0
                                                             StartQ:0
                                                        ProfileMode:0
                                                            Profile:0
                                                      FrequencyMode:0
                                                   FrequencyChannel:0
                                                       isEASEnabled:0];
        [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
        [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        //disable all other ports
        for (int i=1;i<16;i++) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:FALSE
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
        }
    }
    else {
        //enable power output on selected port
        for (int i=0;i<4;i++) {
            [[CSLRfidAppEngine sharedAppEngine].reader selectAntennaPort:i];
            NSLog(@"Antenna %d: %@", i, [(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue] ? @"ON" : @"OFF");
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaConfig:[(NSNumber*)[CSLRfidAppEngine sharedAppEngine].settings.isPortEnabled[i] boolValue]
                                                          InventoryMode:0
                                                          InventoryAlgo:0
                                                                 StartQ:0
                                                            ProfileMode:0
                                                                Profile:0
                                                          FrequencyMode:0
                                                       FrequencyChannel:0
                                                           isEASEnabled:0];
            [[CSLRfidAppEngine sharedAppEngine].reader setPower:[CSLRfidAppEngine sharedAppEngine].settings.power / 10];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaDwell:2000];
            [[CSLRfidAppEngine sharedAppEngine].reader setAntennaInventoryCount:0];
        }
    }

}

- (void) setConfigurationsForTags {

    //set inventory configurations
    //for multiplebank inventory
    Byte tagRead=0;
    if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled && [CSLRfidAppEngine sharedAppEngine].settings.isMultibank2Enabled)
        tagRead=2;
    else if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled)
        tagRead=1;
    else
        tagRead=0;
    
    Byte tagDelay=0;
    if (![CSLRfidAppEngine sharedAppEngine].settings.tagFocus && tagRead) {
        tagDelay=30;
    }

    
    [[CSLRfidAppEngine sharedAppEngine].reader setQueryConfigurations:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? A : [CSLRfidAppEngine sharedAppEngine].settings.target) querySession:[CSLRfidAppEngine sharedAppEngine].settings.session querySelect:ALL];
    [[CSLRfidAppEngine sharedAppEngine].reader selectAlgorithmParameter:[CSLRfidAppEngine sharedAppEngine].settings.algorithm];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters0:[CSLRfidAppEngine sharedAppEngine].settings.QValue maximumQ:15 minimumQ:0 ThresholdMultiplier:4];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters1:0];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryAlgorithmParameters2:([CSLRfidAppEngine sharedAppEngine].settings.target == ToggleAB ? true : false) RunTillZero:false];
    [[CSLRfidAppEngine sharedAppEngine].reader setInventoryConfigurations:[CSLRfidAppEngine sharedAppEngine].settings.algorithm MatchRepeats:0 tagSelect:0 disableInventory:0 tagRead:tagRead crcErrorRead:(tagRead ? 0 : 1) QTMode:0 tagDelay:tagDelay inventoryMode:(tagRead ? 0 : 1)];
    [[CSLRfidAppEngine sharedAppEngine].reader setLinkProfile:[CSLRfidAppEngine sharedAppEngine].settings.linkProfile];
    
    //frequency configurations
    if ([CSLRfidAppEngine sharedAppEngine].readerRegionFrequency.isFixed) {
        [[CSLRfidAppEngine sharedAppEngine].reader SetFixedChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
                                                        RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region
                                                      channelIndex:[[CSLRfidAppEngine sharedAppEngine].settings.channel intValue]];
    }
    else {
        [[CSLRfidAppEngine sharedAppEngine].reader SetHoppingChannel:[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency
                                                          RegionCode:[CSLRfidAppEngine sharedAppEngine].settings.region];
    }
    
    // if multibank read is enabled
    if (tagRead) {
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_BANK:[CSLRfidAppEngine sharedAppEngine].settings.multibank1 acc_bank2:[CSLRfidAppEngine sharedAppEngine].settings.multibank2];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_PTR:([CSLRfidAppEngine sharedAppEngine].settings.multibank2Offset << 16) + [CSLRfidAppEngine sharedAppEngine].settings.multibank1Offset];
        [[CSLRfidAppEngine sharedAppEngine].reader TAGACC_CNT:(tagRead ? [CSLRfidAppEngine sharedAppEngine].settings.multibank1Length : 0) secondBank:(tagRead==2 ? [CSLRfidAppEngine sharedAppEngine].settings.multibank2Length : 0)];
    }
    
    NSLog(@"Tag focus value: %d", [CSLRfidAppEngine sharedAppEngine].settings.tagFocus);
    //Impinj Extension
    [[CSLRfidAppEngine sharedAppEngine].reader setImpinjExtension:[CSLRfidAppEngine sharedAppEngine].settings.tagFocus
                                                           fastId:0
                                                   blockWriteMode:0];
    //LNA settings
    [[CSLRfidAppEngine sharedAppEngine].reader setLNAParameters:[CSLRfidAppEngine sharedAppEngine].reader
                                                  rflnaHighComp:[CSLRfidAppEngine sharedAppEngine].settings.rfLnaHighComp
                                                      rflnaGain:[CSLRfidAppEngine sharedAppEngine].settings.rfLna
                                                      iflnaGain:[CSLRfidAppEngine sharedAppEngine].settings.ifLna
                                                      ifagcGain:[CSLRfidAppEngine sharedAppEngine].settings.ifAgc];
    
}

@end
