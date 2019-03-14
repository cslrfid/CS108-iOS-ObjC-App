//
//  CSLMQTTSettings.m
//  CS108iOSClient	
//
//  Created by Lam Ka Shun on 8/1/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLMQTTSettings.h"

@implementation CSLMQTTSettings

-(id)init {
    if (self = [super init])  {
        //set default values
        self.isMQTTEnabled=false;
        self.brokerAddress=@"";
        self.brokerPort=1883;
        self.clientId=@"CS108Reader1";
        self.userName = @"";
        self.password =@"";
        self.isTLSEnabled = true;
        self.QoS = 1;
        self.retained=false;
    }
    return self;
}
@end
