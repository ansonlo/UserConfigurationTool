//
//  P_OutlineViewController.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OutlineViewController.h"
#import "P_TypeHeader.h"
#import "P_Data.h"
#import "P_Data+P_Exten.h"
#import "P_Config.h"

#import "NSView+P_Animation.h"
#import "NSString+P_16Data.h"


#import "P_PropertyListRowView.h"
#import "P_PropertyListBasicCellView.h"

#import "P_PropertyList2ButtonCellView.h"
#import "P_PropertyListPopUpButtonCellView.h"
#import "P_PropertyListDatePickerCellView.h"

@interface P_OutlineViewController () <P_PropertyList2ButtonCellViewDelegate>
{
    
}

@property (nonatomic, strong) NSArray <P_Data *>*dragItems;

@end

@implementation P_OutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    /** outlineView注册操作类型 */
    [self.outlineView registerForDraggedTypes:[NSArray arrayWithObjects:self.outlineView.pasteboardType, nil]];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

// The NSOutlineView uses 'nil' to indicate the root item. We return our root tree node for that case.
- (NSArray *)childrenForItem:(id)item {
    if (item == nil) {
        if (self.root) {
            return @[self.root];
        } else {
            return @[];
        }
    } else {
        return [item childDatas];
    }
}

#pragma mark - NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    return [children count];
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    // This will return an NSTreeNode with our model object as the representedObject
    return [children objectAtIndex:index];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    // 'item' will always be non-nil. It is an NSTreeNode, since those are always the objects we give NSOutlineView. We access our model object from it.
    P_Data *p = item;
    // We can expand items if the model tells us it is a container
    return p.isExpandable;
}

/* NOTE: this method is optional for the View Based OutlineView.
 */
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
    return nil;
}

#pragma mark - drag & drop

//阶段二之支持拖拽
- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item{
    if ([item isKindOfClass:[P_Data class]]){
        P_Data *p = (P_Data *)item;
        if (p.operation & P_Data_Operation_Move) {
            NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
            [pbItem setString:[NSString stringWithFormat:@"%ld", self.outlineView.selectedRow] forType:self.outlineView.pasteboardType];
            return pbItem;
        }
    }
    return nil;
}

/** 开始拖缀 */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems NS_AVAILABLE_MAC(10_7)
{
    self.dragItems = draggedItems;
    [session.draggingPasteboard setData:[NSData data] forType:self.outlineView.pasteboardType];
    
    /** 组合拖动图像的组件 */
    [session enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent
                                       forView:outlineView
                                       classes:[NSArray arrayWithObject:[NSPasteboardItem class]]
                                 searchOptions:@{}
                                    usingBlock:^(NSDraggingItem * _Nonnull draggingItem, NSInteger idx, BOOL * _Nonnull stop) {
                                        id item = [draggedItems objectAtIndex:idx];
                                        NSInteger row = [outlineView rowForItem:item];
                                        NSTableCellView *cellView = [outlineView viewAtColumn:0 row:row makeIfNecessary:NO];
                                        draggingItem.imageComponentsProvider = ^NSArray*(void) { return cellView.draggingImageComponents;};
                                    }];
    
}

//阶段二之判断是否为有效拖拽
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index{
    NSDragOperation sourceDragMask = [info draggingSourceOperationMask];
    NSPasteboard *pasteboard = info.draggingPasteboard;
    /** 只支持同级拖动 */
    P_Data *p = (P_Data *)item;
    for (P_Data *obj in self.dragItems) {
        if (![p containsData:obj]) {
            return NSDragOperationNone;
        }
    }
    if (index >= 0) {
        if ([[pasteboard types] containsObject:self.outlineView.pasteboardType]) {
            if (sourceDragMask & NSDragOperationMove) {
                return NSDragOperationGeneric;
            }
        }
    }
    return NSDragOperationNone;
}

