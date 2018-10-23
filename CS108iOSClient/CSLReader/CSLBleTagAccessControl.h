//
//  CSLBleTagAccessControl.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 17/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSLBleTagAccessControl : NSObject

- (BOOL) TAGMSK_DESC_CFG:(BOOL)isEnable selectTarget:(Byte)sel_target selectAction:(Byte)sel_action;
- (BOOL) TAGMSK_BANK:(Byte)bank;
- (BOOL) TAGMSK_PTR:(unsigned short)ptr;
- (BOOL) TAGMSK_LEN:(Byte)length;
- (BOOL) TAGMSK_0_3:(unsigned short)data;
- (BOOL) TAGMSK_4_7:(unsigned short)data;
- (BOOL) TAGMSK_8_11:(unsigned short)data;
- (BOOL) TAGMSK_12_15:(unsigned short)data;
- (BOOL) TAGMSK_16_19:(unsigned short)data;
- (BOOL) TAGMSK_20_23:(unsigned short)data;
- (BOOL) TAGMSK_24_27:(unsigned short)data;
- (BOOL) TAGMSK_28_31:(unsigned short)data;
- (BOOL) TAGACC_BANK:(Byte)bank;
- (BOOL) TAGACC_PTR:(unsigned short)ptr secondBank:(unsigned short)ptr2;
- (BOOL) TAGACC_CNT:(Byte)length secondBank:(Byte)length2;
- (BOOL) TAGACC_ACCPWD:(unsigned short)password;
- (BOOL) TAGWRDAT_0:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) TAGWRDAT_1:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) TAGWRDAT_2:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) TAGWRDAT_3:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) TAGWRDAT_4:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) TAGWRDAT_5:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) TAGWRDAT_6:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) TAGWRDAT_7:(unsigned short)data_word data_offset:(unsigned short)offset;
- (BOOL) sendHostCommandRead;
- (BOOL) sendHostCommandWrite;

@end

NS_ASSUME_NONNULL_END
