//
//  ViewController.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "P_PropertyListOutlineView.h"
#import "P_Data.h"
#import "P_SearchView.h"

NS_ASSUME_NONNULL_BEGIN

@interface P_OperationViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, P_SearchViewDelegate, NSViewDraggingDestination>

@property (weak) IBOutlet P_PropertyListOutlineView *outlineView;

@property (weak) IBOutlet P_SearchView *searchView;

@property (nonatomic, readonly) P_Data *root;
@property (nonatomic, readonly) NSURL *plistUrl;

-(void)p_showAlertViewWith:(NSString *)InformativeText;
-(void)p_showAlertViewWith:(NSString *)InformativeText completionHandler:(void (^ __nullable)(void))handler;

@end

NS_ASSUME_NONNULL_END
