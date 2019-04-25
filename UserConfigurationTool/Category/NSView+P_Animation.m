//
//  NSView+P_Animation.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/24.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "NSView+P_Animation.h"
@import QuartzCore;

@implementation NSView (P_Animation)

- (void)p_flashError
{
    CABasicAnimation* flashAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    flashAnimation.fromValue = (__bridge id)NSColor.clearColor.CGColor;
    flashAnimation.toValue = (__bridge id)NSColor.systemRedColor.CGColor;
    flashAnimation.duration = 0.25;
    flashAnimation.autoreverses = YES;
    flashAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    flashAnimation.fillMode = kCAFillModeForwards;
    flashAnimation.removedOnCompletion = YES;
    
    [self.layer addAnimation:flashAnimation forKey:@"backgroundColor"];
}

@end
