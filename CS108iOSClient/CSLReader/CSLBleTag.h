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
///Return RRSI of the tag response
@property (assign) Byte rssi;

@end
