//
//  CSLBleTag.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 29/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
Tag data information
 */
@interface CSLBleTag : NSObject 

///Protocol Control bits
@property (assign) int PC;
///EPC data string
@property NSString * EPC;
///TID data string
@property (assign) NSString* TID;
///USER data string
@property (assign) NSString* USER;
///Return RRSI of the tag response
@property (assign) Byte rssi;
///Return timestamp of the tag readtime
@property (assign) NSDate* timestamp;


@end
