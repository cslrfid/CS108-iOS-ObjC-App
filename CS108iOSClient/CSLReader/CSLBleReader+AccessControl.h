//
//  CSLBleReader+AccessControl.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 23/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLBleReader.h"

#define TAGMSK_0_3 0x0805
#define TAGMSK_4_7 0x0806
#define TAGMSK_8_11 0x0807
#define TAGMSK_12_15 0x0808
#define TAGMSK_16_19 0x0809
#define TAGMSK_20_23 0x080A
#define TAGMSK_24_27 0x080B
#define TAGMSK_28_31 0x080C
#define TAGWRDAT_0 0x0A09
#define TAGWRDAT_1 0x0A0A
#define TAGWRDAT_2 0x0A0B
#define TAGWRDAT_3 0x0A0C
#define TAGWRDAT_4 0x0A0D
#define TAGWRDAT_5 0x0A0E
#define TAGWRDAT_6 0x0A0F
#define TAGWRDAT_7 0x0A10

///Query sessions
typedef NS_ENUM(Byte, MEMORYBANK)
{
    RESERVED = 0,
    EPC,
    TID,
    USER
};

NS_ASSUME_NONNULL_BEGIN

@interface CSLBleReader (AccessControl) {
    
}
/**
 This will send out all the commands needed before tag acccess inclduing (1) setting antenna cycles (2) Query config (3) setting FixedQ, Q=0
 @return TRUE if the operation is successful
 */
- (BOOL)setParametersForTagAccess;
- (BOOL) TAGMSK_DESC_CFG:(BOOL)isEnable selectTarget:(Byte)sel_target selectAction:(Byte)sel_action;
- (BOOL) TAGMSK_BANK:(MEMORYBANK)bank;
- (BOOL) TAGMSK_PTR:(UInt16)ptr;
- (BOOL) TAGMSK_LEN:(Byte)length;
- (BOOL) setTAGMSK:(UInt16)TAGMSKAddr tagMask:(UInt32)mask;

- (BOOL) TAGACC_BANK:(MEMORYBANK)bank acc_bank2:(MEMORYBANK)bank2;
- (BOOL) TAGACC_PTR:(UInt32)ptr;
- (BOOL) TAGACC_PTR:(UInt32)ptr secondBank:(UInt32)ptr2;
- (BOOL) TAGACC_CNT:(Byte)length secondBank:(Byte)length2;
- (BOOL) TAGACC_ACCPWD:(UInt32)password;

- (BOOL) setTAGWRDAT:(UInt16)TAGWRDATAddr data_word:(UInt16)word data_offset:(UInt16)offset;

- (BOOL) sendHostCommandRead;
- (BOOL) sendHostCommandWrite;

- (BOOL) selectTag:(MEMORYBANK)maskbank maskPointer:(UInt16)ptr maskLength:(UInt32)length maskData:(NSData*)mask;
- (BOOL) startTagMemoryRead:(MEMORYBANK)bank dataOffset:(UInt16)offset dataCount:(UInt16)count ACCPWD:(UInt32)password maskBank:(MEMORYBANK)mask_bank maskPointer:(UInt16)mask_pointer maskLength:(UInt32)mask_Length maskData:(NSData*)mask_data;





@end

NS_ASSUME_NONNULL_END
