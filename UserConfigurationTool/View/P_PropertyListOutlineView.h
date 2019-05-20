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

@protocol NSViewDraggingDestination;

NS_ASSUME_NONNULL_BEGIN

@interface P_PropertyListOutlineView : NSOutlineView

@property (nonatomic, readonly) NSPasteboardType pasteboardType;

#pragma mark - 移动
- (void)moveItem:(id)item toIndex:(NSUInteger)toIndex inParent:(id)parent;
#pragma mark - 插入值key、type、value
- (void)insertItem:(id)newItem ofItem:(id)item;
#pragma mark - 删除值key、type、value
- (void)deleteItem:(id)item;
#pragma mark - 更新值key、type、value
- (void)updateItem:(id)newItem ofItem:(id)item;
- (void)updateKey:(NSString *)key ofItem:(id)item withView:(BOOL)withView;
- (void)updateType:(P_PlistTypeName)type value:(id)value childDatas:(NSArray <P_Data *> * _Nullable)childDatas ofItem:(id)item;
- (void)updateValue:(id)value ofItem:(id)item withView:(BOOL)withView;

@property (nonatomic, weak) id<NSViewDraggingDestination>dragDelegate;

@end

@protocol NSViewDraggingDestination <NSObject>

- (NSArray <NSString *>*)supportFile;

- (void)didDragFiles:(NSArray *)files;

@end

NS_ASSUME_NONNULL_END
