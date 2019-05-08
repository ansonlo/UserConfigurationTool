//
//  P_OutlineViewController+ComboBox.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/29.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OutlineViewController+ComboBox.h"
#import "P_PropertyList2ButtonCellView.h"
#import "P_Data.h"
#import "P_Config.h"

#import "NSView+P_Animation.h"

#import <objc/runtime.h>

static NSString *P_OutlineView_root_configKey;
static NSString *P_OutlineView_configKey;
static NSString *P_OutlineView_textFieldEditing;
static NSString *P_OutlineView_comboBoxPopUping;

@interface P_OutlineViewController () <NSComboBoxDataSource, NSComboBoxDelegate>

@property (nonatomic, strong) P_Config *config;

@property (nonatomic, assign) BOOL textFieldEditing;
@property (nonatomic, assign) BOOL comboBoxPopUping;

@end

@implementation P_OutlineViewController (ComboBox)

- (void)setConfig:(P_Config *)config
{
    objc_setAssociatedObject([self class], &P_OutlineView_configKey, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (P_Config *)config
{
    return objc_getAssociatedObject([self class], &P_OutlineView_configKey);
}

- (void)setTextFieldEditing:(BOOL)textFieldEditing
{
    objc_setAssociatedObject([self class], &P_OutlineView_textFieldEditing, @(textFieldEditing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)textFieldEditing
{
    return [objc_getAssociatedObject([self class], &P_OutlineView_textFieldEditing) boolValue];
}

- (void)setComboBoxPopUping:(BOOL)comboBoxPopUping
{
    objc_setAssociatedObject([self class], &P_OutlineView_comboBoxPopUping, @(comboBoxPopUping), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)comboBoxPopUping
{
    return [objc_getAssociatedObject([self class], &P_OutlineView_comboBoxPopUping) boolValue];
}

#pragma mark - NSComboBoxDataSource
/* These two methods are required when not using bindings */
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
{
    NSInteger row = [self.outlineView rowForView:comboBox];
    P_Data *p = [self.outlineView itemAtRow:row];
    
    self.config = [[P_Config config] configAtKey: p.parentData.key];
    
    return self.config.childDatas.count;
}
- (nullable id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index
{
    P_Config *c = [self.config.childDatas objectAtIndex:index];
    return c.key;
}

#pragma mark - NSComboBoxDelegate
- (void)comboBoxWillPopUp:(NSNotification *)notification
{
    self.comboBoxPopUping = YES;
    NSComboBox *comboBox = notification.object;
    [comboBox.window endEditingFor:comboBox];
}

- (void)comboBoxWillDismiss:(NSNotification *)notification
{
    self.comboBoxPopUping = NO;
    NSComboBox *comboBox = notification.object;
    [comboBox.window endEditingFor:comboBox];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *comboBox = notification.object;
    /** 已经确定选择后，需要关闭已经输入的标记。否则会调用controlTextDidEndEditing，导致处理2次数据。 */
    self.textFieldEditing = NO;
    if (comboBox.indexOfSelectedItem > -1) {
//        NSLog(@"config:%@", [self.config.childDatas objectAtIndex:comboBox.indexOfSelectedItem].data);
        
        [self comboBoxDidEndEditing:comboBox config:[self.config.childDatas objectAtIndex:comboBox.indexOfSelectedItem]];
    }
    [comboBox.window endEditingFor:comboBox];
}

#pragma mark NSTextFieldDelegate

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    self.textFieldEditing = YES;
    if (!self.comboBoxPopUping) {
        NSComboBox *comboBox = obj.object;
        [comboBox noteNumberOfItemsChanged];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSComboBox *comboBox = obj.object;

    if (self.textFieldEditing == NO) {
        return;
    }
    self.textFieldEditing = NO;

//    NSLog(@"config:%@", [self.config completedKey:comboBox.stringValue].data);
    [self comboBoxDidEndEditing:comboBox config:[self.config completedKey:comboBox.stringValue]];
}

#pragma mark - 处理数据
- (void)comboBoxDidEndEditing:(NSComboBox *)comboBox config:(P_Config *)config
{
    
    NSInteger row = [self.outlineView rowForView:comboBox];
    NSUInteger column = [self.outlineView columnForView:comboBox];
    
    P_Data *p = [self.outlineView itemAtRow:row];
    P_Data *new_p = config.data;
    
    if (new_p == nil) {
        /** 创建全新对象，避免需要更新权限问题，直接更新对象 */
        new_p = [[P_Data alloc] init];
        new_p.key = comboBox.stringValue;
        new_p.type = p.type;
        new_p.value = p.value;
        new_p.childDatas = p.childDatas;
    }
    
    if (new_p.key.length == 0) {
        /** key不能为空 */
        [[self.outlineView viewAtColumn:column row:row makeIfNecessary:NO] p_flashError];
        
        [self p_showAlertViewWith:NSLocalizedString(@"The key can not be empty.", @"")];
        
        comboBox.stringValue = p.key;
        
        return;
    }
    
    if([p containsChildrenAndWithOutSelfWithKey:new_p.key] == NO)
    {
        [self.outlineView updateItem:new_p ofItem:p];
        
        if (new_p.requested) {
            /** value不能为空 */
            NSTableRowView *rowView = [self.outlineView rowViewAtRow:row makeIfNecessary:NO];
            NSTableCellView *cellView = [rowView viewAtColumn:rowView.numberOfColumns-1];
            /** controlTextDidEndEditing后不能立即触发其他控件的激活，无奈之下只能延迟0.2s */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [cellView.textField becomeFirstResponder];
            });
        }
    }
    else
    {
        [[self.outlineView viewAtColumn:column row:row makeIfNecessary:NO] p_flashError];
        
        [self p_showAlertViewWith:[NSString stringWithFormat:NSLocalizedString(@"The key “%@” already exists in containing item.", @""), new_p.key]];
        if (comboBox.indexOfSelectedItem > -1) {
            [comboBox deselectItemAtIndex:comboBox.indexOfSelectedItem];
        }
        comboBox.stringValue = p.key;
    }
    
}

@end
