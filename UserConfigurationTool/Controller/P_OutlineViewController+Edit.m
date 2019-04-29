//
//  P_OutlineViewController+Edit.m
//  UserConfigurationTool
//
//  Created by 丁嘉睿 on 2019/4/28.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OutlineViewController+Edit.h"


@interface P_OutlineViewController ()

@property (nonatomic, strong) NSString *pbTypeString;

@end

@implementation P_OutlineViewController (Edit)

-(void) enableDragNDrop
{
    /** 剪切板类型标记 */
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
    P_Data *cutItemParentData = cutItem.parentData;
    
    NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    [_pasteboard clearContents];
    NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:cutItem];
    NSPasteboardItem *pbitem = [[NSPasteboardItem alloc] init];
    [pbitem setData:archivedata forType:[NSBundle mainBundle].bundleIdentifier];
    [_pasteboard writeObjects:@[pbitem]];
    
    [self.outlineView beginUpdates];
    NSInteger index = [cutItemParentData.childDatas indexOfObject:cutItem];
    [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:cutItemParentData withAnimation:NSTableViewAnimationSlideDown];
    [cutItemParentData removeChildDataAtIndex:index];
    [self.outlineView endUpdates];

}

- (void)deleteEditing
{
    NSInteger operationIndex = [self.outlineView selectedRow];
    P_Data *operationItem = [self.outlineView itemAtRow:operationIndex];
    P_Data *operationParentData = operationItem.parentData;
    [self.outlineView beginUpdates];
    NSInteger atParentDataIndex = [operationParentData.childDatas indexOfObject:operationItem];
    [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:atParentDataIndex] inParent:operationParentData withAnimation:NSTableViewAnimationEffectNone];
    [operationParentData removeChildDataAtIndex:atParentDataIndex];
    [self.outlineView endUpdates];
}

- (void)pasteEditing
{
    NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    NSPasteboardItem *pbItem = [_pasteboard.pasteboardItems firstObject];
    if (pbItem) {
        NSInteger operationIndex = [self.outlineView selectedRow];
        NSData *data = [pbItem dataForType:[NSBundle mainBundle].bundleIdentifier];
        P_Data *pasteItem = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"%@", pasteItem);
    }
}

- (BOOL)copyEditing
{
    NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    [_pasteboard clearContents];

    NSInteger operationIndex = [self.outlineView selectedRow];
    P_Data *operationItem = [self.outlineView itemAtRow:operationIndex];
    
    NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:operationItem];
    NSPasteboardItem* pbItem = [[NSPasteboardItem alloc] init];
    [pbItem setData:archivedata forType:[NSBundle mainBundle].bundleIdentifier];
    return [_pasteboard writeObjects:@[pbItem]];
}


@end
