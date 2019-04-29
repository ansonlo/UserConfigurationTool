//
//  P_OutlineViewController+Edit.h
//  UserConfigurationTool
//
//  Created by 丁嘉睿 on 2019/4/28.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OutlineViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_OutlineViewController (Edit)

-(void) enableDragNDrop;

- (void)cutEditing;

- (void)deleteEditing;

- (BOOL)copyEditing;

@end

NS_ASSUME_NONNULL_END
