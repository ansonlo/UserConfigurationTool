//
//  P_PropertyList2ButtonCellView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListBasicCellView.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_PropertyList2ButtonCellView : P_PropertyListBasicCellView

- (void)p_setShowsControlButtons:(BOOL)showsControlButtons addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled;

@end

NS_ASSUME_NONNULL_END
