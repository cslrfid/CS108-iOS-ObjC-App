//
//  CSLBleReader.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 28/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSLBleInterface.h"
#import "CSLBleTag.h"
#import "CSLReaderBattery.h"
#import "CSLReaderBarcode.h"

#define COMMAND_TIMEOUT_1S 10
#define COMMAND_TIMEOUT_2S 20
#define COMMAND_TIMEOUT_3S 30
#define COMMAND_TIMEOUT_4S 40
#define COMMAND_TIMEOUT_5S 50
#define COMMAND_TIMEOUT_10S 100

#define COMMAND_ANTCYCLE_CONTINUOUS 0xFFFF

///Query sessions
typedef NS_ENUM(Byte, SESSION)
{
    S0 = 0,
    S1,
    S2,
    S3
};

///Query target
typedef NS_ENUM(Byte, TARGET)
{
    A = 0x00,
    B,
    ToggleAB
};

///Query algorithm
typedef NS_ENUM(Byte, QUERYALGORITHM)
{
    FIXEDQ = 0x00,
    DYNAMICQ = 0x03
};

///Link profile
typedef NS_ENUM(Byte, LINKPROFILE)
{
    MULTIPATH_INTERFERENCE_RESISTANCE = 0x00,
    RANGE_DRM,
    RANGE_THROUGHPUT_DRM,
    MAX_THROUGHPUT
};
//Argument to underlying Query
typedef NS_ENUM(Byte, QUERYSELECT)
{
    ALL = 0x00,
    SL = 0x03
};

//Reader type (fixed or handheld)
typedef NS_ENUM(Byte, READERTYPE)
{
    CS108 = 0x00,
    CS463 = 0x01
};

@class CSLBleReader;             //define class, so protocol can see CSLBleReader class
/**
 Delegate of the reader events
 */
@protocol CSLBleReaderDelegate <NSObject>   //define delegate protocol
/**
 This will be triggered when reader receives a new tag response during its operations
 @param sender CSLBleReader object of the connected reader
 @param tag Reference to the CSLBleTag object being returned
 */
- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag;  //define delegate method to be implemented within another class
/**
 This will be triggered when the trigger key on the reader has chagned state (pressed/released)
 @param sender CSLBleReader object of the connected reader
 @param state State of the trigger key (0=released, 1=pressed)
 */
- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state;
/**
 This will be triggered when reader receives battery level notification on every 5 seconds
 @param sender CSLBleReader object of the connected reader
 @param battPct Battery level in percentage
 */
- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct;
/**
 This will be triggered when a barcode is being scanned
 @param sender CSLBleReader object of the connected reader
 @param barcode Barcode data in CSLReaderBarcode object
 */
- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode;
/**
 This will be triggered when reader receives a tag access response during its operations
 @param sender CSLBleReader object of the connected reader
 @param tag Reference to the CSLBleTag object being returned
 */
- (void) didReceiveTagAccessData: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag;  //define delegate method to be implemented within another class
@end //end protocol

/**
 This object class holds the core function of the reader API and it allows developers to configure and control the device being connnected.
 It is a sub-class of CSLBleInterface, which handles the low-level Bluetooth LE connectiviites.
 */
@interface CSLBleReader : CSLBleInterface
/** This is a buffer for all the tags that have been sorted with all duplicates removed.
Insertion/update of tag data is based on binary searching algorithm for better efficiency especially when the number of tags in buffer raises.
 */
@property NSMutableArray * filteredBuffer;
///This property holds the number of tags being read.  It is reset within a specific time interval (1 second by default)
@property NSInteger rangingTagCount;
///This property holds the number of unique tags being read.  It is reset within a specific time interval (1 second by default)
@property NSInteger uniqueTagCount;
///Enumeration type that holds the battery status information.  Its value is is being updated by a scheduled timer when batteery level notifications return on every 5 seconds
@property CSLReaderBattery* batteryInfo;
///This property indicates if the reader is either in tag access or inventory mode
@property BOOL isTagAccessMode;
///Reader type (fixed or handheld)
@property READERTYPE readerModelNumber;
///
@property CSLCircularQueue * cmdRespQueue;
///Delegate instance that follows the CSLBleReaderDelegate protocol
@property (nonatomic, weak) id <CSLBleReaderDelegate> readerDelegate;

/**
 Static method that converts hexdcecimal string to binary data
 
 @param hexString It holds the hexidecimal string to be converted
 @return NSData value
 */
+ (NSData *)convertHexStringToData:(NSString *)hexString;
/**
 Static method that converts binary data to hexdcecimal string
 
 @param data It holds the binary data to be converted
 @return NSString hexdecimal string
*/
+ (NSString*) convertDataToHexString:(NSData*) data;
/**
 initialization selector that:
 - call init selector of the super class CSLBleInterface
 - initialize tag count properties
 - initialize internal buffer queue
 */
