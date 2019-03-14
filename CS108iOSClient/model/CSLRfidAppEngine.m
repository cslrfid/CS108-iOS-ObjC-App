//
//  CSLRfidAppEngine.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLRfidAppEngine.h"

CSLRfidAppEngine * appEngine;

@interface CSLRfidAppEngine() {

}
@end

@implementation CSLRfidAppEngine

@synthesize reader;
@synthesize readerInfo;
@synthesize settings;
@synthesize tagSelected;
@synthesize isBarcodeMode;
@synthesize MQTTSettings;

+ (CSLRfidAppEngine *) sharedAppEngine
{
    id ret;
    @synchronized([CSLRfidAppEngine class])
    {
        if (appEngine == nil)
        {
            ret=[[self alloc] init];
        }
        
        return appEngine;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([appEngine class])
    {
        NSAssert(appEngine == nil, @"Attempted to allocate a second instance of a singleton.");
        appEngine = [super alloc];
        return appEngine;
    }
    return nil;
}

+(void)destroy
{
    @synchronized([appEngine class])
    {
        if (appEngine != nil)
        {
            appEngine = nil;
        }
    }
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        NSLog(@"----------------------------------------------------------------------");
        NSLog(@"Initialize the CSLBleReader object instance...");
        NSLog(@"----------------------------------------------------------------------");
        reader = [[CSLBleReader alloc] init];
        settings = [[CSLReaderSettings alloc] init];
        [self reloadSettingsFromUserDefaults];
        MQTTSettings = [[CSLMQTTSettings alloc] init];
        [self reloadMQTTSettingsFromUserDefaults];
        readerInfo = [[CSLReaderInfo alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    
}

-(void)reloadSettingsFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"power"])
        settings.power = (int)[defaults integerForKey:@"power"];
    if([defaults objectForKey:@"tagPopulation"])
        settings.tagPopulation = (int)[defaults integerForKey:@"tagPopulation"];
    if([defaults objectForKey:@"isQOverride"])
        settings.isQOverride =[defaults boolForKey:@"isQOverride"];
    if([defaults objectForKey:@"QValue"])
        settings.QValue = (int)[defaults integerForKey:@"QValue"];
    if([defaults objectForKey:@"session"])
        settings.session = (SESSION)[defaults integerForKey:@"session"];
    if([defaults objectForKey:@"target"])
        settings.target = (TARGET)[defaults integerForKey:@"target"];
    if([defaults objectForKey:@"algorithm"])
        settings.algorithm = (QUERYALGORITHM)[defaults integerForKey:@"algorithm"];
    if([defaults objectForKey:@"linkProfile"])
        settings.linkProfile = (LINKPROFILE)[defaults integerForKey:@"linkProfile"];
    if([defaults objectForKey:@"isSoundEnabled"])
        settings.enableSound =[defaults boolForKey:@"isSoundEnabled"];
    if([defaults objectForKey:@"isEnableMultibank1"])
        settings.isMultibank1Enabled =[defaults boolForKey:@"isEnableMultibank1"];
    if([defaults objectForKey:@"multibank1Select"])
        settings.multibank1 = (MEMORYBANK)[defaults integerForKey:@"multibank1Select"];
    if([defaults objectForKey:@"multibank1Offset"])
        settings.multibank1Offset = (Byte)[defaults integerForKey:@"multibank1Offset"];
    if([defaults objectForKey:@"multibank1Size"])
        settings.multibank1Length = (Byte)[defaults integerForKey:@"multibank1Size"];
    if([defaults objectForKey:@"isEnableMultibank2"])
        settings.isMultibank2Enabled =[defaults boolForKey:@"isEnableMultibank2"];
    if([defaults objectForKey:@"multibank2Select"])
        settings.multibank2 = (MEMORYBANK)[defaults integerForKey:@"multibank2Select"];
    if([defaults objectForKey:@"multibank2Offset"])
        settings.multibank2Offset = (Byte)[defaults integerForKey:@"multibank2Offset"];
    if([defaults objectForKey:@"multibank2Size"])
        settings.multibank2Length = (Byte)[defaults integerForKey:@"multibank2Size"];
}
-(void)saveSettingsToUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:settings.power forKey:@"power"];
    [defaults setInteger:settings.tagPopulation forKey:@"tagPopulation"];
    [defaults setBool:settings.isQOverride forKey:@"isQOverride"];
    [defaults setInteger:settings.QValue forKey:@"QValue"];
    [defaults setInteger:settings.session forKey:@"session"];
    [defaults setInteger:settings.target forKey:@"target"];
    [defaults setInteger:settings.algorithm forKey:@"algorithm"];
    [defaults setInteger:settings.linkProfile forKey:@"linkProfile"];
    [defaults setBool:settings.enableSound forKey:@"isSoundEnabled"];
    [defaults setBool:settings.isMultibank1Enabled forKey:@"isEnableMultibank1"];
    [defaults setInteger:settings.multibank1 forKey:@"multibank1Select"];
    [defaults setInteger:settings.multibank1Offset forKey:@"multibank1Offset"];
    [defaults setInteger:settings.multibank1Length forKey:@"multibank1Size"];
    [defaults setBool:settings.isMultibank2Enabled forKey:@"isEnableMultibank2"];
    [defaults setInteger:settings.multibank2 forKey:@"multibank2Select"];
    [defaults setInteger:settings.multibank2Offset forKey:@"multibank2Offset"];
    [defaults setInteger:settings.multibank2Length forKey:@"multibank2Size"];
    [defaults synchronize];
    
}

