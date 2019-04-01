//
//  CSLTemperatureTagSettings.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 12/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../CSLReader/CSLCircularQueue.h"

#define MIN_TEMP_VALUE -40.0
#define MAX_TEMP_VALUE +85.0

NS_ASSUME_NONNULL_BEGIN

///Temperature Sensor Type (TID)
typedef NS_ENUM(UInt32, SENSORTYPE)
{
    MAGNUSS3 = 0xE2824030,
};

///Temperature Unit
typedef NS_ENUM(BOOL, TEMPERATUREUNIT)
{
    CELCIUS = 0,
    FAHRENHEIT=1
};

@interface CSLTemperatureTagSettings : NSObject

//Temperature alert enable/disable
@property (assign) BOOL isTemperatureAlertEnabled;
///Temperature alert upper limit
@property (assign) double temperatureAlertUpperLimit;
///Temperature alert lower limit
@property (assign) double temperatureAlertLowerLimit;
///On-chip RSSI filter upper limit
@property (assign) int rssiUpperLimit;
///On-chip RSSI filter lower limit
@property (assign) int rssiLowerLimit;
///Temperature sensor type
@property (assign) SENSORTYPE sensorType;
///Number of samples on rolling average for temperature values
@property (assign) int NumberOfRollingAvergage;
///Temperature Unit being displayed
@property (assign) TEMPERATUREUNIT unit;

///Hold a list of circular queues for each of the tag read
@property NSMutableDictionary * temperatureAveragingBuffer;
///Hold a list of last good read timestamp
@property NSMutableDictionary * lastGoodReadBuffer;

/**
 This will add the temperature data to the cirular buffer, with buffer size deinfed on the settings page
 @param temperatureValue Temperature data to be added to the buffer
 @param epc EPC value of the tag
 */
- (void) setTemperatureValueForAveraging:(NSNumber*)temperatureValue EPCID:(NSString*)epc;
/**
 Calculate and return the average temperature based on data within the rolling window
 @param epc EPC value of the tag
 @return Average temperature value calculated
 */
- (NSNumber*) getTemperatureValueAveraging:(NSString*)epc;
/**
 Remove the temperature data in the circular buffer for a specific tag
 @param epc EPC value of the tag
 */
- (void) removeTemperatureAverageForEpc:(NSString*)epc;
/**
 Convert temperature value from Celicus to Fahrenheit
 @param temperatureInCelcius Temperature in Celcius
 @return Temperature in Fahrenheit
 */
+ (double) convertCelciusToFahrenheit:(double)temperatureInCelcius;
/**
 Convert temperature value from Fahrenheit to Celicus
 @param temperatureInFahrenheit Temperature in Fahrenheit
 @return Temperature in Celicus
 */
+ (double) convertFahrenheitToCelcius:(double)temperatureInFahrenheit;

@end

NS_ASSUME_NONNULL_END
