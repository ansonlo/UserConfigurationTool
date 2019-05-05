//
//  P_PropertyListOutlineView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListOutlineView.h"
#import "P_Data.h"

NSPasteboardName const NSPasteboardName_P_Data = @"NSPasteboardName_P_Data";

@interface P_PropertyListOutlineView ()

@property (nonatomic, strong) NSPasteboard *pasteboard;
@property (nonatomic, copy) NSString *pasteboardType;

@end

@implementation P_PropertyListOutlineView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.enclosingScrollView.wantsLayer = YES;
    self.enclosingScrollView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    self.usesAlternatingRowBackgroundColors = YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    [self registerForDraggedTypes:[NSArray arrayWithObject:[NSBundle mainBundle].bundleIdentifier]];
    _pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    _pasteboardType = [NSBundle mainBundle].bundleIdentifier;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUpNotification:) name:NSPopUpButtonWillPopUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comboBoxWillPopUpNotification:) name:NSComboBoxWillPopUpNotification object:nil];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mouseDown:(NSEvent *)event
{
    if (event.clickCount > 1) {
        NSInteger row = self.selectedRow;
        NSInteger column = [self columnAtPoint:event.locationInWindow];
        NSTableCellView *cellView = [self viewAtColumn:column row:row makeIfNecessary:NO];
        if ([cellView.textField acceptsFirstResponder]) {
            [cellView.textField becomeFirstResponder];
        }
    } else {
        [super mouseDown:event];
    }
}


- (void)drawGridInClipRect:(NSRect)clipRect
{
    NSRect lastRowRect = [self rectOfRow:[self numberOfRows] - 1];
    NSRect myClipRect = NSMakeRect(0, 0, lastRowRect.size.width, NSMaxY(lastRowRect));
    NSRect finalClipRect = NSIntersectionRect(clipRect, myClipRect);
    [super drawGridInClipRect:finalClipRect];
}

#pragma mark - NSPopUpButtonWillPopUpNotification
- (void)popUpButtonWillPopUpNotification:(NSNotification *)notify
{
    NSPopUpButton *button = notify.object;
    NSInteger row = [self rowForView:button];
    if (row > -1) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:false];
    }
    
}

#pragma mark - NSMenuItemValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    NSInteger selectRow = [self selectedRow];
    if (selectRow>0) {
        if(menuItem.action == @selector(cut:) && [self respondsToSelector:@selector(cut:)])
        {
            return YES;
        } else if (menuItem.action == @selector(delete:) && [self respondsToSelector:@selector(delete:)]) {
            return YES;
        } else if (menuItem.action == @selector(paste:) && [self respondsToSelector:@selector(paste:)]) {
            return YES;
        } else if (menuItem.action == @selector(copy:) && [self respondsToSelector:@selector(copy:)]) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - NSComboBoxWillPopUpNotification
- (void)comboBoxWillPopUpNotification:(NSNotification *)notify
{
    NSComboBox *box = notify.object;
    NSInteger row = [self rowForView:box];
    if (row > -1) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:false];
    }
}


/** 剪切 */
- (void)cut:(id)sender
{
    NSInteger cutIndex = [self selectedRow];
    P_Data *cutItem = [self itemAtRow:cutIndex];
    P_Data *cutItemParentData = cutItem.parentData;
    [_pasteboard clearContents];
    NSError *error = nil;
    NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:cutItem requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"cut failure %@", error.localizedDescription);
        return;
    }
    [_pasteboard setData:archivedata forType:_pasteboardType];
    [self beginUpdates];
    NSInteger index = [cutItemParentData.childDatas indexOfObject:cutItem];
    [self removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:cutItemParentData withAnimation:NSTableViewAnimationSlideDown];
    [cutItemParentData removeChildDataAtIndex:index];
    [self endUpdates];
}

/** 删除 */
- (void)delete:(id)sender
{
    NSInteger operationIndex = [self selectedRow];
    P_Data *operationItem = [self itemAtRow:operationIndex];
    P_Data *operationParentData = operationItem.parentData;
    [self beginUpdates];
    NSInteger atParentDataIndex = [operationParentData.childDatas indexOfObject:operationItem];
    [self removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:atParentDataIndex] inParent:operationParentData withAnimation:NSTableViewAnimationEffectNone];
    [operationParentData removeChildDataAtIndex:atParentDataIndex];
    [self endUpdates];
}

- (void)paste:(id)sender
{
    if ([_pasteboard canReadItemWithDataConformingToTypes:@[_pasteboardType]]) {
        NSInteger selectIndex = [self selectedRow];
        if (selectIndex > 0) {
            P_Data *selectP = [self itemAtRow:selectIndex];
            P_Data *selectParentData = selectP.parentData;
            
            NSData *archivedata = [_pasteboard dataForType:_pasteboardType];
            NSError *error = nil;
            P_Data *p = [NSKeyedUnarchiver unarchivedObjectOfClass:[P_Data class] fromData:archivedata error:&error];
            if (error) {
                NSLog(@"paste failure %@", error.localizedDescription);
                return;
            }
            if ([selectP.type isEqualToString:@"Dictionary"]) {
                NSLog(@"%@", selectP);
            } else if ([selectP.type isEqualToString:@"Array"]) {
                NSLog(@"%@", selectP);
            }
            
        } else {
            
        }
    }
}

/** 拷贝 */
- (void)copy:(id)sender
{
    NSPasteboard *_pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardName_P_Data];
    [_pasteboard clearContents];
    
    NSInteger operationIndex = [self selectedRow];
    P_Data *operationItem = [self itemAtRow:operationIndex];
    NSError *error = nil;
    NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:operationItem requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"copy failure %@", error.localizedDescription);
        return;
    }
    [_pasteboard setData:archivedata forType:_pasteboardType];
}


@end
