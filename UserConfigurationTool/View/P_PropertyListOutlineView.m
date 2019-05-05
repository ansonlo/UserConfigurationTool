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
    NSInteger index = [cutItemParentData.childDatas indexOfObject:cutItem];
    [cutItemParentData removeChildDataAtIndex:index];
    if (cutItemParentData.parentData) {
        [self reloadItem:cutItemParentData.parentData reloadChildren:YES];
    } else {
        [self reloadItem:cutItemParentData reloadChildren:YES];
    }
}

/** 删除 */
- (void)delete:(id)sender
{
    NSInteger operationIndex = [self selectedRow];
    P_Data *operationItem = [self itemAtRow:operationIndex];
    P_Data *operationParentData = operationItem.parentData;
    [operationParentData removeChildDataAtIndex:[operationParentData.childDatas indexOfObject:operationItem]];
    if (operationParentData.parentData) {
        [self reloadItem:operationParentData.parentData reloadChildren:YES];
    } else {
        [self reloadItem:operationParentData reloadChildren:YES];
    }
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
            NSSet *set = [NSSet setWithArray:@[[P_Data class], [NSDictionary class], [NSArray class], [NSDate class]]];
            P_Data *p = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:archivedata error:&error];
            if (error) {
                NSLog(@"paste failure %@", error.localizedDescription);
                return;
            }
            
            NSString *(^_getKey)(P_Data *aData, NSString *key) = ^(P_Data *aData, NSString *key){
                NSInteger i = 2;
                NSString *str = key;
                while (i>0) {
                    if (![selectP.type isEqualToString:@"Array"]) {
                        if ([aData containsChildrenWithKey:str]) {
                            /** 存在相同的key，需要自增1 */
                            str = [key stringByAppendingString:[NSString stringWithFormat:@" - %ld", (long)i]];
                        } else {
                            i = -1;
                        }
                        i ++;
                    } else {
                        i = -1;
                    }
                }
                return str;
            };
            /** 是否展开子菜单 */
            if ([self isItemExpanded:selectP]) {
                if ([selectP.type isEqualToString:@"Dictionary"]) {
                    p.key = _getKey([selectP childDatas].firstObject, p.key);
                    [selectP insertChildData:p atIndex:[selectP childDatas].count];
                } else if ([selectP.type isEqualToString:@"Array"]) {
                    [selectP insertChildData:p atIndex:[[selectP childDatas] count]];
                    for (NSInteger i = 0; i < selectP.childDatas.count; i ++) {
                        P_Data *obj = [selectP.childDatas objectAtIndex:i];
                        obj.key = [NSString stringWithFormat:@"Item %ld", (long)i];
                    }
                }
            } else {
                if ([selectParentData.type isEqualToString:@"Array"]) {
                    [selectParentData insertChildData:p atIndex:[[selectParentData childDatas] indexOfObject:selectP]];
                    for (NSInteger i = 0; i < selectParentData.childDatas.count; i ++) {
                        P_Data *obj = [selectParentData.childDatas objectAtIndex:i];
                        obj.key = [NSString stringWithFormat:@"Item %ld", (long)i];
                    }
                } else {
                    p.key = _getKey(selectP, p.key);
                    if (selectParentData.level > 0) {
                        [selectParentData insertChildData:p atIndex:selectParentData.childDatas.count];
                    } else {
                        [selectParentData insertChildData:p atIndex:selectIndex];
                    }
                }
            }
            if (selectParentData.parentData) {
                [self reloadItem:selectParentData.parentData reloadChildren:YES];
            } else {
                [self reloadItem:selectParentData reloadChildren:YES];
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
