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
/**
 This category add tag access function to the CSLBleReader class, including read, write and security features.
 */
@interface CSLBleReader (AccessControl) {
    
}
- (BOOL)setParametersForTagAccess;
- (BOOL) TAGMSK_DESC_SEL:(Byte)desc_idx;
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

- (BOOL) TAGACC_DESC_CFG:(BOOL)isVerify retryCount:(Byte)count;
- (BOOL) TAGACC_LOCKCFG:(UInt32)lockCommandConfigBits;

- (BOOL) sendHostCommandRead;
- (BOOL) sendHostCommandWrite;
- (BOOL) sendHostCommandSearch;
- (BOOL) sendHostCommandLock;

/**
 Clear all tag select criteria (8 in total)
 @return TRUE if the operation is successful
 */
- (BOOL) clearAllTagSelect;
/**
 EPC match configuration
 @param match_enable 1 = EPC matching enabled, 0 = EPC matching disabled
 @param epc_notEpc 0 = match on EPC, 1 = match on ~EPC
 @param match_length Length of EPC match data in bits
 @param match_offset Offset in bits of where to start the compare in the EPC read from the tag
 @return TRUE if the operation is successful
 */
- (BOOL) setEpcMatchConfiguration:(BOOL)match_enable matchOn:(BOOL)epc_notEpc matchLength:(UInt16)match_length matchOffset:(UInt16)match_offset;
/**
 Delay time between inventory cycle.
 @param cycle_delay Time delay in-between each inventory cycle in ms (use to reduce tag rate).  The values should be between 0 to 2000.  0 means fastest tag rate.
 @return TRUE if the operation is successful
 */
- (BOOL) setInventoryCycleDelay:(UInt32) cycle_delay;
/**
 Select tag before tag access (read/write) operation
 @param maskbank Mask bank to be used for tag selection
 @param ptr Pointer to the start of the memory address, to be expressed by bits
 @param length Size of the mask expressed in number of bits
 @param mask mask value
 @return TRUE if the operation is successful
 */
- (BOOL) selectTag:(MEMORYBANK)maskbank maskPointer:(UInt16)ptr maskLength:(UInt32)length maskData:(NSData*)mask;
/**
 Select tag before tag access (search) operation
 @param maskbank Mask bank to be used for tag selection
 @param ptr Pointer to the start of the memory address, to be expressed by bits
 @param length Size of the mask expressed in number of bits
 @param mask mask value
 @return TRUE if the operation is successful
 */
- (BOOL) selectTagForSearch:(MEMORYBANK)maskbank maskPointer:(UInt16)ptr maskLength:(UInt32)length maskData:(NSData*)mask;
/**
 Send singular tag read command
 @param bank Bank to be read from
 @param offset Pointer to the start of the memory address, by the number of words
 @param count Number of words to be read
 @param password Access password for the tag
 @param mask_bank Mask bank to be used for tag selection
 @param mask_pointer Pointer to the start of the memory address, to be expressed by bits
 @param mask_Length Size of the mask expressed in number of bits
 @param mask_data mask value
 @return TRUE if the operation is successful
 */
- (BOOL) startTagMemoryRead:(MEMORYBANK)bank dataOffset:(UInt16)offset dataCount:(UInt16)count ACCPWD:(UInt32)password maskBank:(MEMORYBANK)mask_bank maskPointer:(UInt16)mask_pointer maskLength:(UInt32)mask_Length maskData:(NSData*)mask_data;
/**
 Send singular tag write command
 @param bank Bank to be writing to
 @param offset Pointer to the start of the memory address, by the number of words
 @param count Number of words to be written
 @param password Access password for the tag
 @param mask_bank Mask bank to be used for tag selection
 @param mask_pointer Pointer to the start of the memory address, to be expressed by bits
 @param mask_Length Size of the mask expressed in number of bits
 @param mask_data mask value
 @return TRUE if the operation is successful
 */
- (BOOL) startTagMemoryWrite:(MEMORYBANK)bank dataOffset:(UInt16)offset dataCount:(UInt16)count writeData:(NSData*)data ACCPWD:(UInt32)password maskBank:(MEMORYBANK)mask_bank maskPointer:(UInt16)mask_pointer maskLength:(UInt32)mask_Length maskData:(NSData*)mask_data;
/**
 Send singular tag security command
 @param lockCommandConfigBits 20 configuration bits for defining security status of a tag.  Mask defines which bank to execute the locking, action defines what type of lock or unlock commands to carry out. For details please reference EPC Air Interface document.
 @param password Access password for the tag
 @param mask_bank Mask bank to be used for tag selection
 @param mask_pointer Pointer to the start of the memory address, to be expressed by bits
 @param mask_Length Size of the mask expressed in number of bits
 @param mask_data mask value
 @return TRUE if the operation is successful
 */
- (BOOL) startTagMemoryLock:(UInt32)lockCommandConfigBits ACCPWD:(UInt32)password maskBank:(MEMORYBANK)mask_bank maskPointer:(UInt16)mask_pointer maskLength:(UInt32)mask_Length maskData:(NSData*)mask_data;
/**
 Send singular tag search command
 @param mask_bank Mask bank to be used for tag selection
 @param mask_pointer Pointer to the start of the memory address, to be expressed by bits
 @param mask_Length Size of the mask expressed in number of bits
 @param mask_data mask value
 @return TRUE if the operation is successful
 */
- (BOOL) startTagSearch:(MEMORYBANK)mask_bank maskPointer:(UInt16)mask_pointer maskLength:(UInt32)mask_Length maskData:(NSData*)mask_data;
/**
 Stop singular tag search
 @return TRUE if the operation is successful
 */
- (BOOL)stopTagSearch;
/**
 Select tag before tag inventory operation
 @param maskbank Mask bank to be used for tag selection
 @param ptr Pointer to the start of the memory address, to be expressed by bits
 @param length Size of the mask expressed in number of bits
 @param mask mask value
 @param action What action to perform on inventories or SL flags as indicated to tags during
 Select operation
 @return TRUE if the operation is successful
 */
- (BOOL) selectTagForInventory:(MEMORYBANK)maskbank maskPointer:(UInt16)ptr maskLength:(UInt32)length maskData:(NSData*)mask sel_action:(Byte)action;
/**
 Select tag before tag inventory operation
 @param maskbank Mask bank to be used for tag selection
 @param ptr Pointer to the start of the memory address, to be expressed by bits
 @param length Size of the mask expressed in number of bits
 @param mask mask value
 @param action What action to perform on inventories or SL flags as indicated to tags during
 Select operation
 @param delay CW hold time in ms after Select command.
 @return TRUE if the operation is successful
 */
- (BOOL) selectTagForInventory:(MEMORYBANK)maskbank maskPointer:(UInt16)ptr maskLength:(UInt32)length maskData:(NSData*)mask sel_action:(Byte)action delayTime:(Byte)delay;
@end

NS_ASSUME_NONNULL_END
