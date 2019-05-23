//
//  ViewController.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "P_PropertyListOutlineView.h"
#import "P_PropertyListToolbarView.h"
#import "P_Data.h"
#import "P_TextFinder.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, P_AutosavesCode) {
    P_AutosavesCodeSave,
    P_AutosavesCodeRevertChanges,
    P_AutosavesCodeCancel,
};

@interface P_OperationViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, P_PropertyListOutlineViewDelegate, P_PropertyListToolbarViewDelegate>

@property (weak) IBOutlet P_PropertyListOutlineView *outlineView;
@property (weak) IBOutlet P_PropertyListToolbarView *toolbar;

/** 搜索框架 */
@property (nonatomic, readonly) P_TextFinder *textFinder;

@property (nonatomic, readonly) P_Data *root;
@property (nonatomic, readonly) NSURL *plistUrl;
/** 是否编辑过 */
@property (nonatomic, readonly) BOOL isEdited;

-(void)p_showAlertViewWith:(NSString *)InformativeText;
-(void)p_showAlertViewWith:(NSString *)InformativeText completionHandler:(void (^ __nullable)(void))handler;

-(void)autosavesInPlace:(void (^)(P_AutosavesCode code))completionHandler;

@end

NS_ASSUME_NONNULL_END
