//
//  CSLReaderFrequency.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2020-05-15.
//  Copyright © 2020 Convergence Systems Limited. All rights reserved.
//

#import "CSLReaderFrequency.h"

@implementation CSLReaderFrequency
{
    NSArray* FCCTableOfFreq;
    NSArray* AUTableOfFreq;
    NSArray* CNTableOfFreq;
    NSArray* ETSITableOfFreq;
    NSArray* INTableOfFreq;
    NSArray* HKTableOfFreq;
    NSArray* JPTableOfFreq;
    NSArray* KRTableOfFreq;
    NSArray* MYTableOfFreq;
    NSArray* TWTableOfFreq;
    NSArray* ZATableOfFreq;
    NSArray* BR1TableOfFreq;
    NSArray* BR2TableOfFreq;
    NSArray* BR3TableOfFreq;
    NSArray* BR4TableOfFreq;
    NSArray* BR5TableOfFreq;
    NSArray* IDTableOfFreq;
    NSArray* JETableOfFreq;
    NSArray* PHTableOfFreq;
    NSArray* ETSIUPPERBANDTableOfFreq;
    NSArray* NZTableOfFreq;
    NSArray* UH1TableOfFreq;
    NSArray* UH2TableOfFreq;
    NSArray* LHTableOfFreq;
    NSArray* LH1TableOfFreq;
    NSArray* LH2TableOfFreq;
    NSArray* VNTableOfFreq;
    
    NSArray* FCCFreqValues;
    NSArray* AUFreqValues;
    NSArray* CNFreqValues;
    NSArray* ETSIFreqValues;
    NSArray* INFreqValues;
    NSArray* HKFreqValues;
    NSArray* JPFreqValues;
    NSArray* KRFreqValues;
    NSArray* MYFreqValues;
    NSArray* TWFreqValues;
    NSArray* ZAFreqValues;
    NSArray* BR1FreqValues;
    NSArray* BR2FreqValues;
    NSArray* BR3FreqValues;
    NSArray* BR4FreqValues;
    NSArray* BR5FreqValues;
    NSArray* IDFreqValues;
    NSArray* JEFreqValues;
    NSArray* PHFreqValues;
    NSArray* ETSIUPPERBANDFreqValues;
    NSArray* NZFreqValues;
    NSArray* UH1FreqValues;
    NSArray* UH2FreqValues;
    NSArray* LHFreqValues;
    NSArray* LH1FreqValues;
    NSArray* LH2FreqValues;
    NSArray* VNFreqValues;

    NSArray* FCCFreqIndex;
    NSArray* AUFreqIndex;
    NSArray* CNFreqIndex;
    NSArray* ETSIFreqIndex;
    NSArray* INFreqIndex;
    NSArray* HKFreqIndex;
    NSArray* JPFreqIndex;
    NSArray* KRFreqIndex;
    NSArray* MYFreqIndex;
    NSArray* TWFreqIndex;
    NSArray* ZAFreqIndex;
    NSArray* BR1FreqIndex;
    NSArray* BR2FreqIndex;
    NSArray* BR3FreqIndex;
    NSArray* BR4FreqIndex;
    NSArray* BR5FreqIndex;
    NSArray* IDFreqIndex;
    NSArray* JEFreqIndex;
    NSArray* PHFreqIndex;
    NSArray* ETSIUPPERBANDFreqIndex;
    NSArray* NZFreqIndex;
    NSArray* UH1FreqIndex;
    NSArray* UH2FreqIndex;
    NSArray* LHFreqIndex;
    NSArray* LH1FreqIndex;
    NSArray* LH2FreqIndex;
    NSArray* VNFreqIndex;
    
}

-(id)init {
    
    //set default values to CS108 FCC fixed
    self = [self initWithOEMData:2 specialCountryVerison:0 FreqModFlag:0xAA ModelCode:0x0B];
    return self;
}

-(id)initWithOEMData:(UInt32)countryCode specialCountryVerison:(UInt32)special_country FreqModFlag:(UInt32)freq_mod_flag ModelCode:(UInt32)model_code {
    if (self = [super init])  {
        //set default values
        _CountryCode=countryCode;
        _SpecialCountryVerison=special_country;
        _FreqModFlag=freq_mod_flag;
        _ModelCode=model_code;
        [self generateRegionList];
    }
    return self;
}

