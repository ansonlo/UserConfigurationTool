//
//  P_PropertyListOutlineView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@protocol P_PropertyListOutlineView_MenuOperationDelegate;

@interface P_PropertyListOutlineView : NSOutlineView

@property (nonatomic, weak) id<P_PropertyListOutlineView_MenuOperationDelegate>menuOperationDelegate;

@end


@protocol P_PropertyListOutlineView_MenuOperationDelegate <NSObject>

@optional

- (void)menuOperationForCut;

- (void)menuOperationForDelete;

- (void)menuOperationForCopy;

- (void)menuOperationForPaste;

@end

NS_ASSUME_NONNULL_END
