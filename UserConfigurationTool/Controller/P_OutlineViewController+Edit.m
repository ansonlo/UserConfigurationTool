//
//  P_OutlineViewController+Edit.m
//  UserConfigurationTool
//
//  Created by 丁嘉睿 on 2019/4/28.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OutlineViewController+Edit.h"


@interface P_OutlineViewController ()


@end

@implementation P_OutlineViewController (Edit)

-(void) enableDragNDrop
{
    /** 注册拖缀时间 */
    [self.outlineView registerForDraggedTypes:[NSArray arrayWithObject:[NSBundle mainBundle].bundleIdentifier]];
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

- (void)cutEditing
{
    NSInteger cutIndex = [self.outlineView selectedRow];
    P_Data *cutItem = [self.outlineView itemAtRow:cutIndex];
    
    NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    [_pasteboard clearContents];
    NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:cutItem];
    NSPasteboardItem *pbitem = [[NSPasteboardItem alloc] init];
    [pbitem setData:archivedata forType:[NSBundle mainBundle].bundleIdentifier];
    [_pasteboard writeObjects:@[pbitem]];
    
    [self.outlineView beginUpdates];
    [cutItem.parentData removeChildDataAtIndex:cutIndex-1];
    [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:cutIndex-1] inParent:cutItem.parentData withAnimation:NSTableViewAnimationSlideDown];
    [self.outlineView endUpdates];

}

- (void)deleteEditing
{
    NSInteger operationIndex = [self.outlineView selectedRow];
    P_Data *operationItem = [self.outlineView itemAtRow:operationIndex];
    if (operationItem.operation & P_Data_Operation_Delete) {
        [self.outlineView beginUpdates];
        NSInteger atParentDataIndex = [operationItem.childDatas indexOfObject:operationItem];
        [operationItem.parentData removeChildDataAtIndex:atParentDataIndex];
        [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:atParentDataIndex] inParent:operationItem.parentData withAnimation:NSTableViewAnimationEffectNone];
        [self.outlineView endUpdates];
    }
}

- (BOOL)copyEditing
{
    NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    [_pasteboard clearContents];
    NSInteger copyIndex = [self.outlineView selectedRow];
    P_Data *copyItem = [self.outlineView itemAtRow:copyIndex];
    NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:copyItem];
    NSPasteboardItem* pbItem = [[NSPasteboardItem alloc] init];
    [pbItem setData:archivedata forType:[NSBundle mainBundle].bundleIdentifier];
    return [_pasteboard writeObjects:@[pbItem]];
}


@end
