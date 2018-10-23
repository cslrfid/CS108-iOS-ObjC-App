//
//  CSLBleTagAccessControl.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 17/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLBleTagAccessControl.h"

@implementation CSLBleTagAccessControl


- (BOOL) TAGMSK_DESC_CFG:(BOOL)isEnable selectTarget:(Byte)sel_target selectAction:(Byte)sel_action {
    return true;
}
- (BOOL) TAGMSK_BANK:(Byte)bank {
    return true;
}
- (BOOL) TAGMSK_PTR:(unsigned short)ptr {
    return true;
}
- (BOOL) TAGMSK_LEN:(Byte)length {
    return true;
}
- (BOOL) TAGMSK_0_3:(unsigned short)data {
    return true;
}
- (BOOL) TAGMSK_4_7:(unsigned short)data {
    return true;
}
- (BOOL) TAGMSK_8_11:(unsigned short)data; {
    return true;
}
- (BOOL) TAGMSK_12_15:(unsigned short)data {
    return true;
}
- (BOOL) TAGMSK_16_19:(unsigned short)data {
    return true;
}
- (BOOL) TAGMSK_20_23:(unsigned short)data {
    return true;
}
- (BOOL) TAGMSK_24_27:(unsigned short)data {
    return true;
}
- (BOOL) TAGMSK_28_31:(unsigned short)data {
    return true;
}

- (BOOL) TAGACC_BANK:(Byte)bank {
    return true;
}
- (BOOL) TAGACC_PTR:(unsigned short)ptr secondBank:(unsigned short)ptr2 {
    return true;
}
- (BOOL) TAGACC_CNT:(Byte)length secondBank:(Byte)length2 {
    return true;
}
- (BOOL) TAGACC_ACCPWD:(unsigned short)password {
    return true;
}
- (BOOL) TAGWRDAT_0:(unsigned short)data_word data_offset:(unsigned short)offset {
    return true;
}
- (BOOL) TAGWRDAT_1:(unsigned short)data_word data_offset:(unsigned short)offset {
    return true;
}
- (BOOL) TAGWRDAT_2:(unsigned short)data_word data_offset:(unsigned short)offset {
    return true;
}
- (BOOL) TAGWRDAT_3:(unsigned short)data_word data_offset:(unsigned short)offset {
    return true;
}
- (BOOL) TAGWRDAT_4:(unsigned short)data_word data_offset:(unsigned short)offset {
    return true;
}
- (BOOL) TAGWRDAT_5:(unsigned short)data_word data_offset:(unsigned short)offset {
    return true;
}
- (BOOL) TAGWRDAT_6:(unsigned short)data_word data_offset:(unsigned short)offset {
    return true;
}
- (BOOL) TAGWRDAT_7:(unsigned short)data_word data_offset:(unsigned short)offset; {
    return true;
}
- (BOOL) sendHostCommandWrite {
    return true;
}
- (BOOL) sendHostCommandRead {
    return true;
}

@end
