//
//  CSLBleTag.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 29/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSLBleTag : NSObject
{
    int PC;
    NSString * EPC;
    Byte rssi;
    
}

@property int PC;
@property NSString * EPC;
@property Byte rssi;

@end
