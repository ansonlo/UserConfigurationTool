//
//  P_Data.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface P_Data : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) id value;
@property (nonatomic, readonly) NSString *valueDesc;

/** 是否有子数据 */
@property (nonatomic, readonly) BOOL hasChild;
/** 可否展开 */
@property (nonatomic, readonly, getter=isExpandable) BOOL expandable;
/** 层级 */
@property (nonatomic, readonly) int level;
/** 子数据对象 */
@property (nonatomic, readonly) NSArray <P_Data *>*childDatas;
/** 文件数据 */
@property (nonatomic, readonly) id plist;


+ (instancetype)rootWithPlistUrl:(NSURL *)plistUrl;

@end

NS_ASSUME_NONNULL_END
