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

#import "NSView+P_Animation.h"
#import "NSString+P_16Data.h"

#import "P_PropertyListRowView.h"
#import "P_PropertyListBasicCellView.h"

#import "P_PropertyList2ButtonCellView.h"
#import "P_PropertyListPopUpButtonCellView.h"
#import "P_PropertyListDatePickerCellView.h"

@interface P_OutlineViewController () <P_PropertyListCellViewDelegate>
{
    NSUndoManager* _undoManager;
}

@property (nonatomic, strong) P_Data *root;


@end

@implementation P_OutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _undoManager = [NSUndoManager new];

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - overwrite
- (void)__loadPlistData:(NSURL *)plistUrl
{
    P_Data *p = [P_Data rootWithPlistUrl:plistUrl];
    if (p) {
        _root = p;
        
        [self.outlineView setIndentationMarkerFollowsCell:YES];
//        [self.outlineView setIgnoresMultiClick:YES];
        [self.outlineView reloadData];
        //设置子项的展开
        [self.outlineView expandItem:_root expandChildren:NO];
    }
}

- (void)__savePlistData:(NSURL *)plistUrl
{
    P_Data *root = self.root;
    
    NSData *data = root.data;
    
    BOOL success = [data writeToURL:plistUrl atomically:YES];
    
    if (success) {
        [self p_showAlertViewWith:NSLocalizedString(@"save plist success!", @"")];
    } else {
        [self p_showAlertViewWith:NSLocalizedString(@"save plist fail!", @"")];
    }
}

// The NSOutlineView uses 'nil' to indicate the root item. We return our root tree node for that case.
- (NSArray *)childrenForItem:(id)item {
    if (item == nil) {
        if (_root) {
            return @[_root];
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
    
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:PlistColumnIdentifier.Key])
    {
        cellIdentifier = PlistCell.KeyCell;
        editable = (p.editable & P_Data_Editable_Key) && ![p.parentData.type isEqualToString: Plist.Array];
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
    [self outlineView:outlineView willDisplayCell:cellView forTableColumn:tableColumn item:item];
    [cellView p_setControlEditable:editable];
    
    return cellView;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(P_PropertyListBasicCellView *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    P_Data *p = item;
    // For all the other columns, we don't do anything.
    
    NSString *identifier =[tableColumn identifier];
    if ([identifier isEqualToString:PlistColumnIdentifier.Key])
    {
        [cell p_setControlWithString:p.key toolTip:p.keyDesc];
    }
    else if ([identifier isEqualToString:PlistColumnIdentifier.Type])
    {
        [(P_PropertyListPopUpButtonCellView *)cell p_setControlWithString:p.type];
    }
    else if ([identifier isEqualToString:PlistColumnIdentifier.Value])
    {
        if ([p.type isEqualToString: Plist.Boolean]) {
            [(P_PropertyListPopUpButtonCellView *)cell p_setControlWithBoolean:[p.value boolValue]];
        } else if ([p.type isEqualToString: Plist.Date]) {
            [(P_PropertyListDatePickerCellView *)cell p_setControlWithDate:p.value];
        } else {
            [cell p_setControlWithString:p.valueDesc];
        }
    }
}

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors;
{
    //Make the outline view as the first responder to prevent issues with currently edited text fields.
    [outlineView.window makeFirstResponder:outlineView];
    
    /** 记录之前选中的对象 */
    id item = [outlineView itemAtRow:outlineView.selectedRow];
    
    /** 排序&刷新 */
    [_root sortWithSortDescriptors:outlineView.sortDescriptors recursively:YES];
    [self.outlineView reloadItem:nil reloadChildren:YES];
    
    /** 重置选中对象的视图 */
    NSInteger selectionRow = [outlineView rowForItem:item];
    [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionRow] byExtendingSelection:NO];
    [outlineView scrollRowToVisible:selectionRow];
}

//阶段二之支持拖拽
- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item{
    if ([item isKindOfClass:[P_Data class]]){
        P_Data *a_P_Data = (P_Data *)item;
        if (a_P_Data.operation == P_Data_Operation_Move) {
        }
        NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:item];
        NSPasteboardItem* pbItem = [[NSPasteboardItem alloc] init];
        [pbItem setData:archivedata forType:[NSBundle mainBundle].bundleIdentifier];
        return pbItem;
    }
    return nil;
}


//阶段二之判断是否为有效拖拽
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index{
    NSLog(@"validateDrop:%@", NSStringFromPoint(info.draggingLocation));
    NSDragOperation sourceDragMask = [info draggingSourceOperationMask];
    NSPasteboard *pasteboard = info.draggingPasteboard;
    if ([[pasteboard types] containsObject:[NSBundle mainBundle].bundleIdentifier]) {
        if (sourceDragMask & NSDragOperationMove) {
            return NSDragOperationMove;
        }
    }
    return NSDragOperationNone;
}

//阶段二之拖拽调整位置
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index{
    NSLog(@"acceptDrop:%@", NSStringFromPoint(info.draggingLocation));
    NSPasteboard* pb = [info draggingPasteboard];
    [self.outlineView beginUpdates];
    //    [self.outlineView moveItemAtIndex:1 inParent:item toIndex:index inParent:item];
    [self.outlineView endUpdates];
    return YES;
}