-(void)generateRegionList {
    
    self.RegionList = [[NSMutableArray init] alloc];

    switch (self.CountryCode)
    {
        //-1 CE for Europe for India
        case 1:
            [self.RegionList addObject:@"ETSI"];
            [self.RegionList addObject:@"IN"];
            [self.RegionList addObject:@"G800"];
            break;
        case 2:
            //-2 RW (rest-of-the-world)
            if (self.FreqModFlag == 0x00)
            {
                [self.RegionList addObject:@"FCC"];     //FCC USA &Canada
                [self.RegionList addObject:@"AR"];      //Argentina
                [self.RegionList addObject:@"BR1"];     //Brazil 1
                [self.RegionList addObject:@"BR2"];     //Brazil 2
                [self.RegionList addObject:@"BR3"];     //Brazil 3
                [self.RegionList addObject:@"BR4"];     //Brazil 4
                [self.RegionList addObject:@"BR5"];     //Brazil 5
                [self.RegionList addObject:@"CL"];      //Chile
                [self.RegionList addObject:@"CO"];      //Columbia
                [self.RegionList addObject:@"CR"];      //Costa Rica
                [self.RegionList addObject:@"DO"];      //Dominican Republic
                [self.RegionList addObject:@"HK"];      //Hong Kong
                [self.RegionList addObject:@"ID"];      //Indonesia
                [self.RegionList addObject:@"JE"];      //Jersey 915-917 MHz
                [self.RegionList addObject:@"KR"];      //Korea
                [self.RegionList addObject:@"MY"];      //Malaysia
                [self.RegionList addObject:@"PA"];      //Panama
                [self.RegionList addObject:@"PE"];      //Peru
                [self.RegionList addObject:@"PH"];      //Philippnes
                [self.RegionList addObject:@"SG"];      //Singapore
                [self.RegionList addObject:@"TH"];      //Thailand
                [self.RegionList addObject:@"UY"];      //Uruguay
                [self.RegionList addObject:@"VN"];      //Vietnam
                [self.RegionList addObject:@"ZA"];      //South Africa
                [self.RegionList addObject:@"LH1"];
                [self.RegionList addObject:@"LH2"];
                [self.RegionList addObject:@"UH1"];
                [self.RegionList addObject:@"UH2"];

            }
            else
            { // HK USA AU ZA
                switch (self.SpecialCountryVerison)
                {
                    default: // and case 0x2a555341
                        [self.RegionList addObject:@"FCC"];
                        break;
                    case 0x4f464341:
                        [self.RegionList addObject:@"HK"];
                        break;
                    case 0x2a2a4153:
                        [self.RegionList addObject:@"AU"];
                        break;
                    case 0x2a2a4e5a:
                        [self.RegionList addObject:@"NZ"];
                        break;
                }
            }
            break;
        case 4:     //Taiwan NCC
            [self.RegionList addObject:@"TW"];
            [self.RegionList addObject:@"AU"];
            [self.RegionList addObject:@"CN"];
            [self.RegionList addObject:@"HK"];
            [self.RegionList addObject:@"ID"];
            [self.RegionList addObject:@"MY"];
            [self.RegionList addObject:@"SG"];
            break;
        case 6:
            [self.RegionList addObject:@"KR"];
            break;
        case 7:
            [self.RegionList addObject:@"CN"];
            [self.RegionList addObject:@"HK"];
            [self.RegionList addObject:@"AU"];
            [self.RegionList addObject:@"ID"];
            [self.RegionList addObject:@"MY"];
            [self.RegionList addObject:@"SG"];
            [self.RegionList addObject:@"TH"];
            break;
        case 8:
            [self.RegionList addObject:@"JP"];
            break;
        case 9:
            [self.RegionList addObject:@"ETSIUPPERBAND"];
            break;
    }
    
}

