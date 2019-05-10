//
//  P_PropertyListRowView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListRowView.h"
#import "P_PropertyList2ButtonCellView.h"
#import "P_PropertyListPopUpButtonCellView.h"

#import "P_Data+P_Exten.h"

@interface P_PropertyListRowView ()
{
    BOOL _mouseIn;
    NSTrackingArea* _trackingArea;
}

@end

@implementation P_PropertyListRowView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.wantsLayer = YES;
    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    self.canDrawSubviewsIntoLayer = YES;
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = NSColor.clearColor.CGColor;
}

- (void)ensureTrackingArea
{
    if (_trackingArea == nil)
    {
        _trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    }
}

- (void)setP:(P_Data *)p
{
    _p = p;
    [self p_updateEditButtons];
    
    [self p_updatePopUpButtons];
}

#pragma mark - overwrite

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    [self ensureTrackingArea];
    
    if ([[self trackingAreas] containsObject:_trackingArea] == NO)
    {
        [self addTrackingArea:_trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)event
{
    [super mouseEntered:event];
    _mouseIn = YES;
    
    [self p_updateEditButtons];
}

- (void)mouseExited:(NSEvent *)event
{
    [super mouseExited:event];
    _mouseIn = NO;
    
    [self p_updateEditButtons];
}

- (void)setEmphasized:(BOOL)emphasized
{
    /** 禁止已选中时，被取消标志 */
    if (self.isSelected && emphasized == NO) {
        return;
    }
    [super setEmphasized:emphasized];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [self setEmphasized:YES];
    }
    [self p_updateEditButtons];
    
    [self p_updatePopUpButtons];
}

#pragma mark - public
- (void)p_updatePopUpButtons
{
    if (self.numberOfColumns > 1) {
        NSTableCellView *cellView = [self viewAtColumn:1];
        if ([cellView isKindOfClass:[P_PropertyListPopUpButtonCellView class]]) {
            [(P_PropertyListPopUpButtonCellView *)cellView p_setShowsControlButtons:self.selected];
        }
    }
}

- (void)p_updateEditButtons
{
    if(self.numberOfColumns > 0)
    {
        
        NSTableCellView *cellView = [self viewAtColumn:0];
        if ([cellView isKindOfClass:[P_PropertyList2ButtonCellView class]]) {
            
            BOOL addButtonEnabled = self.p.operation & P_Data_Operation_Insert;
            BOOL deleteButtonEnabled = self.p.operation & P_Data_Operation_Delete;
            
            [(P_PropertyList2ButtonCellView *)cellView p_setShowsControlButtons:self.selected || _mouseIn addButtonEnabled:addButtonEnabled deleteButtonEnabled:deleteButtonEnabled];
        }
    }
}

//直接改变点击背景色的方法
- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {

        NSRect selectionRect = NSInsetRect(self.bounds, 1, 1);

        [[NSColor systemBlueColor] setStroke];  //设置边框颜色
        [[NSColor systemBlueColor] setFill];  //设置填充背景颜色

        NSBezierPath *path = [NSBezierPath bezierPathWithRect:selectionRect];
        [path fill];
        [path stroke];
    }
}

@end