//阶段二之拖拽调整位置
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index{
    NSPasteboard *pasteboard = [info draggingPasteboard];
    NSPasteboardItem *pbItem = pasteboard.pasteboardItems.firstObject;
    NSString *selectedRowStr = [pbItem stringForType:self.outlineView.pasteboardType];
    if (selectedRowStr) {
        P_Data *p = (P_Data *)item;
        /** 这里是单个拖动 */
        for (P_Data *obj in self.dragItems) {
            BOOL canDo = YES;
            NSInteger selectIndex = [p.childDatas indexOfObject:obj];
            if (index == selectIndex) {
                canDo = NO;
            }
            else if (index == (selectIndex + 1)) {
                canDo = NO;
            }
            if (canDo) {
                [self.outlineView moveItem:obj toIndex:index inParent:item];
            }
        }
    }
    return YES;
}

/** 拖缀结束 */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation NS_AVAILABLE_MAC(10_7)
{
    self.dragItems = nil;
}

#pragma mark - sort

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors;
{
    //Make the outline view as the first responder to prevent issues with currently edited text fields.
    [outlineView.window makeFirstResponder:outlineView];
    
    /** 记录之前选中的对象 */
    id item = [outlineView itemAtRow:outlineView.selectedRow];
    
    /** 排序&刷新 */
    [self.root sortWithSortDescriptors:outlineView.sortDescriptors recursively:YES];
    [self.outlineView reloadItem:nil reloadChildren:YES];
    
    /** 重置选中对象的视图 */
    NSInteger selectionRow = [outlineView rowForItem:item];
    [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionRow] byExtendingSelection:NO];
    [outlineView scrollRowToVisible:selectionRow];
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
    // Query our model for the answer to this question
    P_Data *p = item;
    // We can expand items if the model tells us it is a container
    return p.isExpandable;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    // Query our model for the answer to this question
    P_Data *p = item;
    // We can expand items if the model tells us it is a container
    return p.isExpandable;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    P_Data *p = item;
    P_PropertyListRowView* rowView = [P_PropertyListRowView new];
    rowView.p = p;
    
    return rowView;
}

- (nullable NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    P_Data *p = item;
    P_PlistCellName cellIdentifier = nil;
    BOOL editable = YES;
    P_Config *c = nil;
    
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:PlistColumnIdentifier.Key])
    {
        editable = (p.editable & P_Data_Editable_Key) && ![p.parentData.type isEqualToString: Plist.Array];
        if (editable) {
            c = [[P_Config config] configAtKey: p.parentData.key];
        }
        
        /**
         以下情况不需要显示下拉框
         1、root
         2、上级类型为Array || 不能编辑
         3、没有配置项
         */
        if (p.level == 0 || !editable || c == nil) {
            cellIdentifier = PlistCell.KeyCell;
        } else {
            cellIdentifier = PlistCell.ComboKeyCell;
        }
    }
    else if ([identifier isEqualToString:PlistColumnIdentifier.Type])
    {
        cellIdentifier = PlistCell.TypeCell;
        editable = (p.editable & P_Data_Editable_Type);
    }
    else if ([identifier isEqualToString:PlistColumnIdentifier.Value])
    {
        editable = (p.editable & P_Data_Editable_Value) && !([p.type isEqualToString: Plist.Array] || [p.type isEqualToString: Plist.Dictionary]);
        if ([p.type isEqualToString: Plist.Boolean]) {
            cellIdentifier = PlistCell.ValueBoolCell;
        } else if ([p.type isEqualToString: Plist.Date]) {
            cellIdentifier = PlistCell.ValueDateCell;
        } else {
            cellIdentifier = PlistCell.ValueCell;
        }
    }
    
    P_PropertyListBasicCellView *cellView = [outlineView makeViewWithIdentifier:cellIdentifier owner:self];
    cellView.delegate = self;
    
    
    if ([identifier isEqualToString:PlistColumnIdentifier.Key])
    {
        
        [(P_PropertyList2ButtonCellView *)cellView p_setControlData:p config:c];
    }
    else if ([identifier isEqualToString:PlistColumnIdentifier.Type])
    {
        [(P_PropertyListPopUpButtonCellView *)cellView p_setControlWithString:p.type];
    }
    else if ([identifier isEqualToString:PlistColumnIdentifier.Value])
    {
        if ([p.type isEqualToString: Plist.Boolean]) {
            [(P_PropertyListPopUpButtonCellView *)cellView p_setControlWithBoolean:[p.value boolValue]];
        } else if ([p.type isEqualToString: Plist.Date]) {
            [(P_PropertyListDatePickerCellView *)cellView p_setControlWithDate:p.value];
        } else {
            [cellView p_setControlWithString:p.valueDesc];
        }
    }
    
    if ([identifier isEqualToString:PlistColumnIdentifier.Key] && (p.level == 0 || [p.parentData.type isEqualToString:Plist.Array])) {
        [cellView p_setControlEditableWithOutTextColor:editable];
    } else {
        [cellView p_setControlEditable:editable];
    }
    
    
    return cellView;
}

