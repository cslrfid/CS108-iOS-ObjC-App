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

@implementation CSLDeviceTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[CSLRfidAppEngine sharedAppEngine].reader startScanDevice];
    
    self.navigationItem.title=@"Search for Devices...";
    
    [actSpinner stopAnimating];
    
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
    
    NSString * deviceName=[[CSLRfidAppEngine sharedAppEngine].reader.deviceListName objectAtIndex:indexPath.row];
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:deviceName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceName];
    }
    
    cell.textLabel.text = deviceName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[CSLRfidAppEngine sharedAppEngine].reader.deviceListName objectAtIndex:indexPath.row] message:@"Connect to reader selected?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [self->actSpinner startAnimating];
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
        else {
            
            //set device name to singleton object
            [CSLRfidAppEngine sharedAppEngine].reader.deviceName=[[CSLRfidAppEngine sharedAppEngine].reader.deviceListName objectAtIndex:indexPath.row];
            NSString * btFwVersion;
            NSString * slVersion;
            NSString * rfidBoardSn;
            NSString * pcbBoardVersion;
            NSString * rfidFwVersion;
            NSString * appVersion;

            
            //Configure reader
            [[CSLRfidAppEngine sharedAppEngine].reader barcodeReader:true];
            [[CSLRfidAppEngine sharedAppEngine].reader powerOnRfid:false];
            [[CSLRfidAppEngine sharedAppEngine].reader powerOnRfid:true];
            if ([[CSLRfidAppEngine sharedAppEngine].reader getBtFirmwareVersion:&btFwVersion])
                [CSLRfidAppEngine sharedAppEngine].readerInfo.BtFirmwareVersion=btFwVersion;
            if ([[CSLRfidAppEngine sharedAppEngine].reader getSilLabIcVersion:&slVersion])
                [CSLRfidAppEngine sharedAppEngine].readerInfo.SiLabICFirmwareVersion=slVersion;
            if ([[CSLRfidAppEngine sharedAppEngine].reader getRfidBrdSerialNumber:&rfidBoardSn])
                [CSLRfidAppEngine sharedAppEngine].readerInfo.deviceSerialNumber=rfidBoardSn;
            if ([[CSLRfidAppEngine sharedAppEngine].reader getPcBBoardVersion:&pcbBoardVersion])
                [CSLRfidAppEngine sharedAppEngine].readerInfo.pcbBoardVersion=pcbBoardVersion;
            [[CSLRfidAppEngine sharedAppEngine].reader.batteryInfo setPcbVersion:[pcbBoardVersion doubleValue]];
            [[CSLRfidAppEngine sharedAppEngine].reader sendAbortCommand];
            
            if ([[CSLRfidAppEngine sharedAppEngine].reader getRfidFwVersionNumber:&rfidFwVersion])
                [CSLRfidAppEngine sharedAppEngine].readerInfo.RfidFirmwareVersion=rfidFwVersion;

            
            appVersion = [NSString stringWithFormat:@"v%@ Build %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
            [CSLRfidAppEngine sharedAppEngine].readerInfo.appVersion=appVersion;
            
             //read OEM data: to be implemented for getting reader regional settings and parameters
            UInt32 OEMData;
            
            //device country code
            [[CSLRfidAppEngine sharedAppEngine].reader readOEMData:[CSLRfidAppEngine sharedAppEngine].reader atAddr:0x00000002 forData:&OEMData];
            [CSLRfidAppEngine sharedAppEngine].readerInfo.countryCode=OEMData;
            NSLog(@"OEM data address 0x%08X: 0x%08X", 0x02, OEMData);
            //special country version
            [[CSLRfidAppEngine sharedAppEngine].reader readOEMData:[CSLRfidAppEngine sharedAppEngine].reader atAddr:0x0000008E forData:&OEMData];
            [CSLRfidAppEngine sharedAppEngine].readerInfo.specialCountryVerison=OEMData;
            NSLog(@"OEM data address 0x%08X: 0x%08X", 0x8E, OEMData);
            //freqency modification flag
            [[CSLRfidAppEngine sharedAppEngine].reader readOEMData:[CSLRfidAppEngine sharedAppEngine].reader atAddr:0x0000008F forData:&OEMData];
            [CSLRfidAppEngine sharedAppEngine].readerInfo.freqModFlag=OEMData;
            NSLog(@"OEM data address 0x%08X: 0x%08X", 0x8F, OEMData);
            //model code
            [[CSLRfidAppEngine sharedAppEngine].reader readOEMData:[CSLRfidAppEngine sharedAppEngine].reader atAddr:0x000000A4 forData:&OEMData];
            [CSLRfidAppEngine sharedAppEngine].readerInfo.modelCode=OEMData;
            NSLog(@"OEM data address 0x%08X: 0x%08X", 0xA4, OEMData);
            //hopping/fixed frequency
            [[CSLRfidAppEngine sharedAppEngine].reader readOEMData:[CSLRfidAppEngine sharedAppEngine].reader atAddr:0x0000009D forData:&OEMData];
            [CSLRfidAppEngine sharedAppEngine].readerInfo.isFxied=OEMData;
            NSLog(@"OEM data address 0x%08X: 0x%08X", 0x9D, OEMData);

            [CSLRfidAppEngine sharedAppEngine].readerRegionFrequency = [[CSLReaderFrequency alloc] initWithOEMData:[CSLRfidAppEngine sharedAppEngine].readerInfo.countryCode
                                                                                             specialCountryVerison:[CSLRfidAppEngine sharedAppEngine].readerInfo.specialCountryVerison
                                                                                                       FreqModFlag:[CSLRfidAppEngine sharedAppEngine].readerInfo.freqModFlag
                                                                                                         ModelCode:[CSLRfidAppEngine sharedAppEngine].readerInfo.modelCode
                                                                                                           isFixed:[CSLRfidAppEngine sharedAppEngine].readerInfo.isFxied];

            if([CSLRfidAppEngine sharedAppEngine].readerRegionFrequency.TableOfFrequencies[[CSLRfidAppEngine sharedAppEngine].settings.region] == nil) {
                //the region being stored is not valid, reset to default region and frequency channel
                [CSLRfidAppEngine sharedAppEngine].settings.region=[CSLRfidAppEngine sharedAppEngine].readerRegionFrequency.RegionList[0];
                [CSLRfidAppEngine sharedAppEngine].settings.channel=@"0";
                [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
            }
            
            if ([btFwVersion length]>=5)
            {
                if ([[btFwVersion substringToIndex:1] isEqualToString:@"3"]) {
                    //if BT firmware version is greater than v3, it is connecting to CS463
                    [CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber=CS463;
                }
                else {
                    [CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber=CS108;
                    [[CSLRfidAppEngine sharedAppEngine].reader startBatteryAutoReporting];
                }
            }

            
            [self->actSpinner stopAnimating];
        }
        
        
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
