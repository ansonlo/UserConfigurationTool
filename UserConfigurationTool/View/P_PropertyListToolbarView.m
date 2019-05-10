//
//  P_PropertyListToolbarView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/5/10.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListToolbarView.h"

@implementation P_PropertyListToolbarView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSView *)hitTest:(NSPoint)point
{
    NSView *view = [super hitTest:point];
    
    if ([view isDescendantOf:self]) {
        /** 获取当然window的响应者 */
        NSResponder *firstResponder = self.window.firstResponder;
        if ([firstResponder respondsToSelector:@selector(delegate)]) {
            /** 获取代理对象 */
            id delegateObj = [firstResponder performSelector:@selector(delegate)];
            if ([delegateObj isKindOfClass:[NSTextField class]]) {
                /** 对象是outlineView的成员之一 */
                if ([(NSTextField *)delegateObj isDescendantOf:self.superview]) {
                    [self.window endEditingFor:delegateObj];
                    return nil;
                }
            }
        }
    }
    
    return view;
}

@end
