//
//  P_PropertyListPopUpButtonCellView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListBasicCellView.h"
#import "P_TypeHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_PropertyListPopUpButtonCellView : P_PropertyListBasicCellView

- (void)p_setControlWithBoolean:(BOOL)boolean;
- (void)p_setControlWithString:(P_PlistTypeName)str;
- (void)p_setShowsControlButtons:(BOOL)showsControlButtons;

@end

NS_ASSUME_NONNULL_END
