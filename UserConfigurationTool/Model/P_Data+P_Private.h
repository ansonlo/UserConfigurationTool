//
//  P_Data+P_Private.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/25.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Data.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_Data (P_Private)

@property (nonatomic, strong) NSMutableArray <P_Data *>*m_childDatas;

@end

NS_ASSUME_NONNULL_END
