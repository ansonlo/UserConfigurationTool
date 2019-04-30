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
    NSLog(@"config:%@", [self.config.childDatas objectAtIndex:comboBox.indexOfSelectedItem].data);
    NSInteger row = [self.outlineView rowForView:comboBox];
    [self updateObjectWithIndex:row withObject:[self.config completedKey:comboBox.stringValue].data];
}

#pragma mark NSTextFieldDelegate

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    NSComboBox *comboBox = obj.object;
    if (self.config == nil) {
        [comboBox reloadData];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSComboBox *comboBox = obj.object;
    
    NSInteger row = [self.outlineView rowForView:comboBox];
//    P_Data *p = [self.outlineView itemAtRow:row];
    NSLog(@"config:%@", [self.config completedKey:comboBox.stringValue].data);
    [self updateObjectWithIndex:row withObject:[self.config completedKey:comboBox.stringValue].data];
}
@end
