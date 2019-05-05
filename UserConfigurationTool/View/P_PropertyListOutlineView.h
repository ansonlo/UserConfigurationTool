//
//  P_PropertyListOutlineView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "P_TypeHeader.h"
@class P_Data;

NS_ASSUME_NONNULL_BEGIN

/** 剪切板 */
extern NSPasteboardName const NSPasteboardName_P_Data;

@protocol P_PropertyListOutlineView_MenuOperationDelegate;

@interface P_PropertyListOutlineView : NSOutlineView

@property (nonatomic, weak) id<P_PropertyListOutlineView_MenuOperationDelegate>menuOperationDelegate;

#pragma mark - 更新值key、type、value
- (void)updateItem:(id)newItem ofItem:(id)item;
- (void)updateKey:(NSString *)key ofItem:(id)item withView:(BOOL)withView;
- (void)updateType:(P_PlistTypeName)type value:(id)value childDatas:(NSArray <P_Data *> * _Nullable)childDatas ofItem:(id)item;
- (void)updateValue:(id)value ofItem:(id)item withView:(BOOL)withView;

@end

NS_ASSUME_NONNULL_END
