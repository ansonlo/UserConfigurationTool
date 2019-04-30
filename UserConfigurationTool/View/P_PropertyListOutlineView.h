//
//  P_PropertyListOutlineView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/** 剪切板 */
extern NSPasteboardName const NSPasteboardName_P_Data;

@protocol P_PropertyListOutlineView_MenuOperationDelegate;

@interface P_PropertyListOutlineView : NSOutlineView

@property (nonatomic, weak) id<P_PropertyListOutlineView_MenuOperationDelegate>menuOperationDelegate;

@end

NS_ASSUME_NONNULL_END
