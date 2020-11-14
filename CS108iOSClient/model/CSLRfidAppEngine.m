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
@synthesize CSLBleTagSelected;
@synthesize isBarcodeMode;
@synthesize MQTTSettings;
@synthesize temperatureSettings;

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
        temperatureSettings = [[CSLTemperatureTagSettings alloc] init];
        [self reloadTemperatureTagSettingsFromUserDefaults];
        readerInfo = [[CSLReaderInfo alloc] init];
        self.readerRegionFrequency = [[CSLReaderFrequency alloc] init];
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
    if([defaults objectForKey:@"isCustomBatteryReporting"])
        settings.isCustomBatteryReporting =[defaults boolForKey:@"isCustomBatteryReporting"];
    if([defaults objectForKey:@"customBatteryReportingInterval"])
        settings.customBatteryReportingInterval =[defaults doubleForKey:@"customBatteryReportingInterval"];
    
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
    if([defaults objectForKey:@"numberOfPowerLevel"])
        settings.numberOfPowerLevel = (int)[defaults integerForKey:@"numberOfPowerLevel"];
    if([defaults objectForKey:@"powerLevel"])
        settings.powerLevel = (NSMutableArray*)[defaults arrayForKey:@"powerLevel"];
    if([defaults objectForKey:@"dwellTime"])
        settings.dwellTime = (NSMutableArray*)[defaults arrayForKey:@"dwellTime"];
    if([defaults objectForKey:@"isPortEnabled"])
        settings.isPortEnabled = (NSMutableArray*)[defaults arrayForKey:@"isPortEnabled"];
    if([defaults objectForKey:@"tagFocus"])
        settings.tagFocus = (Byte)[defaults integerForKey:@"tagFocus"];
    if([defaults objectForKey:@"FastId"])
        settings.FastId = (Byte)[defaults integerForKey:@"FastId"];
    if([defaults objectForKey:@"rfLnaHighComp"])
        settings.rfLnaHighComp = (Byte)[defaults integerForKey:@"rfLnaHighComp"];
    if([defaults objectForKey:@"rfLna"])
        settings.rfLna = (Byte)[defaults integerForKey:@"rfLna"];
    if([defaults objectForKey:@"ifLna"])
        settings.ifLna = (Byte)[defaults integerForKey:@"ifLna"];
    if([defaults objectForKey:@"ifAgc"])
        settings.ifAgc = (Byte)[defaults integerForKey:@"ifAgc"];
    if([defaults objectForKey:@"region"])
        settings.region = (NSString*)[defaults stringForKey:@"region"];
    if([defaults objectForKey:@"channel"])
        settings.channel = (NSString*)[defaults stringForKey:@"channel"];
    
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
    [defaults setInteger:settings.numberOfPowerLevel forKey:@"numberOfPowerLevel"];
    [defaults setObject:settings.powerLevel forKey:@"powerLevel"];
    [defaults setObject:settings.dwellTime forKey:@"dwellTime"];
    [defaults setObject:settings.isPortEnabled forKey:@"isPortEnabled"];
    [defaults setInteger:settings.tagFocus forKey:@"tagFocus"];
    [defaults setInteger:settings.FastId forKey:@"FastId"];
    [defaults setInteger:settings.rfLnaHighComp forKey:@"rfLnaHighComp"];
    [defaults setInteger:settings.rfLna forKey:@"rfLna"];
    [defaults setInteger:settings.ifLna forKey:@"ifLna"];
    [defaults setInteger:settings.ifAgc forKey:@"ifAgc"];
    [defaults setObject:settings.region forKey:@"region"];
    [defaults setObject:settings.channel forKey:@"channel"];
    [defaults setBool:settings.isCustomBatteryReporting forKey:@"isCustomBatteryReporting"];
    [defaults setDouble:settings.customBatteryReportingInterval forKey:@"customBatteryReportingInterval"];
    
    [defaults synchronize];
    
}

-(void)reloadMQTTSettingsFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"isMQTTEnabled"])
        MQTTSettings.isMQTTEnabled = (BOOL)[defaults boolForKey:@"isMQTTEnabled"];
    if([defaults objectForKey:@"brokerAddress"])
        MQTTSettings.brokerAddress = (NSString*)[defaults stringForKey:@"brokerAddress"];
    if([defaults objectForKey:@"brokerAddress"])
        MQTTSettings.brokerAddress = (NSString*)[defaults stringForKey:@"brokerAddress"];
    if([defaults objectForKey:@"brokerPort"])
        MQTTSettings.brokerPort = (int)[defaults integerForKey:@"brokerPort"];
    if([defaults objectForKey:@"clientId"])
        MQTTSettings.clientId =(NSString*)[defaults stringForKey:@"clientId"];
    if([defaults objectForKey:@"userName"])
        MQTTSettings.userName = (NSString*)[defaults stringForKey:@"userName"];
    if([defaults objectForKey:@"password"])
        MQTTSettings.password = (NSString*)[defaults stringForKey:@"password"];
    if([defaults objectForKey:@"isTLSEnabled"])
        MQTTSettings.isTLSEnabled = (BOOL)[defaults boolForKey:@"isTLSEnabled"];
    if([defaults objectForKey:@"QoS"])
        MQTTSettings.QoS = (int)[defaults integerForKey:@"QoS"];
    if([defaults objectForKey:@"retained"])
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

-(void)reloadTemperatureTagSettingsFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if([defaults objectForKey:@"isTemperatureAlertEnabled"])
        temperatureSettings.isTemperatureAlertEnabled = (BOOL)[defaults boolForKey:@"isTemperatureAlertEnabled"];
    if([defaults objectForKey:@"temperatureAlertLowerLimit"])
        temperatureSettings.temperatureAlertLowerLimit = (double)[defaults doubleForKey:@"temperatureAlertLowerLimit"];
    if([defaults objectForKey:@"temperatureAlertUpperLimit"])
        temperatureSettings.temperatureAlertUpperLimit = (double)[defaults doubleForKey:@"temperatureAlertUpperLimit"];
    if([defaults objectForKey:@"rssiLowerLimit"])
        temperatureSettings.rssiLowerLimit = (int)[defaults integerForKey:@"rssiLowerLimit"];
    if([defaults objectForKey:@"rssiUpperLimit"])
        temperatureSettings.rssiUpperLimit = (int)[defaults integerForKey:@"rssiUpperLimit"];
    if([defaults objectForKey:@"NumberOfRollingAvergage"])
        temperatureSettings.NumberOfRollingAvergage = (UInt32)[defaults integerForKey:@"NumberOfRollingAvergage"];
    if([defaults objectForKey:@"temperatureUnit"])
        temperatureSettings.unit = (BOOL)[defaults boolForKey:@"temperatureUnit"];
    if([defaults objectForKey:@"sensorType"])
        temperatureSettings.sensorType = (SENSORTYPE)[defaults integerForKey:@"sensorType"];
    if([defaults objectForKey:@"reading"])
        temperatureSettings.reading = (BOOL)[defaults boolForKey:@"reading"];
    if([defaults objectForKey:@"powerLevel"])
        temperatureSettings.powerLevel = (POWERLEVEL)[defaults integerForKey:@"powerLevel"];
    if([defaults objectForKey:@"tagIdFormat"])
        temperatureSettings.tagIdFormat = (TAGIDFORMAT)[defaults boolForKey:@"tagIdFormat"];
    if([defaults objectForKey:@"moistureAlertCondition"])
        temperatureSettings.moistureAlertCondition = (BOOL)[defaults boolForKey:@"moistureAlertCondition"];
    if([defaults objectForKey:@"moistureAlertValue"])
        temperatureSettings.moistureAlertValue = (int)[defaults integerForKey:@"moistureAlertValue"];
}
-(void)saveTemperatureTagSettingsToUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:temperatureSettings.isTemperatureAlertEnabled forKey:@"isTemperatureAlertEnabled"];
    [defaults setDouble:temperatureSettings.temperatureAlertLowerLimit forKey:@"temperatureAlertLowerLimit"];
    [defaults setDouble:temperatureSettings.temperatureAlertUpperLimit forKey:@"temperatureAlertUpperLimit"];
    [defaults setInteger:temperatureSettings.rssiLowerLimit forKey:@"rssiLowerLimit"];
    [defaults setInteger:temperatureSettings.rssiUpperLimit forKey:@"rssiUpperLimit"];
    [defaults setInteger:temperatureSettings.NumberOfRollingAvergage forKey:@"NumberOfRollingAvergage"];
    [defaults setInteger:temperatureSettings.unit forKey:@"temperatureUnit"];
    [defaults setInteger:temperatureSettings.sensorType forKey:@"sensorType"];
    [defaults setBool:temperatureSettings.reading forKey:@"reading"];
    [defaults setInteger:temperatureSettings.powerLevel forKey:@"powerLevel"];
    [defaults setBool:temperatureSettings.tagIdFormat forKey:@"tagIdFormat"];
    [defaults setBool:temperatureSettings.moistureAlertCondition forKey:@"moistureAlertCondition"];
    [defaults setInteger:temperatureSettings.moistureAlertValue forKey:@"moistureAlertValue"];
    
    [defaults synchronize];
    
}

-(void)soundAlert:(SystemSoundID)soundId {
    if(settings.enableSound)
        AudioServicesPlaySystemSound(soundId);
}
@end
