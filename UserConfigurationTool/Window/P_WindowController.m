//
//  P_WindowController.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/5/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_WindowController.h"
#import "P_OperationViewController.h"

@interface P_WindowController ()

@end

@implementation P_WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - NSWindowDelegate
- (BOOL)windowShouldClose:(NSWindow *)sender
{
    if (((P_OperationViewController *)self.contentViewController).isEdited) {
        [(P_OperationViewController *)self.contentViewController autosavesInPlace:^(P_AutosavesCode code) {
            switch (code) {
                case P_AutosavesCodeSave:
                case P_AutosavesCodeRevertChanges:
                {
                    /** 等待动画消失才执行 */
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        /** 执行退出 */
                        [self close];
                    });
                }
                    break;
                default:
                {
                    
                }
                    break;
            }
        }];
        return NO;
    }
    return YES;
}

@end
