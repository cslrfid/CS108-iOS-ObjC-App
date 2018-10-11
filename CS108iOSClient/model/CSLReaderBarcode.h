//
//  CSLReaderBarcode.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
///Barcode reader operations and data management
@interface CSLReaderBarcode : NSObject

///Serial data returned by the barcode module
@property NSData* serialData;
///Barcode value extract from serial data
@property NSString* barcodeValue;
///Code ID representing the barcode type
@property NSString* codeId;
///AIM ID
@property NSString* aimId;

- (id) init;
/** Initialize the instance with serial data returned from the barcode reader
 @param data Serial data from the barcode module
 @return Reference to the allocated instance
 */
- (id) initWithSerialData:(NSData*)data;
/** Extract barcode information from serial data returned by the barcode module
 @return Data in ASCII string
 */
- (NSString*) extractBarcodeFromSerialData;
/** Convert serial data to hexdecimal string
 @param data Serial data in binary
 @return Data in hexdecimal string
 */
+ (NSString*) convertDataToHexString:(NSData*) data;
/** Convert hexdecimal string to ASCII string
 @param hexString Hexdecimal string
 @return Data in ASCII string
 */
+ (NSString*) convertHexStringToAscii:(NSString*) hexString ;

@end
