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
        self.brokerAddress=@"RFIDHub.azure-devices.net";
        self.brokerPort=8883;
        self.clientId=@"CS108Reader1";
        self.userName = @"RFIDHub.azure-devices.net/CS108Reader1";
        self.password =@"SharedAccessSignature sr=RFIDHub.azure-devices.net%2Fdevices%2FCS108Reader1&sig=xMbKxKHkOSmbB1SO88mIy69lfES%2FlbOse8CkCXc%2Fm3s%3D&se=1562566454";
        self.isTLSEnabled = true;
        self.QoS = 1;
        self.retained=false;
    }
    return self;
}
@end
