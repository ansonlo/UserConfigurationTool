//
//  P_PropertyListToolbarView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/5/10.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, P_PropertyListToolbarButton) {
    P_PropertyListToolbarButtonNone,
    P_PropertyListToolbarButtonOpen,
    P_PropertyListToolbarButtonReset,
    P_PropertyListToolbarButtonAdd,
    P_PropertyListToolbarButtonRemove,
    P_PropertyListToolbarButtonSave,
};

@class P_PropertyListToolbarView;

@protocol P_PropertyListToolbarViewDelegate <NSToolbarDelegate>

- (void)P_PropertyListToolbarView:(P_PropertyListToolbarView *)toolbar didClickButton:(P_PropertyListToolbarButton)buttonType;

@end

@interface P_PropertyListToolbarView : NSToolbar

@property (weak) IBOutlet NSWindow *window;

@property (nullable, weak) id<P_PropertyListToolbarViewDelegate> delegate;

//- (void)p_setControlSelected:(BOOL)isSelected addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled;

@end

NS_ASSUME_NONNULL_END
