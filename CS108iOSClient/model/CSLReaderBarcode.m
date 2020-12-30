//
//  CSLReaderBarcode.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderBarcode.h"

@interface CSLReaderBarcode() {
    NSMutableDictionary *codeIdDescriptons;
}
@end

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
        
        codeIdDescriptons=[[NSMutableDictionary alloc] init];
        [codeIdDescriptons setObject:@"Code-128/EAN-128" forKey:@"j"];
        [codeIdDescriptons setObject:@"AIM-128" forKey:@"f"];
        [codeIdDescriptons setObject:@"EAN-8/EAN-13" forKey:@"d"];
        [codeIdDescriptons setObject:@"UPC-E/UPC-A" forKey:@"c"];
        [codeIdDescriptons setObject:@"Interleaved 2 of 5/ITF" forKey:@"e"];
        [codeIdDescriptons setObject:@"Matrix 2 of 5" forKey:@"v"];
        [codeIdDescriptons setObject:@"Code 39" forKey:@"b"];
        [codeIdDescriptons setObject:@"Codabar" forKey:@"a"];
        [codeIdDescriptons setObject:@"Code 93" forKey:@"i"];
        [codeIdDescriptons setObject:@"Code 11" forKey:@"H"];
        [codeIdDescriptons setObject:@"GS1 Databar(RSS)" forKey:@"R"];
        [codeIdDescriptons setObject:@"EAN/UCC Composite" forKey:@"y"];
        [codeIdDescriptons setObject:@"ISBN" forKey:@"B"];
        [codeIdDescriptons setObject:@"ISSN" forKey:@"n"];
        [codeIdDescriptons setObject:@"Matrix 2 of 5(European Matrix 2)" forKey:@"v"];
        [codeIdDescriptons setObject:@"Industrial 25" forKey:@"D"];
        [codeIdDescriptons setObject:@"Standard 25" forKey:@"s"];
        [codeIdDescriptons setObject:@"Plessey" forKey:@"p"];
        [codeIdDescriptons setObject:@"MSI-Plessey" forKey:@"m"];
        [codeIdDescriptons setObject:@"QR Code" forKey:@"Q"];
        [codeIdDescriptons setObject:@"Aztec" forKey:@"z"];
        [codeIdDescriptons setObject:@"Data Matrix" forKey:@"u"];
        [codeIdDescriptons setObject:@"Maxicode" forKey:@"x"];
        [codeIdDescriptons setObject:@"Chinese Sensible Code" forKey:@"h"];
        [codeIdDescriptons setObject:@"Plessey" forKey:@"p"];
        
        serialData=data;
        [self extractBarcodeFromSerialData];
    }
    return self;
}

- (NSString*) extractBarcodeFromSerialData {
    
    static NSString* barcodeHexString = @"";
    if ([barcodeHexString isEqualToString:@""])
        barcodeHexString=[CSLReaderBarcode convertDataToHexString:serialData];
    else {
        barcodeHexString=[barcodeHexString stringByAppendingString:[CSLReaderBarcode convertDataToHexString:serialData]];
    }
    
    if ([barcodeHexString length] < 32 ){
        NSLog(@"Invalid barcode serial data - %@", barcodeHexString);
        return nil;
    }
    
    //check if we have received complete data
    if ([[barcodeHexString substringToIndex:12] containsString:@"020007101713"] &&
        [[barcodeHexString substringFromIndex:[barcodeHexString length]-14] containsString:@"050111160304"]) {
        barcodeHexString=[barcodeHexString substringFromIndex:12];      //remove self-prefix
        barcodeHexString=[barcodeHexString substringToIndex:[barcodeHexString length]-14];  //remove self-suffix
    }
    else if ([[barcodeHexString substringToIndex:12] containsString:@"020007101713"] &&
        [barcodeHexString containsString:@"050111160304"]) {
        NSLog(@"Corrupted barcode data returned.  Clearing buffer - %@", barcodeHexString);
        barcodeHexString=@"";
        return nil;
    }
    else if ([barcodeHexString containsString:@"020007101713"] &&
        [[barcodeHexString substringFromIndex:[barcodeHexString length]-14] containsString:@"050111160304"]) {
        NSLog(@"Corrupted barcode data returned.  Clearing buffer - %@", barcodeHexString);
        barcodeHexString=@"";
        return nil;
    }
    else
    {
        NSLog(@"Incomplete barcode data received - %@", barcodeHexString);
        return nil;
    }

    NSLog(@"Barcode extracted - %@", barcodeHexString);
    codeId=[codeIdDescriptons objectForKey:[CSLReaderBarcode convertHexStringToAscii:[barcodeHexString substringToIndex:2]]];
    barcodeHexString=[barcodeHexString substringFromIndex:2];
    aimId=[CSLReaderBarcode convertHexStringToAscii:[barcodeHexString substringToIndex:6]];
    barcodeHexString=[barcodeHexString substringFromIndex:6];
    
    barcodeValue=[CSLReaderBarcode convertHexStringToAscii:barcodeHexString];
    barcodeHexString=@"";
    
    return barcodeValue;
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
