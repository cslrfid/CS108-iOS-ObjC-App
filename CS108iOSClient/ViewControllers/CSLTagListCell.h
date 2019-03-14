//
//  CSLTagListCell.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSLTagListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbCellEPC;
@property (weak, nonatomic) IBOutlet UILabel *lbCellBank;

@end

NS_ASSUME_NONNULL_END
