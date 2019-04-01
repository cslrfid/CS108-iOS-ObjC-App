//
//  CSLMQTTSettings.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 8/1/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enumeration of MQTT status
 */
typedef NS_ENUM(NSInteger, MQTTStatus) {
    MQTTStatusConnected,
    MQTTStatusNotConnected,
    MQTTStatusError
};

@interface CSLMQTTSettings : NSObject<MQTTSessionDelegate>

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
///MQTT connection status
@property (assign) MQTTStatus mqttStatus;
///MQTT submission counter
@property (assign) int publishTopicCounter;

/** Connect to MQTT broker
 @param topicToPublish Topic to be published for retain message
 */
- (void)connectToMQTTBroker:(NSString*)topicToPublish;
/**
 Pulbish data to a defined topic
 @param jsonData Data to be published in JSON format
 @param topic Topic where the data will be published
 */
- (void)publishData:(NSData*)jsonData onTopic:(NSString*)topic;
@end

NS_ASSUME_NONNULL_END
