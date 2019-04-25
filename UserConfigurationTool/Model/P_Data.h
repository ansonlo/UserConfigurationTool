//
//  P_Data.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P_TypeHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_Data : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) P_PlistTypeName type;
@property (nonatomic, strong) id value;
@property (nonatomic, readonly) NSString *valueDesc;

/** 是否有子数据 */
@property (nonatomic, readonly) BOOL hasChild;
/** 可否展开 */
@property (nonatomic, readonly, getter=isExpandable) BOOL expandable;
/** 层级 */
@property (nonatomic, readonly) int level;
/** 子数据对象 */
@property (nonatomic, strong) NSArray <P_Data *>*childDatas;
/** 文件数据 */
@property (nonatomic, readonly) id plist;


+ (instancetype)rootWithPlistUrl:(NSURL *)plistUrl;
- (instancetype)initWithPlistKey:(NSString *)key value:(id)value;

@property (nullable, readonly, weak) P_Data *parentData;
// sorts the entire subtree
- (void)sortWithSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors recursively:(BOOL)recursively;

- (void)insertChildData:(P_Data *)data atIndex:(NSUInteger)idx;
- (void)removeChildDataAtIndex:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
