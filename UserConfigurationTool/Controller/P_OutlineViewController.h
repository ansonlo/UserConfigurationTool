//
//  P_OutlineViewController.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OperationViewController.h"
#import "P_Data.h"
#import "P_Data+P_Exten.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_OutlineViewController : P_OperationViewController

@property (nonatomic, readonly) P_Data *root;

- (void)updateObjectWithIndex:(NSInteger)index withObject:(P_Data *)anObject;

@end

NS_ASSUME_NONNULL_END
