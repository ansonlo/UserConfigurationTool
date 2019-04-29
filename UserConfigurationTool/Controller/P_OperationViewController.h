//
//  ViewController.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "P_PropertyListOutlineView.h"

@interface P_OperationViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (weak) IBOutlet P_PropertyListOutlineView *outlineView;

@property (nonatomic, readonly) NSURL *plistUrl;

-(void)p_showAlertViewWith:(NSString *)InformativeText;

@end

