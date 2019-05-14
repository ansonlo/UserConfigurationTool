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

FOUNDATION_EXTERN int P_SortSpecialKey(NSString *key);

@class P_Data;

@interface P_Config : NSObject

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) P_PlistTypeName type;
@property (nonatomic, readonly) id value;
@property (nonatomic, readonly) id keyDesc;
/** 必填 */
@property (nonatomic, readonly) BOOL requested;

@property (nonatomic, readonly) NSArray <P_Config *>*childDatas;

@property (nonatomic, readonly) P_Data *data;

/** 单例 static */
+ (instancetype)config;

/** 匹配 类型是Dictionary并且key一致的对象 */
- (P_Config *)configAtKey:(NSString *)key;

/** 匹配下级key的对象 */
- (P_Config *)compareKey:(NSString *)key;

- (P_Config *)compareData:(P_Data *)p;

@end

NS_ASSUME_NONNULL_END