-(void)reloadMQTTSettingsFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults boolForKey:@"isMQTTEnabled"])
        MQTTSettings.isMQTTEnabled = (BOOL)[defaults boolForKey:@"isMQTTEnabled"];
    if([defaults stringForKey:@"brokerAddress"])
        MQTTSettings.brokerAddress = (NSString*)[defaults stringForKey:@"brokerAddress"];
    if([defaults stringForKey:@"brokerAddress"])
        MQTTSettings.brokerAddress = (NSString*)[defaults stringForKey:@"brokerAddress"];
    if([defaults integerForKey:@"brokerPort"])
        MQTTSettings.brokerPort = (int)[defaults integerForKey:@"brokerPort"];
    if([defaults stringForKey:@"clientId"])
        MQTTSettings.clientId =(NSString*)[defaults stringForKey:@"clientId"];
    if([defaults stringForKey:@"userName"])
        MQTTSettings.userName = (NSString*)[defaults stringForKey:@"userName"];
    if([defaults stringForKey:@"password"])
        MQTTSettings.password = (NSString*)[defaults stringForKey:@"password"];
    if([defaults boolForKey:@"isTLSEnabled"])
        MQTTSettings.isTLSEnabled = (BOOL)[defaults boolForKey:@"isTLSEnabled"];
    if([defaults integerForKey:@"QoS"])
        MQTTSettings.QoS = (int)[defaults integerForKey:@"QoS"];
    if([defaults boolForKey:@"retained"])
        MQTTSettings.retained = (BOOL)[defaults boolForKey:@"retained"];
}
-(void)saveMQTTSettingsToUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:MQTTSettings.isMQTTEnabled forKey:@"isMQTTEnabled"];
    [defaults setObject:MQTTSettings.brokerAddress forKey:@"brokerAddress"];
    [defaults setInteger:MQTTSettings.brokerPort forKey:@"brokerPort"];
    [defaults setObject:MQTTSettings.clientId forKey:@"clientId"];
    [defaults setObject:MQTTSettings.userName forKey:@"userName"];
    [defaults setObject:MQTTSettings.password forKey:@"password"];
    [defaults setBool:MQTTSettings.isTLSEnabled forKey:@"isTLSEnabled"];
    [defaults setInteger:MQTTSettings.QoS forKey:@"QoS"];
    [defaults setBool:MQTTSettings.retained forKey:@"retained"];
    [defaults synchronize];
    
}

-(void)soundAlert:(SystemSoundID)soundId {
    if(settings.enableSound)
        AudioServicesPlaySystemSound(soundId);
}
@end
