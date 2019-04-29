//
//  P_PropertyListOutlineView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListOutlineView.h"

@interface P_PropertyListOutlineView ()

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUpNotification:) name:NSPopUpButtonWillPopUpNotification object:nil];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUpNotification:) name:NSPopUpButtonWillPopUpNotification object:nil];
    }
    return self;
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
    return NO;
}


- (void)cut:(id)sender
{
    if ([self.menuOperationDelegate respondsToSelector:@selector(menuOperationForCut)]) {
        [self.menuOperationDelegate menuOperationForCut];
    }
}

- (void)delete:(id)sender
{
    if ([self.menuOperationDelegate respondsToSelector:@selector(menuOperationForDelete)]) {
        [self.menuOperationDelegate menuOperationForDelete];
    }
}

- (void)paste:(id)sender
{
    if ([self.menuOperationDelegate respondsToSelector:@selector(menuOperationForPaste)]) {
        [self.menuOperationDelegate menuOperationForPaste];
    }
}

- (void)copy:(id)sender
{
    if ([self.menuOperationDelegate respondsToSelector:@selector(menuOperationForCopy)]) {
        [self.menuOperationDelegate menuOperationForCopy];
    }
}

@end
