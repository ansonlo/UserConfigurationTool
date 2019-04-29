//
//  NSString+P_16Data.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/28.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "NSString+P_16Data.h"

@implementation NSString (P_16Data)

- (NSData *)p_stringToHexData
{
    NSString *fixStr = self;
    
    if ([fixStr hasPrefix:@"<"] && [fixStr hasSuffix:@">"]) {
        fixStr = [fixStr substringWithRange:NSMakeRange(1, fixStr.length-2)];
        fixStr = [fixStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    } else {
        return nil;
    }
    
    
    if (!fixStr || [fixStr length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([fixStr length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [fixStr length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [fixStr substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}
@end
