//
//  CSLReaderFrequency.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2020-05-15.
//  Copyright © 2020 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSLReaderFrequency : NSObject

///Device country code (OEM address 0x02)
@property (assign, readonly) UInt32 CountryCode;
///Special Country version (OEM address 0x8E)
@property (assign, readonly) UInt32 SpecialCountryVerison;
///frequency modification flag (OEM address 0x8F)
@property (assign, readonly) UInt32 FreqModFlag;
///Device model code (OEM address 0xA4)
@property (assign, readonly) UInt32 ModelCode;
///Hopping/Fixed frequency (OEM address 0x9D)
@property (assign, readonly) UInt32 isFixed;
///List of Regions based on the OEM data
@property NSMutableArray* RegionList;
///Provide a key with the region code and get an array of frequencies
@property NSMutableDictionary* TableOfFrequencies;
///Provide a key with the region code and get an array of frequency values
@property NSMutableDictionary* FrequencyValues;
///Provide a key with the region code and get an array of frequency index
@property NSMutableDictionary* FrequencyIndex;

-(id)initWithOEMData:(UInt32)countryCode specialCountryVerison:(UInt32)special_country FreqModFlag:(UInt32)freq_mod_flag ModelCode:(UInt32)model_code isFixed:(UInt32)is_fixed;

@end

NS_ASSUME_NONNULL_END
