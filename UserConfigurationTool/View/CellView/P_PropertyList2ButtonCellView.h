//
//  P_PropertyList2ButtonCellView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListBasicCellView.h"

NS_ASSUME_NONNULL_BEGIN
@class P_PropertyList2ButtonCellView;

@protocol P_PropertyList2ButtonCellViewDelegate <P_PropertyListCellViewDelegate>

@optional
- (id)p_propertyList2ButtonCellPlusAction:(P_PropertyList2ButtonCellView *)cellView;
- (id)p_propertyList2ButtonCellMinusAction:(P_PropertyList2ButtonCellView *)cellView;

@end

@interface P_PropertyList2ButtonCellView : P_PropertyListBasicCellView

@property (nonatomic, weak) id<P_PropertyList2ButtonCellViewDelegate> delegate;

- (void)p_setShowsControlButtons:(BOOL)showsControlButtons addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled;

@end

NS_ASSUME_NONNULL_END
