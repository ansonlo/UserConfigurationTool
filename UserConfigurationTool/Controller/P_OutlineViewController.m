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

@interface P_OutlineViewController () <P_PropertyList2ButtonCellViewDelegate>
{
    
}

@property (nonatomic, strong) P_Data *root;

@property (nonatomic, strong) NSArray *dragItems;

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

#pragma mark - sort

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

#pragma mark - drag & drop

//阶段二之支持拖拽
- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item{
    if ([item isKindOfClass:[P_Data class]]){
        P_Data *p = (P_Data *)item;
        if (p.operation & P_Data_Operation_Move) {
            NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
            [pbItem setString:[NSString stringWithFormat:@"%ld", self.outlineView.selectedRow] forType:[NSBundle mainBundle].bundleIdentifier];
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
    if (index >= 0) {
        if ([[pasteboard types] containsObject:[NSBundle mainBundle].bundleIdentifier]) {
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
    NSString *selectedRowStr = [pbItem stringForType:[NSBundle mainBundle].bundleIdentifier];
    if (selectedRowStr) {
        NSInteger selectedRow = selectedRowStr.integerValue;
        NSLog(@"%ld", selectedRow);
        P_Data *p = [self.outlineView itemAtRow:selectedRow];
        
        NSLog(@"%p", p );
        
//        [self.outlineView beginUpdates];
//        [self.outlineView moveItemAtIndex:<#(NSInteger)#> inParent:<#(nullable id)#> toIndex:<#(NSInteger)#> inParent:<#(nullable id)#>]
//        [self.outlineView endUpdates];
    }
    return YES;
}

/** 拖缀结束 */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation NS_AVAILABLE_MAC(10_7)
{
    self.dragItems = nil;
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
            [self.outlineView updateKey:value ofItem:item withView:NO];
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
        [self.outlineView updateType:value value:p.value childDatas:nil ofItem:item];
    }
    else if(column == 2)
    {
#warning 验证NSData的正确性
        if (1==1)
        {
            [self.outlineView updateValue:value ofItem:item withView:NO];
        } else {
            [[self.outlineView viewAtColumn:column row:row makeIfNecessary:NO] p_flashError];
            // Your entry is not valid.  Do you want to keep editing and fix the error or cancel editing?
        }
        
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

