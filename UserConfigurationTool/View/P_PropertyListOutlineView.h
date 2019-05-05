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

@interface P_PropertyListOutlineView : NSOutlineView

#pragma mark - 更新值key、type、value
- (void)updateItem:(id)newItem ofItem:(id)item;
- (void)updateKey:(NSString *)key ofItem:(id)item withView:(BOOL)withView;
- (void)updateType:(P_PlistTypeName)type value:(id)value childDatas:(NSArray <P_Data *> * _Nullable)childDatas ofItem:(id)item;
- (void)updateValue:(id)value ofItem:(id)item withView:(BOOL)withView;

@end

NS_ASSUME_NONNULL_END
