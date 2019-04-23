//
//  P_Data+P_Exten.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Data.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_Data (P_Exten)

/** 展开状态 */
@property (nonatomic, assign) BOOL expandState;

/** 可编辑key */
@property (nonatomic, assign) BOOL editableKey;
/** 可编辑type */
@property (nonatomic, assign) BOOL editableType;
/** 可编辑value */
@property (nonatomic, assign) BOOL editableValue;

@end

NS_ASSUME_NONNULL_END
