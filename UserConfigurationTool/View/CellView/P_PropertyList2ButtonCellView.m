//
//  P_PropertyList2ButtonCellView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyList2ButtonCellView.h"
#import "P_Config.h"
#import "P_Data.h"

@interface P_PropertyList2ButtonCellView () <NSComboBoxDataSource, NSComboBoxDelegate>

@property (weak) IBOutlet NSButton *minusButton;
@property (weak) IBOutlet NSButton *plusButton;
@property (weak) IBOutlet NSLayoutConstraint *comboBoxTrailing;

@property (nonatomic, strong) P_Config *config;

@property (nonatomic, assign) BOOL textFieldEditing;
@property (nonatomic, assign) BOOL comboBoxPopUping;
@end

@implementation P_PropertyList2ButtonCellView

@dynamic delegate;

- (void)setDelegate:(id<P_PropertyList2ButtonCellViewDelegate>)delegate
{
    super.delegate = delegate;
}

- (id<P_PropertyList2ButtonCellViewDelegate>)delegate
{
    id curDelegate = super.delegate;
    return curDelegate;
}

- (void)setConfig:(P_Config *)config
{
    _config = config;
    if ([self.textField isKindOfClass:[NSComboBox class]]) {
        [(NSComboBox *)self.textField noteNumberOfItemsChanged];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self p_setShowsControlButtons:NO];
    self.config = nil;
}

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    if ([self.superview isKindOfClass:[NSTableRowView class]]) {
        [self p_setShowsControlButtons:[(NSTableRowView *)self.superview isSelected]];
    }
}

#pragma mark - overwrite
- (NSArray<NSDraggingImageComponent *> *)draggingImageComponents
{
    NSArray<NSDraggingImageComponent *> *s_draggingImageComponents = [super draggingImageComponents];
    NSDraggingImageComponent *imageComponent1 = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentIconKey];
    imageComponent1.contents = self.minusButton.image;
    imageComponent1.frame = self.minusButton.frame;
    
    NSDraggingImageComponent *imageComponent2 = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentIconKey];
    imageComponent2.contents = self.plusButton.image;
    imageComponent2.frame = self.plusButton.frame;
    
    if (s_draggingImageComponents) {
        return [s_draggingImageComponents arrayByAddingObjectsFromArray:@[imageComponent1, imageComponent2]];
    } else {
        return @[imageComponent1, imageComponent2];
    }
}

- (void)p_setControlData:(P_Data *)p
{
    self.textField.stringValue = p.key;
    self.toolTip = p.keyDesc;
}

- (void)p_setControlData:(P_Data *)p config:(P_Config *)c
{
    [self p_setControlData:p];
    self.config = c;
}

- (void)p_setShowsControlButtons:(BOOL)showsControlButtons
{
    self.comboBoxTrailing.constant = showsControlButtons ? self.frame.size.width-self.plusButton.frame.origin.x : 2;
    
    self.plusButton.hidden = self.minusButton.hidden = !showsControlButtons;
}

- (void)p_setShowsControlButtons:(BOOL)showsControlButtons addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled
{
    [self p_setShowsControlButtons:showsControlButtons];
    
    self.plusButton.enabled = addButtonEnabled;
    self.minusButton.enabled = deleteButtonEnabled;
}

#pragma mark - NSComboBoxDataSource
/* These two methods are required when not using bindings */
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
{
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
    /** 已经确定选择后，需要关闭已经输入的标记。否则会调用controlTextDidEndEditing，导致处理2次数据。 */
    self.textFieldEditing = NO;
    NSComboBox *comboBox = notification.object;
    if (comboBox.indexOfSelectedItem > -1) {
        //        NSLog(@"config:%@", [self.config.childDatas objectAtIndex:comboBox.indexOfSelectedItem].data);
        
        [self comboBoxDidEndEditing:comboBox config:[self.config.childDatas objectAtIndex:comboBox.indexOfSelectedItem]];
    }
}

#pragma mark NSTextFieldDelegate

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    self.textFieldEditing = YES;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    if (self.textFieldEditing == NO) {
        return;
    }
    self.textFieldEditing = NO;
    
    NSTextField *textField = obj.object;
    //    NSLog(@"config:%@", [self.config completedKey:comboBox.stringValue].data);
    [self comboBoxDidEndEditing:textField config:[self.config compareKey:textField.stringValue]];
}

- (BOOL)control:(NSControl *)control isValidObject:(nullable id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        if ([self.delegate respondsToSelector:@selector(p_propertyListCell:isValidObject:)]) {
            return [self.delegate p_propertyListCell:self isValidObject:obj];
        }
    }
    return YES;
}


#pragma mark - 处理数据
- (void)comboBoxDidEndEditing:(NSTextField *)textField config:(P_Config *)config
{
    if ([self.delegate respondsToSelector:@selector(p_propertyListCellDidEndEditing:value:)]) {
        P_Data *new_p = config.data;
        if (new_p == nil) {
            /** 创建全新对象，避免需要更新权限问题，直接更新对象 */
            new_p = [[P_Data alloc] init];
            new_p.key = textField.stringValue;
        }
        id realValue = [self.delegate p_propertyListCellDidEndEditing:self value:new_p];
        if ([realValue isKindOfClass:[P_Data class]]) {
            [self p_setControlData:realValue];
        }
    }
}

- (IBAction)p_plusAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(p_propertyList2ButtonCellPlusAction:)]) {
        [self.delegate p_propertyList2ButtonCellPlusAction:self];
    }
}

- (IBAction)p_minusAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(p_propertyList2ButtonCellMinusAction:)]) {
        [self.delegate p_propertyList2ButtonCellMinusAction:self];
    }
}


@end
