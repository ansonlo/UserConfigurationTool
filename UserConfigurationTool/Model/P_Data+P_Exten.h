//
//  P_Data+P_Exten.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Data.h"
#import "P_TypeHeader.h"

NS_ASSUME_NONNULL_BEGIN


@interface P_Data (P_Exten)

/** 编辑类型 */
@property (nonatomic, assign) P_Data_EditableType editable;
/** 操作类型 */
@property (nonatomic, assign) P_Data_OperationType operation;
/** 必填 */
@property (nonatomic, assign) BOOL requested;

@end

NS_ASSUME_NONNULL_END
