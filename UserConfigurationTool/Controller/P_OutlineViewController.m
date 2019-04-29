//
//  P_OutlineViewController.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OutlineViewController.h"
#import "P_TypeHeader.h"

#import "NSView+P_Animation.h"
#import "NSString+P_16Data.h"

#import "P_PropertyListRowView.h"
#import "P_PropertyListBasicCellView.h"

#import "P_PropertyList2ButtonCellView.h"
#import "P_PropertyListPopUpButtonCellView.h"
#import "P_PropertyListDatePickerCellView.h"

NSPasteboardName const NSPasteboardName_P_Data = @"NSPasteboardName_P_Data";
NSPasteboardType const NSPasteboardTypeP_Data = @"NSPasteboardTypeP_Data";

@interface P_OutlineViewController () <P_PropertyListCellViewDelegate, P_PropertyListOutlineView_MenuOperationDelegate>
{
    NSUndoManager* _undoManager;
}

@property (nonatomic, strong) NSArray *designatedList;

@end

@implementation P_OutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.outlineView.menuOperationDelegate = self;

    _undoManager = [NSUndoManager new];
    
    NSURL *configDescriptionListURL = [[NSBundle mainBundle] URLForResource:@"ConfigDescription" withExtension:@"plist"];
    NSData *data = [NSData dataWithContentsOfURL:configDescriptionListURL];
    NSDictionary *configPlist = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];
    NSURL *configDefaultListURL = [[NSBundle mainBundle] URLForResource:@"DefaultConfig" withExtension:@"plist"];
    data = [NSData dataWithContentsOfURL:configDefaultListURL];
    NSDictionary *defaultPlist = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];
    
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
        [cell p_setControlWithString:p.key];
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

#pragma mark - P_PropertyListCellViewDelegate
- (id)p_propertyListCellDidEndEditing:(P_PropertyListBasicCellView *)cellView value:(id)value
{
    NSUInteger row = [self.outlineView rowForView:cellView];
    NSUInteger column = [self.outlineView columnForView:cellView];
    
    id item = [self.outlineView itemAtRow:row];
    P_Data *p = item;
    
    if(column == 0)
    {
        if([item containsChildrenWithKey:value] == NO)
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
        NSError *err;
        id p_value = [self _verifyValue:p.value ofType:value error:&err];
        if (err == nil) {
            [self _updateType:value value:p_value childDatas:nil ofItem:item];
        }
    }
    else if(column == 2)
    {
        id new_value = [self _fixedValue:value ofType:p.type];
        if (new_value)
        {
            [self _updateValue:new_value ofItem:item withView:NO];
        } else {
            [[self.outlineView viewAtColumn:column row:row makeIfNecessary:NO] p_flashError];
            // Your entry is not valid.  Do you want to keep editing and fix the error or cancel editing?
        }
        
        return p.valueDesc;
    }
    
    return nil;
}

#pragma mark - private
- (id)_verifyValue:(id)value ofType:(P_PlistTypeName)type error:(NSError **)error
{
    id n_value = nil;
    if ([type isEqualToString: Plist.Dictionary]) {
        n_value = @{};
    } else if ([type isEqualToString: Plist.Array]) {
        n_value = @[];
    } else if ([type isEqualToString: Plist.String]) {
        n_value = [value description];
    } else if ([type isEqualToString: Plist.Number]) {
        // 准备对象
        NSString * searchStr = [value description];
        // 创建 NSRegularExpression 对象,匹配 正则表达式
        NSString * regExpStr = @"^[0-9]*";
        NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:regExpStr
                                                        options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:nil];
        NSRange range = [regExp rangeOfFirstMatchInString:searchStr options:NSMatchingAnchored range:NSMakeRange(0, searchStr.length)];
        NSString *result_string = [searchStr substringWithRange:range];
        if (result_string.length == 0) {
            n_value = @0;
        } else {
            n_value = result_string;
        }
    } else if ([type isEqualToString: Plist.Boolean]) {
        n_value = @([[value description] boolValue]);
    } else if ([type isEqualToString: Plist.Date]) {
        n_value = [NSDate date];
    } else if ([type isEqualToString: Plist.Data]) {
        n_value = [NSData data];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:@"ValueError" code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"不匹配这种类型:%@", type]}];
        }
        NSLog(@"不匹配这种类型:%@", type);
    }
    return n_value;
}

