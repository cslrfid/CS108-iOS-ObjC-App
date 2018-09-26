//
//  CSLTabVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLTabVC.h"

@implementation CSLTabVC
{

}


- (void)setActiveView:(int)identifier
{
    [self setSelectedViewController:[[self viewControllers] objectAtIndex:identifier]];
    m_SelectedTabView = identifier;
}

@end
