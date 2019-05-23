//
//  P_PropertyListToolbarView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/5/10.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListToolbarView.h"

@interface P_PropertyListToolbarView ()

@end


@implementation P_PropertyListToolbarView

@dynamic delegate;

- (void)setDelegate:(id<P_PropertyListToolbarViewDelegate>)delegate
{
    super.delegate = delegate;
}

- (id<P_PropertyListToolbarViewDelegate>)delegate
{
    id curDelegate = super.delegate;
    return curDelegate;
}

//- (void)p_setControlSelected:(BOOL)isSelected addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled
//{
//    self.plusButton.enabled = isSelected && addButtonEnabled;
//    self.minusButton.enabled = isSelected && deleteButtonEnabled;
//}

- (void)callDelegate:(P_PropertyListToolbarButton)type
{
    /** 获取当然window的响应者 */
    NSResponder *firstResponder = self.window.firstResponder;
    if ([firstResponder respondsToSelector:@selector(delegate)]) {
        /** 获取代理对象 */
        id delegateObj = [firstResponder performSelector:@selector(delegate)];
        if ([delegateObj isKindOfClass:[NSTextField class]]) {
            /** 对象是outlineView的成员之一 */
            if ([(NSTextField *)delegateObj isDescendantOf:self.window.windowController.contentViewController.view]) {
                [self.window endEditingFor:delegateObj];
                return;
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(P_PropertyListToolbarView:didClickButton:)]) {
        [self.delegate P_PropertyListToolbarView:self didClickButton:type];
    }
}

#pragma mark - action
- (IBAction)openAction:(id)sender {
    [self callDelegate:P_PropertyListToolbarButtonOpen];
}
- (IBAction)resetAction:(id)sender {
    [self callDelegate:P_PropertyListToolbarButtonReset];
}
- (IBAction)addAction:(id)sender {
    [self callDelegate:P_PropertyListToolbarButtonAdd];
}
- (IBAction)removeAction:(id)sender {
    [self callDelegate:P_PropertyListToolbarButtonRemove];
}
- (IBAction)saveAction:(id)sender {
    [self callDelegate:P_PropertyListToolbarButtonSave];
}


@end
