//
//  CSLReaderBarcode.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSLReaderBarcode : NSObject
{
    NSData* serialData;
    NSString* barcodeValue;
    NSString* codeId;
    NSString* aimId;
}

@property (retain) NSData* serialData;
@property (retain) NSString* barcodeValue;
@property (retain) NSString* codeId;
@property (retain) NSString* aimId;

- (id) init;
- (id) initWithSerialData:(NSData*)data;
- (NSString*) extractBarcodeFromSerialData;
+ (NSString*) convertDataToHexString:(NSData*) data;
+ (NSString*) convertHexStringToAscii:(NSString*) hexString ;

@end
