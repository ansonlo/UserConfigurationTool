//
//  P_SearchView.h
//  UserConfigurationTool
//
//  Created by 丁嘉睿 on 2019/5/15.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol P_SearchViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface P_SearchView : NSView

@property (nonatomic, readonly) NSString *searchString;

@property (nonatomic, weak) id<P_SearchViewDelegate>delegate;

@end

@protocol P_SearchViewDelegate <NSObject>

@optional

- (void)searchView:(P_SearchView *)view didChangeSearchString:(NSString *)searchString;

- (BOOL)searchView:(P_SearchView *)view doCommandBySelector:(SEL)commandSelector;

@end

NS_ASSUME_NONNULL_END
