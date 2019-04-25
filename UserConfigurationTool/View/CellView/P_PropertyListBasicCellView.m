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

- (void)p_setControlWithString:(NSString *)str
{
    self.textField.stringValue = str;
    self.toolTip = str;
}

- (void)p_setControlEditable:(BOOL)editable
{
    self.textField.selectable = self.textField.editable = editable;
    
    NSColor* controlColor = editable ? NSColor.labelColor : NSColor.disabledControlTextColor;
    
    self.textField.textColor = controlColor;
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
