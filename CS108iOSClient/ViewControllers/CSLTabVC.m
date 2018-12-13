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



@end