- (void)generateTableOfFreq {

    
    FCCTableOfFreq = @[@"902.75", @"903.25", @"903.75", @"904.25", @"904.75", @"905.25", @"905.75", @"906.25", @"906.75", @"907.25",
                      @"907.75", @"908.25", @"908.75", @"909.25", @"909.75", @"910.25", @"910.75", @"911.25", @"911.75", @"912.25",
                      @"912.75", @"913.25", @"913.75", @"914.25", @"914.75", @"915.25", @"915.75", @"916.25", @"916.75", @"917.25",
                      @"917.75", @"918.25", @"918.75", @"919.25", @"919.75", @"920.25", @"920.75", @"921.25", @"921.75", @"922.25",
                      @"922.75", @"923.25", @"923.75", @"924.25", @"924.75", @"925.25", @"925.75", @"926.25", @"926.75", @"927.25"];

    AUTableOfFreq = @[@"920.75", @"921.25", @"921.75", @"922.25", @"922.75", @"923.25", @"923.75", @"924.25", @"924.75", @"925.25"];

    CNTableOfFreq = @[@"920.625", @"920.875", @"921.125", @"921.375", @"921.625", @"921.875", @"922.125", @"922.375",
                      @"922.625", @"922.875", @"923.125", @"923.375", @"923.625", @"923.875", @"924.125", @"924.375"];
    
    ETSITableOfFreq = @[@"865.70", @"866.30", @"866.90", @"867.50"];
    
    INTableOfFreq = @[@"865.70", @"866.30", @"866.90"];

    HKTableOfFreq = @[@"920.75", @"921.25", @"921.75", @"922.25", @"922.75", @"923.25", @"923.75", @"924.25"];
    
    JPTableOfFreq = @[@"916.80", @"918.00", @"919.20", @"920.40"];

    KRTableOfFreq = @[@"917.30", @"917.90", @"918.50", @"919.10", @"919.70", @"920.30"];
 
    MYTableOfFreq = @[@"919.75", @"920.25", @"920.75", @"921.25", @"921.75", @"922.25"];

    TWTableOfFreq = @[@"922.25", @"922.75", @"923.25", @"923.75", @"924.25", @"924.75", @"925.25", @"925.75", @"926.25", @"926.75", @"927.25", @"927.75"];
    
    ZATableOfFreq = @[@"915.7", @"915.9", @"916.1", @"916.3", @"916.5", @"916.7", @"916.9", @"917.1", @"917.3", @"917.5", @"917.7", @"917.9", @"918.1", @"918.3", @"918.5", @"918.7"];
    
    
    BR1TableOfFreq = @[@"915.75", @"916.25", @"916.75", @"917.25", @"917.75", @"918.25", @"918.75", @"919.25", @"919.75", @"920.25",
                       @"920.75", @"921.25", @"921.75", @"922.25", @"922.75", @"923.25", @"923.75", @"924.25", @"924.75", @"925.25",
                       @"925.75", @"926.25", @"926.75", @"927.25"];

    BR2TableOfFreq = @[@"902.75", @"903.25", @"903.75", @"904.25", @"904.75", @"905.25", @"905.75", @"906.25", @"906.75",
                       @"915.75", @"916.25", @"916.75", @"917.25", @"917.75", @"918.25", @"918.75", @"919.25", @"919.75", @"920.25",
                       @"920.75", @"921.25", @"921.75", @"922.25", @"922.75", @"923.25", @"923.75", @"924.25", @"924.75", @"925.25",
                       @"925.75", @"926.25", @"926.75", @"927.25"];
    
    BR3TableOfFreq = @[@"902.75", @"903.25", @"903.75", @"904.25", @"904.75", @"905.25", @"905.75", @"906.25", @"906.75"];
    
    BR4TableOfFreq = @[@"902.75", @"903.25", @"903.75", @"904.25"];
    
    BR5TableOfFreq = @[@"917.75", @"918.25", @"918.75", @"919.25", @"919.75", @"920.25", @"920.75",
                       @"921.25", @"921.75", @"922.25", @"922.75", @"923.25", @"923.75", @"924.25"];
    
    IDTableOfFreq = @[@"923.25", @"923.75", @"924.25", @"924.75"];
    
    JETableOfFreq = @[@"915.25", @"915.5", @"915.75", @"916.0", @"916.25", @"916.5", @"916.75"];
    
    PHTableOfFreq = @[@"918.125", @"918.375", @"918.625", @"918.875", @"919.125", @"919.375", @"919.625", @"919.875"];
    
    ETSIUPPERBANDTableOfFreq = @[@"916.3", @"917.5", @"918.7"];

    NZTableOfFreq = @[@"922.25", @"922.75", @"923.25", @"923.75", @"924.25", @"924.75", @"925.25", @"925.75", @"926.25", @"926.75", @"927.25"];
    
    UH1TableOfFreq = @[@"915.25", @"915.75", @"916.25", @"916.75", @"917.25", @"917.75", @"918.25", @"918.75", @"919.25", @"919.75"];
    
    UH2TableOfFreq = @[@"920.25", @"920.75", @"921.25", @"921.75", @"922.25",
                       @"922.75", @"923.25", @"923.75", @"924.25", @"924.75",
                       @"925.25", @"925.75", @"926.25", @"926.75", @"927.25"];
    LHTableOfFreq = @[@"902.75", @"903.25", @"903.75", @"904.25", @"904.75", @"905.25", @"905.75", @"906.25", @"906.75", @"907.25",
                      @"907.75", @"908.25", @"908.75", @"909.25", @"909.75", @"910.25", @"910.75", @"911.25", @"911.75", @"912.25",
                      @"912.75", @"913.25", @"913.75", @"914.25", @"914.75", @"915.25"];
    LH1TableOfFreq = @[@"902.75", @"903.25", @"903.75", @"904.25", @"904.75", @"905.25", @"905.75", @"906.25", @"906.75", @"907.25",
                       @"907.75", @"908.25", @"908.75", @"909.25"];
    LH2TableOfFreq = @[@"909.75", @"910.25", @"910.75", @"911.25", @"911.75", @"912.25", @"912.75", @"913.25", @"913.75", @"914.25", @"914.75"];
    
    VNTableOfFreq  = @[@"922.75", @"923.25", @"923.75", @"924.25", @"924.75", @"925.25", @"925.75", @"926.25", @"926.75", @"927.25"];
    
    FCCFreqValues = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E1F], /*903.75 MHz  2 */
                     [NSNumber numberWithUnsignedInt:0x00180E41], /*912.25 MHz  19 */
                     [NSNumber numberWithUnsignedInt:0x00180E2F], /*907.75 MHz  10 */
                     [NSNumber numberWithUnsignedInt:0x00180E39], /*910.25 MHz  15 */
                     [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75 MHz  40 */
                     [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz  41 */
                     [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz  42 */
                     [NSNumber numberWithUnsignedInt:0x00180E4D], /*915.25 MHz  25 */
                     [NSNumber numberWithUnsignedInt:0x00180E35], /*909.25 MHz  13 */
                     [NSNumber numberWithUnsignedInt:0x00180E43], /*912.75 MHz  20 */
                     [NSNumber numberWithUnsignedInt:0x00180E3B], /*910.75 MHz  16 */
                     [NSNumber numberWithUnsignedInt:0x00180E47], /*913.75 MHz  22 */
                     [NSNumber numberWithUnsignedInt:0x00180E37], /*909.75 MHz  14 */
                     [NSNumber numberWithUnsignedInt:0x00180E25], /*905.25 MHz  5 */
                     [NSNumber numberWithUnsignedInt:0x00180E3F], /*911.75 MHz  18 */
                     [NSNumber numberWithUnsignedInt:0x00180E1B], /*902.75 MHz  0 */
                     [NSNumber numberWithUnsignedInt:0x00180E49], /*914.25 MHz  23 */
                     [NSNumber numberWithUnsignedInt:0x00180E59], /*918.25 MHz  31 */
                     [NSNumber numberWithUnsignedInt:0x00180E79], /*926.25 MHz  47 */
                     [NSNumber numberWithUnsignedInt:0x00180E77], /*925.75 MHz  46 */
                     [NSNumber numberWithUnsignedInt:0x00180E63], /*920.75 MHz  36 */
                     [NSNumber numberWithUnsignedInt:0x00180E61], /*920.25 MHz  35 */
                     [NSNumber numberWithUnsignedInt:0x00180E2D], /*907.25 MHz  9 */
                     [NSNumber numberWithUnsignedInt:0x00180E4B], /*914.75 MHz  24 */
                     [NSNumber numberWithUnsignedInt:0x00180E5F], /*919.75 MHz  34 */
                     [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25 MHz  39 */
                     [NSNumber numberWithUnsignedInt:0x00180E1D], /*903.25 MHz  1 */
                     [NSNumber numberWithUnsignedInt:0x00180E29], /*906.25 MHz  7 */
                     [NSNumber numberWithUnsignedInt:0x00180E27], /*905.75 MHz  6 */
                     [NSNumber numberWithUnsignedInt:0x00180E7B], /*926.75 MHz  48 */
                     [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz  43 */
                     [NSNumber numberWithUnsignedInt:0x00180E23], /*904.75 MHz  4 */
                     [NSNumber numberWithUnsignedInt:0x00180E75], /*925.25 MHz  45 */
                     [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75 MHz  44 */
                     [NSNumber numberWithUnsignedInt:0x00180E5D], /*919.25 MHz  33 */
                     [NSNumber numberWithUnsignedInt:0x00180E53], /*916.75 MHz  28 */
                     [NSNumber numberWithUnsignedInt:0x00180E3D], /*911.25 MHz  17 */
                     [NSNumber numberWithUnsignedInt:0x00180E65], /*921.25 MHz  37 */
                     [NSNumber numberWithUnsignedInt:0x00180E31], /*908.25 MHz  11 */
                     [NSNumber numberWithUnsignedInt:0x00180E33], /*908.75 MHz  12 */
                     [NSNumber numberWithUnsignedInt:0x00180E45], /*913.25 MHz  21 */
                     [NSNumber numberWithUnsignedInt:0x00180E51], /*916.25 MHz  27 */
                     [NSNumber numberWithUnsignedInt:0x00180E21], /*904.25 MHz  3 */
                     [NSNumber numberWithUnsignedInt:0x00180E2B], /*906.75 MHz  8 */
                     [NSNumber numberWithUnsignedInt:0x00180E57], /*917.75 MHz  30 */
                     [NSNumber numberWithUnsignedInt:0x00180E67], /*921.75 MHz  38 */
                     [NSNumber numberWithUnsignedInt:0x00180E55], /*917.25 MHz  29 */
                     [NSNumber numberWithUnsignedInt:0x00180E7D], /*927.25 MHz  49 */
                     [NSNumber numberWithUnsignedInt:0x00180E5B], /*918.75 MHz  32 */
                     [NSNumber numberWithUnsignedInt:0x00180E4F], /*915.75 MHz  26 */
                     nil];
    
    AUFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E63], /* 920.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E69], /* 922.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6F], /* 923.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E73], /* 924.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E65], /* 921.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6B], /* 922.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E71], /* 924.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E75], /* 925.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E67], /* 921.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6D], /* 923.25MHz   */
                  nil];
    CNFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00301CD3], /*922.375MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CD1], /*922.125MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CCD], /*921.625MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CC5], /*920.625MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CD9], /*923.125MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CE1], /*924.125MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CCB], /*921.375MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CC7], /*920.875MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CD7], /*922.875MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CD5], /*922.625MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CC9], /*921.125MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CDF], /*923.875MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CDD], /*923.625MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CDB], /*923.375MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CCF], /*921.875MHz   */
                  [NSNumber numberWithUnsignedInt:0x00301CE3], /*924.375MHz   */
                  nil];
                  
    ETSIFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x003C21D1], /*865.700MHz   */
                    [NSNumber numberWithUnsignedInt:0x003C21D7], /*866.300MHz   */
                    [NSNumber numberWithUnsignedInt:0x003C21DD], /*866.900MHz   */
                    [NSNumber numberWithUnsignedInt:0x003C21E3], /*867.500MHz   */
                    nil];
    INFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x003C21D1], /*865.700MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C21D7], /*866.300MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C21DD], /*866.900MHz   */
                  nil];

    HKFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E63], /*920.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E65], /*921.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E67], /*921.75MHz   */
                  nil];
    
    JPFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x003C23D0], /*916.800MHz   Channel 1*/
                  [NSNumber numberWithUnsignedInt:0x003C23DC], /*918.000MHz   Channel 2*/
                  [NSNumber numberWithUnsignedInt:0x003C23E8], /*919.200MHz   Channel 3*/
                  [NSNumber numberWithUnsignedInt:0x003C23F4], /*920.400MHz   Channel 4*/
                  nil];
    
    KRFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x003C23E7], /*919.1 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23D5], /*917.3 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23F3], /*920.3 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23DB], /*917.9 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23ED], /*919.7 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23E1], /*918.5 MHz   */
                  nil];
    
    MYFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E5F], /*919.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E65], /*921.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E61], /*920.25MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E67], /*921.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E63], /*920.75MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25MHz   */
                  nil];
                                            
                                            
    TWFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E7D], /*927.25MHz   10*/
                  [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75MHz   5*/
                  [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75MHz   1*/
                  [NSNumber numberWithUnsignedInt:0x00180E75], /*925.25MHz   6*/
                  [NSNumber numberWithUnsignedInt:0x00180E7F], /*927.75MHz   11*/
                  [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25MHz   4*/
                  [NSNumber numberWithUnsignedInt:0x00180E79], /*926.25MHz   8*/
                  [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25MHz   2*/
                  [NSNumber numberWithUnsignedInt:0x00180E7B], /*926.75MHz   9*/
                  [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25MHz   0*/
                  [NSNumber numberWithUnsignedInt:0x00180E77], /*925.75MHz   7*/
                  [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75MHz   3*/
                  nil];

    ZAFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x003C23C5], /*915.7 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23C7], /*915.9 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23C9], /*916.1 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23CB], /*916.3 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23CD], /*916.5 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23CF], /*916.7 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23D1], /*916.9 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23D3], /*917.1 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23D5], /*917.3 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23D7], /*917.5 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23D9], /*917.7 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23DB], /*917.9 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23DD], /*918.1 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23DF], /*918.3 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23E1], /*918.5 MHz   */
                  [NSNumber numberWithUnsignedInt:0x003C23E3], /*918.7 MHz   */
                  nil];
             
    BR1FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E4F], /*915.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E7B], /*926.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E79], /*926.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E7D], /*927.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E61], /*920.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5D], /*919.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5B], /*918.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E57], /*917.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E75], /*925.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E67], /*921.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E55], /*917.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E59], /*918.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E51], /*916.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5F], /*919.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E53], /*916.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E77], /*925.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E65], /*921.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E63], /*920.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz   */
                   nil];
                                             
    BR2FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E4F], /*915.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1D], /*903.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E7B], /*926.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E79], /*926.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E21], /*904.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E7D], /*927.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E61], /*920.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5D], /*919.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5B], /*918.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E57], /*917.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E25], /*905.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E23], /*904.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E75], /*925.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E67], /*921.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E2B], /*906.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1F], /*903.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E27], /*905.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E29], /*906.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E55], /*917.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E59], /*918.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E51], /*916.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5F], /*919.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E53], /*916.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E77], /*925.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E65], /*921.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E63], /*920.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1B], /*902.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz   */
                   nil];
    
    BR3FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E1D], /*903.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E21], /*904.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E25], /*905.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E23], /*904.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E2B], /*906.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1F], /*903.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E27], /*905.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E29], /*906.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1B], /*902.75 MHz   */
                   nil];
    
    BR4FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E1D], /*903.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E21], /*904.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1F], /*903.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1B], /*902.75 MHz   */
                   nil];
                                             
    BR5FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E61], /*920.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5D], /*919.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5B], /*918.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E57], /*917.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E67], /*921.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E59], /*918.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5F], /*919.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E65], /*921.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E63], /*920.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz   */
                   nil];
                                         
    IDFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz    */
                  [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz    */
                  [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz    */
                  [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75 MHz    */
                  nil];
    
    JEFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E4D], /*915.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E51], /*916.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E4E], /*915.5 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E52], /*916.5 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E4F], /*915.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E53], /*916.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E50], /*916.0 MHz   */
                  nil];
    
    PHFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00301CB1], /*918.125MHz   Channel 0*/
                  [NSNumber numberWithUnsignedInt:0x00301CBB], /*919.375MHz   Channel 5*/
                  [NSNumber numberWithUnsignedInt:0x00301CB7], /*918.875MHz   Channel 3*/
                  [NSNumber numberWithUnsignedInt:0x00301CBF], /*919.875MHz   Channel 7*/
                  [NSNumber numberWithUnsignedInt:0x00301CB3], /*918.375MHz   Channel 1*/
                  [NSNumber numberWithUnsignedInt:0x00301CBD], /*919.625MHz   Channel 6*/
                  [NSNumber numberWithUnsignedInt:0x00301CB5], /*918.625MHz   Channel 2*/
                  [NSNumber numberWithUnsignedInt:0x00301CB9], /*919.125MHz   Channel 4*/
                  nil];
    
    ETSIUPPERBANDFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x003C23CB], /*916.3 MHz   */
                             [NSNumber numberWithUnsignedInt:0x003C23D7], /*917.5 MHz   */
                             [NSNumber numberWithUnsignedInt:0x003C23E3], /*918.7 MHz   */
                             nil];
    
    NZFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E77], /*925.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E7B], /*926.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E7D], /*927.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E75], /*925.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E79], /*926.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75 MHz   */
                  nil];
    
    
    
    UH1FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E4F], /*915.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E4D], /*915.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5D], /*919.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5B], /*918.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E57], /*917.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E55], /*917.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E59], /*918.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E51], /*916.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E5F], /*919.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E53], /*916.75 MHz   */
                   nil];
    
    UH2FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E7B], /*926.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E79], /*926.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E7D], /*927.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E61], /*920.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E75], /*925.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E67], /*921.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E69], /*922.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E77], /*925.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E65], /*921.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E63], /*920.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz   */
                   nil];
    
                   
    LHFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E1B], /*902.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E35], /*909.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E1D], /*903.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E37], /*909.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E1F], /*903.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E39], /*910.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E21], /*904.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E3B], /*910.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E23], /*904.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E3D], /*911.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E25], /*905.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E3F], /*911.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E27], /*905.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E41], /*912.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E29], /*906.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E43], /*912.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E2B], /*906.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E45], /*913.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E2D], /*907.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E47], /*913.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E2F], /*907.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E49], /*914.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E31], /*908.25 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E4B], /*914.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E33], /*908.75 MHz   */
                  [NSNumber numberWithUnsignedInt:0x00180E4D], /*915.25 MHz   */
                  nil];
    
    LH1FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E1B], /*902.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E35], /*909.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1D], /*903.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E1F], /*903.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E21], /*904.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E23], /*904.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E25], /*905.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E27], /*905.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E29], /*906.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E2B], /*906.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E2D], /*907.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E2F], /*907.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E31], /*908.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E33], /*908.75 MHz   */
                   nil];
    
    LH2FreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E37], /*909.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E39], /*910.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E3B], /*910.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E3D], /*911.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E3F], /*911.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E41], /*912.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E43], /*912.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E45], /*913.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E47], /*913.75 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E49], /*914.25 MHz   */
                   [NSNumber numberWithUnsignedInt:0x00180E4B], /*914.75 MHz   */
                   nil];
    
    VNFreqValues=[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x00180E77], /*925.75 MHz  6 */
                  [NSNumber numberWithUnsignedInt:0x00180E6B], /*922.75 MHz  0 */
                  [NSNumber numberWithUnsignedInt:0x00180E7D], /*927.25 MHz  9 */
                  [NSNumber numberWithUnsignedInt:0x00180E75], /*925.25 MHz  5 */
                  [NSNumber numberWithUnsignedInt:0x00180E6D], /*923.25 MHz  1 */
                  [NSNumber numberWithUnsignedInt:0x00180E7B], /*926.75 MHz  8 */
                  [NSNumber numberWithUnsignedInt:0x00180E73], /*924.75 MHz  4 */
                  [NSNumber numberWithUnsignedInt:0x00180E6F], /*923.75 MHz  2 */
                  [NSNumber numberWithUnsignedInt:0x00180E79], /*926.25 MHz  7 */
                  [NSNumber numberWithUnsignedInt:0x00180E71], /*924.25 MHz  3 */
                  nil];
    
    FCCFreqIndex = @[@2, @19, @10, @15, @40,
                     @41, @42, @25, @13, @20,
                     @16, @22, @14, @5, @18,
                     @0, @23, @31, @47, @46,
                     @36, @35, @9, @24, @34,
                     @39, @1, @7, @6, @48,
                     @43, @4, @45, @44, @33,
                     @28, @17, @37, @11, @12,
                     @21, @27, @3, @8, @30,
                     @38, @29, @49, @32, @26];

    AUFreqIndex = @[@0, @3, @6, @8, @1,
                   @4, @7, @9, @2, @5];
    
    
    CNFreqIndex = @[@7, @6, @4, @0,
                    @10, @14, @3, @1,
                    @9, @8, @2, @13,
                    @12, @11, @5, @15,];
    
    
    ETSIFreqIndex = @[@0, @1, @2, @3];
    
    INFreqIndex = @[@0, @1, @2,];
    
    HKFreqIndex = @[@0, @3, @7, @1,
                    @3, @5, @6, @2];
    
    JPFreqIndex = @[@0, @1, @2, @3];
    
    KRFreqIndex = @[@3, @0, @5, @1, @4, @2];
    
    MYFreqIndex = @[@0, @3, @1, @4, @2, @5];
    
    TWFreqIndex = @[@10, @5, @1, @6,
                    @11, @4, @8, @2,
                    @9, @0, @7, @3];
    
    ZAFreqIndex = @[@4, @7, @0, @9, @2, @10, @6, @1, @8, @3, @5];
    
    BR1FreqIndex = @[@0, @22, @21, @23,
                     @9, @7, @6, @4,
                     @19, @12, @13, @3,
                     @5, @1, @18, @8,
                     @2, @16, @20, @17,
                     @11, @10, @14, @15,];
    
    BR2FreqIndex = @[@9, @1, @31,
                     @30, @3, @32,
                     @18, @16, @15,
                     @13, @5, @4,
                     @28, @21, @8,
                     @22, @2, @6,
                     @7, @12, @14,
                     @10, @27, @17,
                     @11, @25, @29,
                     @26, @20, @19,
                     @23, @0, @24];
    
    BR3FreqIndex = @[@1, @3, @5, @4, @8, @2, @6, @7, @0];
    BR4FreqIndex = @[@1, @3, @2, @0];
    BR5FreqIndex = @[@5, @3, @2, @0, @8, @9, @1, @4, @12, @13, @7, @6, @10, @11];
    IDFreqIndex = @[@0, @1, @2, @3];
    JEFreqIndex = @[@0, @4, @1, @5, @2, @6, @3];
    PHFreqIndex = @[@0, @5, @3, @7, @1, @6, @2, @4];
    ETSIUPPERBANDFreqIndex = @[@0, @1, @2];
    NZFreqIndex = @[@4, @7, @0, @9, @2, @10, @6, @1, @8, @3, @5];
    UH1FreqIndex = @[@1, @0, @8, @7, @5, @4, @6, @2, @9, @3];
    UH2FreqIndex = @[@13, @12, @14, @0, @10, @3, @4, @9, @7, @11, @8, @2, @1, @5, @6];
    LHFreqIndex = @[@0, @13, @1, @14, @2, @15, @3, @16, @4, @17, @5, @18, @6, @19, @7, @20, @8, @21, @9, @22, @10, @23, @11, @24, @12, @25];
    LH1FreqIndex = @[@0, @13, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12];
    LH2FreqIndex = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    VNFreqIndex = @[@6, @0, @9, @5, @1, @8, @4, @2, @7, @3];
    
    
    
    self.TableOfFrequencies = [[NSDictionary init] alloc];
    self.FrequencyValues = [[NSDictionary init] alloc];
    [self generateRegionList];
    
    for (NSString* region in self.RegionList) {
        if ([region isEqualToString:@"ETSI"] ||
            [region isEqualToString:@"G800"]) {
            [self.TableOfFrequencies setValue:ETSITableOfFreq forKey:@"ETSI"];
            [self.FrequencyValues setValue:ETSIFreqValues forKey:@"ETSI"];
            [self.FrequencyIndex setValue:ETSIFreqIndex forKey:@"ETSI"];
            [self.TableOfFrequencies setValue:ETSITableOfFreq forKey:@"G800"];
            [self.FrequencyValues setValue:ETSIFreqValues forKey:@"G800"];
            [self.FrequencyIndex setValue:ETSIFreqIndex forKey:@"G800"];
        }
        else if ([region isEqualToString:@"IN"]) {
            [self.TableOfFrequencies setValue:INTableOfFreq forKey:@"IN"];
            [self.FrequencyValues setValue:INFreqValues forKey:@"IN"];
            [self.FrequencyIndex setValue:INFreqIndex forKey:@"IN"];
        }
        else if ([region isEqualToString:@"AR"] ||
                 [region isEqualToString:@"CL"] ||
                 [region isEqualToString:@"CO"] ||
                 [region isEqualToString:@"CR"] ||
                 [region isEqualToString:@"DO"] ||
                 [region isEqualToString:@"PA"] ||
                 [region isEqualToString:@"UY"] ||
                 [region isEqualToString:@"FCC"]) {
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"FCC"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"FCC"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"FCC"];
            
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"AR"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"AR"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"AR"];
            
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"CO"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"CO"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"CO"];
            
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"CR"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"CR"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"CR"];
            
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"DO"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"DO"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"DO"];
            
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"PA"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"PA"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"PA"];
            
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"UY"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"UY"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"UY"];
            
            [self.TableOfFrequencies setValue:FCCTableOfFreq forKey:@"CL"];
            [self.FrequencyValues setValue:FCCFreqValues forKey:@"CL"];
            [self.FrequencyIndex setValue:FCCFreqIndex forKey:@"CL"];
        }
        else if ([region isEqualToString:@"BR1"]) {
            [self.TableOfFrequencies setValue:BR1TableOfFreq forKey:@"BR1"];
            [self.FrequencyValues setValue:BR1FreqValues forKey:@"BR1"];
            [self.FrequencyIndex setValue:BR1FreqIndex forKey:@"BR1"];
        }
        else if ([region isEqualToString:@"BR2"] ||
                 [region isEqualToString:@"PE"]) {
            [self.TableOfFrequencies setValue:BR2TableOfFreq forKey:@"BR2"];
            [self.FrequencyValues setValue:BR2FreqValues forKey:@"BR2"];
            [self.FrequencyIndex setValue:BR2FreqIndex forKey:@"BR2"];
        }
        else if ([region isEqualToString:@"BR3"]) {
            [self.TableOfFrequencies setValue:BR3TableOfFreq forKey:@"BR3"];
            [self.FrequencyValues setValue:BR3FreqValues forKey:@"BR3"];
            [self.FrequencyIndex setValue:BR3FreqIndex forKey:@"BR3"];
        }
        else if ([region isEqualToString:@"BR4"]) {
            [self.TableOfFrequencies setValue:BR4TableOfFreq forKey:@"BR4"];
            [self.FrequencyValues setValue:BR4FreqValues forKey:@"BR4"];
            [self.FrequencyIndex setValue:BR4FreqIndex forKey:@"BR4"];
        }
        else if ([region isEqualToString:@"BR5"]) {
            [self.TableOfFrequencies setValue:BR5TableOfFreq forKey:@"BR5"];
            [self.FrequencyValues setValue:BR5FreqValues forKey:@"BR5"];
            [self.FrequencyIndex setValue:BR5FreqIndex forKey:@"BR5"];
        }
        else if ([region isEqualToString:@"HK"] ||
                 [region isEqualToString:@"SG"] ||
                 [region isEqualToString:@"TH"]) {
            [self.TableOfFrequencies setValue:HKTableOfFreq forKey:@"HK"];
            [self.FrequencyValues setValue:HKFreqValues forKey:@"HK"];
            [self.FrequencyIndex setValue:HKFreqIndex forKey:@"HK"];
            [self.TableOfFrequencies setValue:HKTableOfFreq forKey:@"SG"];
            [self.FrequencyValues setValue:HKFreqValues forKey:@"SG"];
            [self.FrequencyIndex setValue:HKFreqIndex forKey:@"SG"];
            [self.TableOfFrequencies setValue:HKTableOfFreq forKey:@"TH"];
            [self.FrequencyValues setValue:HKFreqValues forKey:@"TH"];
            [self.FrequencyIndex setValue:HKFreqIndex forKey:@"TH"];
        }
        else if ([region isEqualToString:@"JE"]) {
            [self.TableOfFrequencies setValue:JETableOfFreq forKey:@"JE"];
            [self.FrequencyValues setValue:JEFreqValues forKey:@"JE"];
            [self.FrequencyIndex setValue:JEFreqIndex forKey:@"JE"];
        }
        else if ([region isEqualToString:@"KR"]) {
            [self.TableOfFrequencies setValue:KRTableOfFreq forKey:@"KR"];
            [self.FrequencyValues setValue:KRFreqValues forKey:@"KR"];
            [self.FrequencyIndex setValue:KRFreqIndex forKey:@"KR"];
        }
        else if ([region isEqualToString:@"MY"]) {
            [self.TableOfFrequencies setValue:MYTableOfFreq forKey:@"MY"];
            [self.FrequencyValues setValue:MYFreqValues forKey:@"MY"];
            [self.FrequencyIndex setValue:MYFreqIndex forKey:@"MY"];
        }
        else if ([region isEqualToString:@"PH"]) {
            [self.TableOfFrequencies setValue:PHTableOfFreq forKey:@"PH"];
            [self.FrequencyValues setValue:PHFreqValues forKey:@"PH"];
            [self.FrequencyIndex setValue:PHFreqIndex forKey:@"PH"];
        }
        else if ([region isEqualToString:@"VN"]) {
            [self.TableOfFrequencies setValue:VNTableOfFreq forKey:@"VN"];
            [self.FrequencyValues setValue:VNFreqValues forKey:@"VN"];
            [self.FrequencyIndex setValue:VNFreqIndex forKey:@"VN"];
        }
        else if ([region isEqualToString:@"ZA"]) {
            [self.TableOfFrequencies setValue:ZATableOfFreq forKey:@"ZA"];
            [self.FrequencyValues setValue:ZAFreqValues forKey:@"ZA"];
            [self.FrequencyIndex setValue:ZAFreqIndex forKey:@"ZA"];
        }
        else if ([region isEqualToString:@"LH1"]) {
            [self.TableOfFrequencies setValue:LH1TableOfFreq forKey:@"LH1"];
            [self.FrequencyValues setValue:LH1FreqValues forKey:@"LH1"];
            [self.FrequencyIndex setValue:LH1FreqIndex forKey:@"LH1"];
        }
        else if ([region isEqualToString:@"LH2"]) {
            [self.TableOfFrequencies setValue:LH2TableOfFreq forKey:@"LH2"];
            [self.FrequencyValues setValue:LH2FreqValues forKey:@"LH2"];
            [self.FrequencyIndex setValue:LH2FreqIndex forKey:@"LH2"];
        }
        else if ([region isEqualToString:@"UH1"]) {
            [self.TableOfFrequencies setValue:UH1TableOfFreq forKey:@"UH1"];
            [self.FrequencyValues setValue:UH1FreqValues forKey:@"UH1"];
            [self.FrequencyIndex setValue:UH1FreqIndex forKey:@"UH1"];
        }
        else if ([region isEqualToString:@"UH2"]) {
            [self.TableOfFrequencies setValue:UH2TableOfFreq forKey:@"UH2"];
            [self.FrequencyValues setValue:UH2FreqValues forKey:@"UH2"];
            [self.FrequencyIndex setValue:UH2FreqIndex forKey:@"UH2"];
        }
        else if ([region isEqualToString:@"LH"]) {
            [self.TableOfFrequencies setValue:LHTableOfFreq forKey:@"LH"];
            [self.FrequencyValues setValue:LHFreqValues forKey:@"LH"];
            [self.FrequencyIndex setValue:LHFreqIndex forKey:@"LH"];
        }
        else if ([region isEqualToString:@"AU"]) {
            [self.TableOfFrequencies setValue:AUTableOfFreq forKey:@"AU"];
            [self.FrequencyValues setValue:AUFreqValues forKey:@"AU"];
            [self.FrequencyIndex setValue:AUFreqIndex forKey:@"AU"];
        }
        else if ([region isEqualToString:@"NZ"]) {
            [self.TableOfFrequencies setValue:NZTableOfFreq forKey:@"NZ"];
            [self.FrequencyValues setValue:NZFreqValues forKey:@"NZ"];
            [self.FrequencyIndex setValue:NZFreqIndex forKey:@"NZ"];
        }
        else if ([region isEqualToString:@"CN"]) {
            [self.TableOfFrequencies setValue:CNTableOfFreq forKey:@"CN"];
            [self.FrequencyValues setValue:CNFreqValues forKey:@"CN"];
            [self.FrequencyIndex setValue:CNFreqIndex forKey:@"CN"];
        }
        else if ([region isEqualToString:@"ID"]) {
            [self.TableOfFrequencies setValue:IDTableOfFreq forKey:@"ID"];
            [self.FrequencyValues setValue:IDFreqValues forKey:@"ID"];
            [self.FrequencyIndex setValue:IDFreqIndex forKey:@"ID"];
        }
        else if ([region isEqualToString:@"TW"]) {
            [self.TableOfFrequencies setValue:TWTableOfFreq forKey:@"TW"];
            [self.FrequencyValues setValue:TWFreqValues forKey:@"TW"];
            [self.FrequencyIndex setValue:TWFreqIndex forKey:@"TW"];
        }
        else if ([region isEqualToString:@"JP"]) {
            [self.TableOfFrequencies setValue:JPTableOfFreq forKey:@"JP"];
            [self.FrequencyValues setValue:JPFreqValues forKey:@"JP"];
            [self.FrequencyIndex setValue:JPFreqIndex forKey:@"JP"];
        }
        else if ([region isEqualToString:@"ETSIUPPERBAND"]) {
            [self.TableOfFrequencies setValue:ETSIUPPERBANDTableOfFreq forKey:@"ETSIUPPERBAND"];
            [self.FrequencyValues setValue:ETSIUPPERBANDFreqValues forKey:@"ETSIUPPERBAND"];
            [self.FrequencyIndex setValue:ETSIUPPERBANDFreqIndex forKey:@"ETSIUPPERBAND"];
        }

    }
    
}

@end