- (id)_fixedValue:(id)value ofType:(P_PlistTypeName)type
{
    if ([type isEqualToString: Plist.Number]) {
        return [self _verifyValue:value ofType:type error:nil];
    } else if ([type isEqualToString: Plist.Data]) {
#warning Data类型暂时禁止修改。未参透功能。
        return nil;
    }  else if ([type isEqualToString: Plist.Date]) {
        if (![value isKindOfClass:[NSDate class]]) {
            return nil;
        }
    }
    return value;
}

#pragma mark - 更新值key、type、value

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

//阶段二之支持拖拽
- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item{
    if ([item isKindOfClass:[P_Data class]]){
        NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:item];
        NSPasteboardItem* pbItem = [[NSPasteboardItem alloc] init];
        [pbItem setData:archivedata forType:NSPasteboardTypeP_Data];
        return pbItem;
    }
    return nil;
}

//阶段二之判断是否为有效拖拽
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index{
    bool canDrag = index>=0 && item!=nil;
    if (!canDrag){
        return NSDragOperationNone;
    }
    return NSDragOperationMove;
}

//阶段二之拖拽调整位置
//- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index{
//
//    NSPasteboard* pb = [info draggingPasteboard];
//    NSString *name = [pb stringForType:NSPasteboardTypeString];
//    NSTreeNode *sourceNode = nil;
//
//    if([(NSTreeNode*)item childNodes] != nil){
//        for(id node in [item childNodes]){
//            Playlist * playlist = [node representedObject];
//            if([playlist isKindOfClass:[Playlist class]]){
//                if([playlist.name isEqualToString:name]){
//                    sourceNode = node;
//                }
//            }
//        }
//    }
//    if(sourceNode == nil){
//        return NO;
//    }
//
//    NSUInteger indexs[] ={0,index};
//    NSIndexPath* toIndexPath = [[NSIndexPath alloc] initWithIndexes:indexs length:2];
//    [_treeController moveNode:sourceNode toIndexPath:toIndexPath];
//
//    return YES;
//}

#pragma mark - P_PropertyListOutlineView_MenuOperationDelegate
- (void)menuOperationForCut
{
    NSInteger cutIndex = [self.outlineView selectedRow];
    if (cutIndex > 0) {
        P_Data *cutData = [self.outlineView itemAtRow:cutIndex];
        NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
        [_pasteboard clearContents];
        NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:cutData];
//        NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
//        [item setData:archivedata forType:NSPasteboardTypeP_Data];
        [_pasteboard setData:archivedata forType:NSPasteboardTypeP_Data];
        [self.outlineView beginUpdates];
        [self.root removeChildDataAtIndex:cutIndex-1];
        [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:cutIndex-1] inParent:self.root withAnimation:(NSTableViewAnimationSlideDown)];
        [self.outlineView endUpdates];
        
    }
}

- (void)menuOperationForDelete
{
//    NSInteger cutIndex = [self.outlineView selectedRow];
//    P_Data *cutData = [self.outlineView itemAtRow:cutIndex];
//    if (cutData.operation == P_Data_Operation_Delete) {
//        [self.root removeChildDataAtIndex:cutIndex-1];
//        [self.outlineView reloadData];
//    }
}

- (void)menuOperationForCopy
{
    NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    for (NSPasteboardItem *pasteboardItem in _pasteboard.pasteboardItems) {
        NSLog(@"pasteboardItem:%@", pasteboardItem);
    }
}
@end