- (id)init;
/**
 dealloc selector that:
 - stop radio if it is currently active
 - release selector to the delegates
 */
- (void)dealloc;
/**
 Read OEM data that contains product-specific information such as country code, antenna version and frequency channel information
 @param intf CSLBleInterface that references to the current reader instance
 @param addr Address of the memory location
 @param data Pointer to the NSData object that holds the value of the data address
 @return TRUE if the operation is successful
 */
- (BOOL)readOEMData:(CSLBleInterface*)intf atAddr:(unsigned short)addr forData:(NSData*)data;
/**
 Enable/disable barcode reader
 @param enable TRUE/FALSE for turning on/off the barcode reader module
 @return TRUE if the operation is successful
 */
- (BOOL)barcodeReader:(BOOL)enable;
/**
 Start barcode reading continuously
 @return TRUE if the operation is successful
 */
- (BOOL)startBarcodeReading;
/**
 Stop barcode reading
 @return TRUE if the operation is successful
 */
- (BOOL)stopBarcodeReading;
/**
 Send serial command to barcode reader module
  @return TRUE if the operation is successful
 @note Please refer to Newland serial programming command manual for further details
 */
- (BOOL)sendBarcodeCommandData: (NSData*)data;
/**
 Power on/off RFID module
 @param enable TRUE/FALSE for turning on/off the RFID module
 @return TRUE if the operation is successful
 */
- (BOOL)powerOnRfid:(BOOL)enable;
/**
 Obtain Bluetooth firmware version
 @param versionNumber Pointer to an instance of NSString that receives the version information
 @return TRUE if the operation is successful
 */
- (BOOL)getBtFirmwareVersion:(NSString **)versionNumber;
/**
 Obtain device name (name showing up during device discovery)
 @param deviceName Pointer to an instance of NSString that receives the device name
 @return TRUE if the operation is successful
 */
- (BOOL)getConnectedDeviceName:(NSString **) deviceName;
/**
 Obtain Silicon Lab IC firmware version
 @param slVersion Pointer to an instance of NSString that receives the firmware version
 @return TRUE if the operation is successful
 */
- (BOOL)getSilLabIcVersion:(NSString **) slVersion;
/**
 Obtain RFID board serial number
 @param serialNumber Pointer to an instance of NSString that receives the serial number information
 @return TRUE if the operation is successful
 */
- (BOOL)getRfidBrdSerialNumber:(NSString**) serialNumber;
/**
 Obtain PCB board version information
 @param boardVersion Pointer to an instance of NSString that receives the PCB version information
 @return TRUE if the operation is successful
 */
- (BOOL)getPcBBoardVersion:(NSString**) boardVersion;
/**
 Send abort command to the device for stopping RFID operations (e.g. inventory, tag read/write, etc.)
 @return TRUE if the operation is successful
 */
- (BOOL)sendAbortCommand;
/**
 Start battery level reporting (notification every 5 seconds)
Once it is started, the delegate will be triggered everytime when a battery level notification is being returned
 @return TRUE if the operation is successful
 */
- (BOOL)startBatteryAutoReporting;
/**
 Stop battery level reporting (notification every 5 seconds)
 @return TRUE if the operation is successful
 */
- (BOOL)stopBatteryAutoReporting;
/**
 Obtain RFID module firmware version
 @param versionInfo Pointer to an instance of NSString that receives the RFID firmware version
 @return TRUE if the operation is successful
 */
- (BOOL)getRfidFwVersionNumber:(NSString**) versionInfo;
/**
Set output power of the reader
 @param powerInDbm Power in the range of 0.0-32.0 dBm
 @return TRUE if the operation is successful
 */
- (BOOL)setPower:(double) powerInDbm;
/**
 Set antenna cycle
 @param cycles Should set to 0 (continous) all the time as CS108 is running with a single antenna
 @return TRUE if the operation is successful
 */
- (BOOL)setAntennaCycle:(NSUInteger) cycles;
/**
 Set antenna dwell time
 @param timeInMilliseconds number of milliseconds to communicate on this antenna during a given Antenna Cycle.
 0x00000000 indicates that dwell time should not be used.
 @return TRUE if the operation is successful
 */
- (BOOL)setAntennaDwell:(NSUInteger) timeInMilliseconds;
/**
 Set link profile from the four selections
 @param profile LINKPROFILE data type that represents 1 of the 4 link profile
 @return TRUE if the operation is successful
 */
- (BOOL)setLinkProfile:(LINKPROFILE) profile;
/**
Select which set of algorithm parameter registers to access.
 @param algorithm zero based index of descriptor to access 0 through 3
 @return TRUE if the operation is successful
 */
