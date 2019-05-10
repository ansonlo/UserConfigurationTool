//
//  P_PropertyListBasicCellView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/24.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol P_PropertyListCellViewDelegate;

@interface P_PropertyListBasicCellView : NSTableCellView

@property (nonatomic, weak) id<P_PropertyListCellViewDelegate> delegate;

- (void)p_setControlWithString:(NSString *)str;
- (void)p_setControlWithString:(NSString *)str toolTip:(NSString *)toolTip;

- (void)p_setControlEditable:(BOOL)editable;
- (void)p_setControlEditableWithOutTextColor:(BOOL)editable;

@end

@protocol P_PropertyListCellViewDelegate <NSObject>

@optional


/**
 验证输入内容

 @param cellView 编辑视图
 @param value 编辑后的值
 @return 返回是否验证通过
 */
- (BOOL)p_propertyListCell:(P_PropertyListBasicCellView *)cellView isValidObject:(id)value;
/**
 编辑完毕后的回调

 @param cellView 编辑视图
 @param value 编辑后的值
 @return 返回实际需要显示的值，如果返回nil，不会改变值。
 */
- (id)p_propertyListCellDidEndEditing:(P_PropertyListBasicCellView *)cellView value:(id)value;

@end

NS_ASSUME_NONNULL_END
