//
//  P_PropertyListRowView.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class P_Data;

NS_ASSUME_NONNULL_BEGIN

@interface P_PropertyListRowView : NSTableRowView

@property (nonatomic, strong) P_Data *p;

- (void)p_updateEditButtons;

@end

NS_ASSUME_NONNULL_END
