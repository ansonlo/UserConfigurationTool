//
//  P_PropertyListDatePickerCellView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListBasicCellView.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_PropertyListDatePickerCellView : P_PropertyListBasicCellView

- (void)p_setControlWithDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