- (BOOL)selectAlgorithmParameter:(QUERYALGORITHM) algorithm;
/**
 The algorithm that will be used for the next Inventory command. The definition of each register varies depending on the algorithm chosen. For instance, if you wish to set the
 parameters for algorithm 1, then set selectAlgorithmParameter to 1 and load parameters as specified.
 @param startQ Starting Q value
 @param maxQ Maximum Q value
 @param minQ Minimum Q Value
 @param tmult Threshold multiplier. This is a fixed point fraction with the decimal point between bit 2 and 3.
 The field looks like bbbbbb.bb which allows fractional values of ½ , ¼ and ¾ .
@return TRUE if the operation is successful
 */
- (BOOL)setInventoryAlgorithmParameters0:(Byte) startQ maximumQ:(Byte)maxQ minimumQ:(Byte)minQ ThresholdMultiplier:(Byte)tmult;
/**
 The algorithm that will be used for the next Inventory command. The definition of each register varies depending on the algorithm chosen. For instance, if you wish to set the
 parameters for algorithm 1, then set selectAlgorithmParameter to 1 and load parameters as specified.
 @param retry Number of times to retry a query / query rep sequence for the session/target before flipping the target or exiting. For example, if q is 2 then there will be one query and 4 query reps for each retry.
 @return TRUE if the operation is successful
 */
- (BOOL)setInventoryAlgorithmParameters1:(Byte) retry;
/**
 The algorithm that will be used for the next Inventory command. The definition of each register varies depending on the algorithm chosen. For instance, if you wish to set the
 parameters for algorithm 1, then set selectAlgorithmParameter to 1 and load parameters as specified.
 @param toggle If set to one, the target will flip from A to B or B to A after all rounds have been run on the current target. This is done after no tags have been read if continuous mode is selected and all retry's have been run.
 @param rtz Continue running inventory rounds until a round is completed without reading any tags.
 @return TRUE if the operation is successful
 */
- (BOOL)setInventoryAlgorithmParameters2:(BOOL) toggle RunTillZero:(BOOL)rtz;
/**
 Inventory configuration. Configure parameters used in underlying inventory operations
 @param inventoryAlgorithm Inventory algorithm to use.
 @param match_rep Stop after "N" tags inventoried (zero indicates no stop)
 @param tag_sel 1 = enable tag select prior to inventory, read, write, lock or kill.  0 = no select issued.
 @param disable_inventory Do not run inventory
 @param tag_read 0 = no tag read issued
 1 = enable read 1 bank after inventory
 2 = enable read 2 banks after inventory
 @param crc_err_read 0 = disable crc error read
 1 = enable crc error read
 @param QT_mode 0 = disable QT temporary read private EPC
 1 = enable QT temporary read private EPC
 @param tag_delay Time delay for each tag in ms (use to reduce tag rate).  Value should be between 1 to 65
 @param inv_mode 0 = normal mode
 1 = compact mode
 @return TRUE if the operation is successful
 */
- (BOOL)setInventoryConfigurations:(QUERYALGORITHM) inventoryAlgorithm MatchRepeats:(Byte)match_rep tagSelect:(Byte)tag_sel disableInventory:(Byte)disable_inventory tagRead:(Byte)tag_read crcErrorRead:(Byte) crc_err_read QTMode:(Byte) QT_mode tagDelay:(Byte) tag_delay inventoryMode:(Byte)inv_mode;
/**
 Configure parameters used in underlying Query and inventory operations.
 @param queryTarget Starting Target argument (A or B) to underlying Query.  0 = A; 1 = B.
 @param query_session Session argument to underlying Query.  0= S0; 1 = S1; 2 = S2; 3 = S3.
 @param query_sel Select argument to underlying Query.  0 = All; 1 = All; 2 = ~SL; 3 = SL;
 Recommend to Set 0 for inventory operation.
 Recommend to Set 3 for tag select operation. Reference to INV_CFG and TAGMSK_DESC_CFG.
 @return TRUE if the operation is successful
 */
- (BOOL)setQueryConfigurations:(TARGET) queryTarget querySession:(SESSION)query_session querySelect:(QUERYSELECT)query_sel;
/**
 Start Inventory asynchornously
 @return TRUE if the operation is successful
 */
- (BOOL)startInventory;
/**
 Stop Inventory
 @return TRUE if the operation is successful
 */
- (BOOL)stopInventory;
/**
 Start the data packet decoding routine, where a selector will be running on a background thread and decode the received packet if commands were being sent out previously.  Results will be returned to the recvQueue (for asynchornous commands)  and to cmdRespQueue (for synchronous commands)
 */
- (void)decodePacketsInBufferAsync;

@end
