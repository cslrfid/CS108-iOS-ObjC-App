//
//  CSLMQTTSettings.m
//  CS108iOSClient	
//
//  Created by Lam Ka Shun on 8/1/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLMQTTSettings.h"

@implementation CSLMQTTSettings {
    MQTTCFSocketTransport *transport;
    MQTTSession* session;
}

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
        self.mqttStatus=MQTTStatusNotConnected;
        self.publishTopicCounter=0;
    }
    return self;
}

- (void)connectToMQTTBroker:(NSString*)topicToPublish {
    if (self.isMQTTEnabled) {
        transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = self.brokerAddress;
        transport.port = self.brokerPort;
        transport.tls = self.isTLSEnabled;
        
        session = [[MQTTSession alloc] init];
        session.transport = transport;
        session.userName=self.userName;
        session.password=self.password;
        session.keepAliveInterval = 60;
        session.clientId=self.clientId;
        session.willFlag=true;
        session.willMsg=[@"offline" dataUsingEncoding:NSUTF8StringEncoding];
        session.willTopic=[topicToPublish stringByReplacingOccurrencesOfString:@"{deviceId}" withString:session.clientId];
        session.willQoS=self.QoS;
        session.willRetainFlag=self.retained;
        
        [session setDelegate:self];
        [session connectWithConnectHandler:^(NSError *error) {
            if (error == nil) {
                self->_mqttStatus=MQTTStatusConnected;
            }
            else {
                self->_mqttStatus=MQTTStatusError;
            }
        }];
    }
}

- (void)publishData:(NSData*)jsonData onTopic:(NSString*)topic {
    [self->session publishData:jsonData onTopic:topic retain:self.retained qos:self.QoS publishHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Failed sending data to MQTT broker. Error message: %@", error.debugDescription);
        }
        else {
            if (![topic containsString:@"cmnd"]) {
                @synchronized (self) {
                    self.publishTopicCounter++;
                }
            }
        }
    }];
}

- (void)connectionClosed:(MQTTSession *)session {
    self.mqttStatus=MQTTStatusNotConnected;
}
@end
