//
//  P_TextFinder.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/5/20.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class P_Data;

NS_ASSUME_NONNULL_BEGIN

@interface P_TextFinder : NSTextFinder <NSTextFinderClient>

@property (nonatomic, strong) P_Data *root;

- (instancetype)initWithOutLineView:(NSOutlineView *)outlineView;

@end

NS_ASSUME_NONNULL_END
