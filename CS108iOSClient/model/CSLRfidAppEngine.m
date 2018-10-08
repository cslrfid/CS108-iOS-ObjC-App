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

+ (CSLRfidAppEngine *) sharedAppEngine
{
    @synchronized([CSLRfidAppEngine class])
    {
        if (appEngine == nil)
        {
            [[self alloc] init];
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
        readerInfo = [[CSLReaderInfo alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    
}

-(void)reloadSettingsFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults integerForKey:@"power"])
        settings.power = (int)[defaults integerForKey:@"power"];
    if([defaults integerForKey:@"tagPopulation"])
        settings.tagPopulation = (int)[defaults integerForKey:@"tagPopulation"];
    if([defaults boolForKey:@"isQOverride"])
        settings.isQOverride =[defaults boolForKey:@"isQOverride"];
    if([defaults integerForKey:@"QValue"])
        settings.QValue = (int)[defaults integerForKey:@"QValue"];
    if([defaults integerForKey:@"session"])
        settings.session = (SESSION)[defaults integerForKey:@"session"];
    if([defaults integerForKey:@"target"])
        settings.target = (TARGET)[defaults integerForKey:@"target"];
    if([defaults integerForKey:@"algorithm"])
        settings.algorithm = (QUERYALGORITHM)[defaults integerForKey:@"algorithm"];
    if([defaults integerForKey:@"linkProfile"])
        settings.linkProfile = (LINKPROFILE)[defaults integerForKey:@"linkProfile"];
    if([defaults boolForKey:@"isSoundEnabled"])
        settings.enableSound =[defaults boolForKey:@"isSoundEnabled"];
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
    [defaults synchronize];
    
}

-(void)soundAlert:(SystemSoundID)soundId {
    if(settings.enableSound)
        AudioServicesPlaySystemSound(soundId);
}
@end