#pragma mark - P_PropertyListCellViewDelegate
- (id)p_propertyListCellDidEndEditing:(P_PropertyListBasicCellView *)cellView value:(id)value
{
    NSUInteger row = [self.outlineView rowForView:cellView];
    NSUInteger column = [self.outlineView columnForView:cellView];
    
    id item = [self.outlineView itemAtRow:row];
    P_Data *p = item;
    
    if(column == 0)
    {
        if([item containsChildrenAndWithOutSelfWithKey:value] == NO)
        {
            [self _updateKey:value ofItem:item withView:NO];
        }
        else
        {
            [[self.outlineView viewAtColumn:column row:row makeIfNecessary:NO] p_flashError];
            
            [self p_showAlertViewWith:[NSString stringWithFormat:NSLocalizedString(@"The key “%@” already exists in containing item.", @""), value]];
            
        }
        return p.key;
    }
    else if(column == 1)
    {
        [self _updateType:value value:p.value childDatas:nil ofItem:item];
    }
    else if(column == 2)
    {
#warning 验证NSData的正确性
        if (YES)
        {
            [self _updateValue:value ofItem:item withView:NO];
        } else {
            [[self.outlineView viewAtColumn:column row:row makeIfNecessary:NO] p_flashError];
            // Your entry is not valid.  Do you want to keep editing and fix the error or cancel editing?
        }
        
        return p.valueDesc;
    }
    
    return nil;
}

#pragma mark - 更新值key、type、value

- (void)_updateItem:(id)newItem ofItem:(id)item withView:(BOOL)withView
{
    P_Data *new_p = newItem;
    P_Data *p = item;
    if([p isEqualToP_Data:new_p])
    {
        return;
    }
    
    if (withView) {
        [self.outlineView beginUpdates];
    }
    
    /** willChangeNode */
    P_Data *parentData = p.parentData;
    NSInteger index = [parentData.childDatas indexOfObject:p];
    [parentData removeChildDataAtIndex:index];
    [parentData insertChildData:new_p atIndex:index];
    
    if (withView) {
        [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parentData withAnimation:NSTableViewAnimationEffectNone];
        [self.outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parentData withAnimation:NSTableViewAnimationEffectNone];
        
        [self.outlineView reloadItem:new_p reloadChildren:YES];
        
        [self.outlineView endUpdates];
        
        NSInteger selectionRow = [self.outlineView rowForItem:new_p];
        [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionRow] byExtendingSelection:NO];
        [self.outlineView scrollRowToVisible:selectionRow];
    }

    [_undoManager registerUndoWithTarget:self handler:^(P_OutlineViewController * _Nonnull target) {
        [target _updateItem:item ofItem:newItem withView:YES];
    }];

    /** didChangeNode */
    
    NSLog(@"%@", new_p);
}

- (void)_updateKey:(NSString *)key ofItem:(id)item withView:(BOOL)withView
{
    P_Data *p = item;
    if([p.key isEqualToString:key])
    {
        return;
    }
    /** willChangeNode */
    
    NSString* oldKey = p.key;
    p.key = key;
    
    
    if (withView) {
        NSUInteger row = [self.outlineView rowForItem:item];
        NSUInteger column = 0;
        
        P_PropertyListBasicCellView *cellView = [self.outlineView viewAtColumn:column row:row makeIfNecessary:NO];
        [cellView p_setControlWithString:key];
    }
    
    [_undoManager registerUndoWithTarget:self handler:^(P_OutlineViewController * _Nonnull target) {
        [target _updateKey:oldKey ofItem:item withView:YES];
    }];
    
    /** didChangeNode */
    
    NSLog(@"%@", p);
}

- (void)_updateType:(P_PlistTypeName)type value:(id)value childDatas:(NSArray <P_Data *> *)childDatas ofItem:(id)item
{
    P_Data *p = item;
    if([p.type isEqualToString:type])
    {
        return;
    }
    
    /** willChangeNode */
    
    P_PlistTypeName oldType = p.type;
    id oldValue = p.value;
    NSArray <P_Data *> *oldChildDatas = p.childDatas;
    
    p.type = type;
    p.value = value;
    p.childDatas = childDatas;
    
    [self.outlineView reloadItem:p reloadChildren:YES];
    [self.outlineView scrollRowToVisible:[self.outlineView rowForItem:item]];
    
    [_undoManager registerUndoWithTarget:self handler:^(P_OutlineViewController * _Nonnull target) {
        [target _updateType:oldType value:oldValue childDatas:oldChildDatas ofItem:item];
    }];
    
    /** didChangeNode */
    
    NSLog(@"%@", p);
}

- (void)_updateValue:(id)value ofItem:(id)item withView:(BOOL)withView
{
    P_Data *p = item;
    if (p.value == value) {
        return;
    }
    
    /** willChangeNode */
    
    id oldValue = p.value;
    p.value = value;
    
    
    if(withView)
    {
        NSUInteger row = [self.outlineView rowForItem:item];
        NSUInteger column = 2;
        
        P_PropertyListBasicCellView *cell = [self.outlineView viewAtColumn:column row:row makeIfNecessary:NO];
        
        if ([p.type isEqualToString: Plist.Boolean]) {
            [(P_PropertyListPopUpButtonCellView *)cell p_setControlWithBoolean:[p.value boolValue]];
        } else if ([p.type isEqualToString: Plist.Date]) {
            [(P_PropertyListDatePickerCellView *)cell p_setControlWithDate:p.value];
        } else {
            [cell p_setControlWithString:p.valueDesc];
        }
    }
    
    [_undoManager registerUndoWithTarget:self handler:^(P_OutlineViewController * _Nonnull target) {
        [target _updateValue:oldValue ofItem:item withView:YES];
    }];
    
    /** didChangeNode */
    
    NSLog(@"%@", p);
}

@end

