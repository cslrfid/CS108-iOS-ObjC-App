//
//  CSLMQTTSettings.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 8/1/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSLMQTTSettings : NSObject

///MQTT enable/disable
@property (assign) BOOL isMQTTEnabled;
///MQTT broker address
@property NSString* brokerAddress;
///MQTT broker port
@property (assign) int brokerPort;
///Client ID
@property NSString* clientId;
///User Name for server authentication
@property NSString* userName;
///Password for server authentication
@property NSString* password;
///Enable TLS Encryption (assume using CA signed server certificate)
@property (assign) BOOL isTLSEnabled;
///LWT setting - QoS value
@property (assign) int QoS;
///LWT setting - retaind messages
@property (assign) BOOL retained;


@end

NS_ASSUME_NONNULL_END
