//
//  CSLReaderBarcode.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderBarcode.h"

@implementation CSLReaderBarcode

@synthesize serialData;
@synthesize barcodeValue;
@synthesize aimId;
@synthesize codeId;

- (id)init
{
    return [self initWithSerialData:nil];
}

- (id) initWithSerialData:(NSData *)data {
    if (self = [super init]) {
        serialData=data;
        [self extractBarcodeFromSerialData];
    }
    return self;
}

- (NSString*) extractBarcodeFromSerialData {
    
    NSString* barcodeHexString=[CSLReaderBarcode convertDataToHexString:serialData];

    if ([barcodeHexString length] < 32 ){
        NSLog(@"Invalid barcode serial data - %@", barcodeHexString);
        return nil;
    }
    
    //self-prefix
    if ([[barcodeHexString substringToIndex:12] containsString:@"020007101713"]) {
        barcodeHexString=[barcodeHexString substringFromIndex:12];
    }
    else {
        NSLog(@"Invalid barcode self-prefix - %@", barcodeHexString);
        return nil;
    }
    
    //self-suffix
    NSLog(@"Barcode self-prefix - %@", barcodeHexString);
    if ([[barcodeHexString substringFromIndex:[barcodeHexString length]-14] containsString:@"050111160304"]) {
        barcodeHexString=[barcodeHexString substringToIndex:[barcodeHexString length]-14];
    }
    else {
        NSLog(@"Invalid barcode self-suffix - %@", barcodeHexString);
        return nil;
    }
    
    
    if (barcodeHexString)
    codeId=[CSLReaderBarcode convertHexStringToAscii:[barcodeHexString substringToIndex:2]];
    barcodeHexString=[barcodeHexString substringFromIndex:2];
    aimId=[CSLReaderBarcode convertHexStringToAscii:[barcodeHexString substringToIndex:6]];
    barcodeHexString=[barcodeHexString substringFromIndex:6];
    
    barcodeValue=[CSLReaderBarcode convertHexStringToAscii:barcodeHexString];
    
    return barcodeHexString;
}

+ (NSString*) convertDataToHexString:(NSData*) data {
    
    @try {
        int dlen=(int)[data length];
        NSMutableString* hexStr = [NSMutableString stringWithCapacity:dlen];
        
        
        for(int i = 0; i < [data length]; i++)
            [hexStr appendFormat:@"%02X", ((Byte*)[data bytes])[i]];
        
        return [NSString stringWithString: hexStr];
    }
    @catch (NSException* exception)
    {
        NSLog(@"Exception on convertDataToHexString: %@", exception.description);
        return nil;
    }
}

+ (NSString*) convertHexStringToAscii:(NSString*) hexString {
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [hexString length])
    {
        NSString * hexChar = [hexString substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    return newString;
}

@end
