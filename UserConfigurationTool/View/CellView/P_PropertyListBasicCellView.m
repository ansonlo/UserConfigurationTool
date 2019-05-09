//
//  P_PropertyListBasicCellView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/24.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListBasicCellView.h"

@interface P_PropertyListBasicCellView () <NSTextFieldDelegate>

@end

@implementation P_PropertyListBasicCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //点击的时候不显示蓝色外框
    self.textField.focusRingType = NSFocusRingTypeNone;
    //自动换行
    [[self.textField cell] setLineBreakMode:NSLineBreakByCharWrapping];
    //最大行数
    self.textField.maximumNumberOfLines = 1;
    //设置是否启用单行模式
    [self.textField cell].usesSingleLineMode = NO;
    //设置超出行数是否隐藏
//    [self.textField cell].truncatesLastVisibleLine = YES;
    self.textField.focusRingType = NSFocusRingTypeDefault;
}

#pragma mark - overwrite
- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    /** 禁止系统自动改变文字颜色 */
}

- (NSArray<NSDraggingImageComponent *> *)draggingImageComponents
{
    NSArray<NSDraggingImageComponent *> *s_draggingImageComponents = [super draggingImageComponents];
    NSDraggingImageComponent *imageComponent = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentLabelKey];
    imageComponent.contents = self.textField.stringValue;
    imageComponent.frame = self.textField.frame;
    
    if (s_draggingImageComponents) {
        return [s_draggingImageComponents arrayByAddingObjectsFromArray:@[imageComponent]];
    } else {
        return @[imageComponent];
    }
}

- (void)p_setControlWithString:(NSString *)str
{
    self.textField.stringValue = str;
    self.toolTip = str;
}

- (void)p_setControlWithString:(NSString *)str toolTip:(NSString *)toolTip
{
    self.textField.stringValue = str;
    self.toolTip = toolTip;
}

- (void)p_setControlEditable:(BOOL)editable
{
    self.textField.selectable = self.textField.editable = editable;
    
    NSColor* controlColor = editable ? NSColor.labelColor : NSColor.disabledControlTextColor;
    
    self.textField.textColor = controlColor;
}

- (void)p_setControlEditableWithOutTextColor:(BOOL)editable
{
    self.textField.selectable = self.textField.editable = editable;
    
}

#pragma mark NSTextFieldDelegate

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField *textField = obj.object;
    if ([self.delegate respondsToSelector:@selector(p_propertyListCellDidEndEditing:value:)]) {
        id realValue = [self.delegate p_propertyListCellDidEndEditing:self value:textField.stringValue];
        if ([realValue isKindOfClass:[NSString class]]) {
            [self p_setControlWithString:realValue];
        }
    }
}

@end
