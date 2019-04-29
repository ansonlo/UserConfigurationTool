//
//  P_Config.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/28.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P_TypeHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class P_Data;

@interface P_Config : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) P_PlistTypeName type;
@property (nonatomic, strong) id value;

@property (nonatomic, readonly) P_Data *data;

@end

NS_ASSUME_NONNULL_END
