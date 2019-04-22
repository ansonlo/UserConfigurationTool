//
//  ViewController.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface P_OperationViewController : NSViewController <NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (weak) IBOutlet NSOutlineView *outlineView;

@property (nonatomic, readonly) NSURL *plistUrl;

@end