// 不能移动column
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex
{
    NSTableColumn *column = outlineView.tableColumns[columnIndex];
    column.headerCell.state = NSControlStateValueOff;
    
    return NO;
}


#pragma mark - P_PropertyListCellViewDelegate
- (BOOL)p_propertyListCell:(P_PropertyListBasicCellView *)cellView isValidObject:(id)value
{
    NSUInteger row = [self.outlineView rowForView:cellView];
    NSUInteger column = [self.outlineView columnForView:cellView];
    
    id item = [self.outlineView itemAtRow:row];
    P_Data *p = item;
    
    if(column == 0)
    {
        NSString *key = value;
        
        /** key不能为空 */
        if (key.length == 0) {
            [cellView p_flashError];
            
            [self p_showAlertViewWith:NSLocalizedString(@"The key can not be empty.", @"")];
            
            return NO;
        }
        
        if([p containsChildrenAndWithOutSelfWithKey:key])
        {
            [cellView p_flashError];
            
            [self p_showAlertViewWith:[NSString stringWithFormat:NSLocalizedString(@"The key “%@” already exists in containing item.", @""), key]];
            
            return NO;
        }
    }
    else if(column == 2)
    {
        
        BOOL (^validateValue)(NSString *) = ^(NSString *v){
            //验证value必须有值，@"", [NSData data] 不算有值
            if ([v isKindOfClass:[NSString class]]) {
                if ([p.type isEqualToString:Plist.Data]) {
                    if ([v isEqualToString:@"<>"]) {
                        return NO;
                    }
                } else if ([p.type isEqualToString:Plist.String]) {
                    if ([v length] == 0) {
                        return NO;
                    }
                }
            }
            return YES;
        };
        
        if (p.requested) {
            
            if (!validateValue(value)) {
                [cellView p_flashError];
                
                [self p_showAlertViewWith:NSLocalizedString(@"The value can not be empty.", @"")];
                // NSTextField会出现无法恢复的情况。需要重新赋值。
                [cellView p_setControlWithString:p.valueDesc];
                
                return NO;
            }
        }
#warning 验证NSData的正确性
        if (1==0)
        {
            [cellView p_flashError];
            return NO;
        }
    }
    return YES;
}

- (id)p_propertyListCellDidEndEditing:(P_PropertyListBasicCellView *)cellView value:(id)value
{
    NSUInteger row = [self.outlineView rowForView:cellView];
    NSUInteger column = [self.outlineView columnForView:cellView];
    
    id item = [self.outlineView itemAtRow:row];
    P_Data *p = item;
    
    if(column == 0)
    {
        P_Data *new_p = value;
        
        [self.outlineView updateItem:new_p ofItem:p];
    }
    else if(column == 1)
    {
        P_PlistTypeName type = value;
        [self.outlineView updateType:type value:p.value childDatas:nil ofItem:item];
    }
    else if(column == 2)
    {
        [self.outlineView updateValue:value ofItem:item withView:NO];
        return p.valueDesc;
    }
    
    return nil;
}

#pragma mark - P_PropertyList2ButtonCellViewDelegate
- (void)p_propertyList2ButtonCellPlusAction:(P_PropertyList2ButtonCellView *)cellView
{
    NSUInteger row = [self.outlineView rowForView:cellView];
    
    id item = [self.outlineView itemAtRow:row];
    
    [self.outlineView insertItem:[[P_Data alloc] init] ofItem:item];
}
- (void)p_propertyList2ButtonCellMinusAction:(P_PropertyList2ButtonCellView *)cellView
{
    NSUInteger row = [self.outlineView rowForView:cellView];
    
    id item = [self.outlineView itemAtRow:row];
    
    [self.outlineView deleteItem:item];
}

@end

