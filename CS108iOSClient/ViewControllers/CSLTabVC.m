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


@end
