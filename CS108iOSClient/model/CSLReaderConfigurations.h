//
//  CSLReaderConfigurations.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-10-28.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSLRfidAppEngine.h"


NS_ASSUME_NONNULL_BEGIN

@interface CSLReaderConfigurations : NSObject

+ (void) setAntennaPortsAndPowerForTags:(BOOL)isInitial;
+ (void) setAntennaPortsAndPowerForTagAccess:(BOOL)isInitial;
+ (void) setAntennaPortsAndPowerForTagSearch:(BOOL)isInitial;
+ (void) setConfigurationsForTags;
+ (void) setConfigurationsForTemperatureTags;
+ (void) setAntennaPortsAndPowerForTemperatureTags:(BOOL)isInitial;
+ (void) setConfigurationsForTemperatureTags:(BOOL)isInitial;
+ (void) setReaderRegionAndFrequencies;

@end

NS_ASSUME_NONNULL_END
