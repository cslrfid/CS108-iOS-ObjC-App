//
//  CSLMoreFunctionsVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 19/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLMoreFunctionsVC.h"
#import "CSLMQTTClientSettings.h"

@interface CSLMoreFunctionsVC ()

@end

@implementation CSLMoreFunctionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnMultibankPressed:(id)sender {
}

- (IBAction)btnFiltersPressed:(id)sender {
}

- (IBAction)btnMQTTPressed:(id)sender {
    CSLMQTTClientSettings* mqttSettings;
    mqttSettings = (CSLMQTTClientSettings*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_MQTTSettingsVC"];
    
    if (mqttSettings != nil)
    {
        [[self navigationController] pushViewController:mqttSettings animated:YES];
    }
    
}
@end
