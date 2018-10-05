//
//  CSLRfidAppEngine.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSLBleReader.h"
#import "CSLBleTag.h"
#import "CSLBlePacket.h"
#import "CSLReaderSettings.h"
#import "CSLReaderInfo.h"

@interface CSLRfidAppEngine : NSObject
{
    CSLBleReader* reader;
    CSLReaderSettings* settings;
    CSLReaderInfo* readerInfo;
    NSString* tagSelected;
    BOOL isBarcodeMode;
}
@property CSLBleReader* reader;
@property CSLReaderSettings* settings;
@property CSLReaderInfo* readerInfo;
@property NSString* tagSelected;
@property BOOL isBarcodeMode;

+ (CSLRfidAppEngine *) sharedAppEngine;
+ (id)alloc;
+ (void)destroy;
- (id)init;
- (void)dealloc;

-(void)reloadSettingsFromUserDefaults;
-(void)saveSettingsToUserDefaults;

@end
