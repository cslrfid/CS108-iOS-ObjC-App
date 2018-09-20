//
//  CSLDeviceTV.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLDeviceTV.h"
#import "CSLRfidAppEngine.h"
#import "CSLSettingsVC.h"
#import <QuartzCore/QuartzCore.h>

@interface CSLDeviceTV ()

@end

@implementation CSLDeviceTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[CSLRfidAppEngine sharedAppEngine].reader startScanDevice];
    
    self.navigationItem.title=@"Search for Devices...";
    
    //timer event on updating UI
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(refreshDeviceList)
                                   userInfo:nil
                                    repeats:YES];
    

}

- (void)refreshDeviceList {
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[CSLRfidAppEngine sharedAppEngine].reader stopScanDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[CSLRfidAppEngine sharedAppEngine].reader.bleDeviceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * deviceName=[[[CSLRfidAppEngine sharedAppEngine].reader.bleDeviceList objectAtIndex:indexPath.row] name];
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:deviceName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceName];
    }
    
    cell.textLabel.text = deviceName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[[CSLRfidAppEngine sharedAppEngine].reader.bleDeviceList objectAtIndex:indexPath.row] name] message:@"Connect to reader selected?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        
        //stop scanning for device
        [[CSLRfidAppEngine sharedAppEngine].reader stopScanDevice];
        //connect to device selected
        [[CSLRfidAppEngine sharedAppEngine].reader connectDevice:[[CSLRfidAppEngine sharedAppEngine].reader.bleDeviceList objectAtIndex:indexPath.row]];
        
        for (int i=0;i<COMMAND_TIMEOUT_5S;i++) { //receive data or time out in 5 seconds
            if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus == CONNECTED)
                break;
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus != CONNECTED) {
            NSLog(@"Failed to connect to reader.");
        }
        else //set device name to singleton object
            [CSLRfidAppEngine sharedAppEngine].reader.deviceName=[[[CSLRfidAppEngine sharedAppEngine].reader.bleDeviceList objectAtIndex:indexPath.row] name];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
