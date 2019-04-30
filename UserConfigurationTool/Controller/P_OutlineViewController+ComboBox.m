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

@interface P_OutlineViewController () <NSComboBoxDataSource, NSComboBoxDelegate>

@property (nonatomic, strong) P_Config *root_config;

@property (nonatomic, strong) P_Config *config;

@end

@implementation P_OutlineViewController (ComboBox)

- (void)setRoot_config:(P_Config *)root_config
{
    objc_setAssociatedObject([self class], &P_OutlineView_root_configKey, root_config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (P_Config *)root_config
{
    return objc_getAssociatedObject([self class], &P_OutlineView_root_configKey);
}

- (void)setConfig:(P_Config *)config
{
    objc_setAssociatedObject([self class], &P_OutlineView_configKey, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (P_Config *)config
{
    return objc_getAssociatedObject([self class], &P_OutlineView_configKey);
}

#pragma mark - NSComboBoxDataSource
/* These two methods are required when not using bindings */
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.root_config = [P_Config config];
    });
    NSInteger row = [self.outlineView rowForView:comboBox];
    P_Data *p = [self.outlineView itemAtRow:row];
    
    self.config = [self.root_config configAtKey: p.parentData.key];
    
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
    NSComboBox *comboBox = notification.object;
    [comboBox abortEditing];
}

- (void)comboBoxWillDismiss:(NSNotification *)notification
{
    NSComboBox *comboBox = notification.object;
    [comboBox abortEditing];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *comboBox = notification.object;
    if (comboBox.indexOfSelectedItem > -1) {
        
        NSLog(@"config:%@", [self.config.childDatas objectAtIndex:comboBox.indexOfSelectedItem].data);
        
        [self comboBoxDidEndEditing:comboBox config:[self.config.childDatas objectAtIndex:comboBox.indexOfSelectedItem]];
    }
}

#pragma mark NSTextFieldDelegate

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    NSComboBox *comboBox = obj.object;
    if (self.config == nil || comboBox.numberOfItems == 0) {
        [comboBox noteNumberOfItemsChanged];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSComboBox *comboBox = obj.object;
    NSLog(@"config:%@", [self.config completedKey:comboBox.stringValue].data);
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
        new_p = [[P_Data alloc] init];
        new_p.key = comboBox.stringValue;
        new_p.type = p.type;
    }
    NSString *key = new_p.key;
    
    if([p containsChildrenAndWithOutSelfWithKey:key] == NO)
    {
        [self _updateItem:new_p ofItem:p withView:YES];
    }
    else
    {
        [[self.outlineView viewAtColumn:column row:row makeIfNecessary:NO] p_flashError];
        
        [self p_showAlertViewWith:[NSString stringWithFormat:NSLocalizedString(@"The key “%@” already exists in containing item.", @""), key]];
        if (comboBox.indexOfSelectedItem > -1) {
            [comboBox deselectItemAtIndex:comboBox.indexOfSelectedItem];
        }
        comboBox.stringValue = p.key;
    }
    
}

@end
