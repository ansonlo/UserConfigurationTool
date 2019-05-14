//
//  P_PropertyList2ButtonCellView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListBasicCellView.h"

NS_ASSUME_NONNULL_BEGIN
@class P_PropertyList2ButtonCellView, P_Data, P_Config;

@protocol P_PropertyList2ButtonCellViewDelegate <P_PropertyListCellViewDelegate>

@optional
- (void)p_propertyList2ButtonCellPlusAction:(P_PropertyList2ButtonCellView *)cellView;
- (void)p_propertyList2ButtonCellMinusAction:(P_PropertyList2ButtonCellView *)cellView;

@end

@interface P_PropertyList2ButtonCellView : P_PropertyListBasicCellView

@property (nonatomic, weak) id<P_PropertyList2ButtonCellViewDelegate> delegate;

- (void)p_setControlData:(P_Data *)p;
- (void)p_setControlData:(P_Data *)p config:(P_Config *)c;
- (void)p_setShowsControlButtons:(BOOL)showsControlButtons addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled;

@end

NS_ASSUME_NONNULL_END
