//
//  P_Config.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/28.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Config.h"
#import "P_Data+P_Exten.h"

@interface P_Config ()

@property (nonatomic, strong) NSMutableArray <P_Config *>*m_childDatas;

@end

@implementation P_Config

+ (instancetype)config
{
    NSURL *configDescriptionListURL = [[NSBundle mainBundle] URLForResource:@"ConfigDescription" withExtension:@"plist"];
    NSData *data = [NSData dataWithContentsOfURL:configDescriptionListURL];
    NSDictionary *configPlist = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];
    NSURL *configDefaultListURL = [[NSBundle mainBundle] URLForResource:@"DefaultConfig" withExtension:@"plist"];
    data = [NSData dataWithContentsOfURL:configDefaultListURL];
    NSDictionary *defaultPlist = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];

    if (configPlist && defaultPlist) {
        return [[[self class] alloc] initWithPlistKey:@"Root" desc:nil value:configPlist[@"Root"] defaultValue:defaultPlist];
    } else {
        NSLog(@"Configuration file could not be found.");
    }
    return nil;
}

- (instancetype)initWithPlistKey:(NSString *)key desc:(NSString *)desc value:(id)value defaultValue:(id)defaultValue
{
    self = [self init];
    if (self) {
        _key = key;
        _keyDesc = desc;
        _value = ([defaultValue isKindOfClass:[NSDictionary class]] || [defaultValue isKindOfClass:[NSArray class]]) ? nil : defaultValue;
        
        id n_value = defaultValue ?: value;
        
        if ([n_value isKindOfClass:[NSDictionary class]]) {
            _type = Plist.Dictionary;
            _m_childDatas = [self dealWithChildDatas:value defaultValue:defaultValue];
        } else if ([n_value isKindOfClass:[NSArray class]]) {
            _type = Plist.Array;
            _m_childDatas = [self dealWithChildDatas:value defaultValue:defaultValue];
        } else if ([n_value isKindOfClass:[NSString class]]) {
            _type = Plist.String;
        } else if ([n_value isKindOfClass:[NSNumber class]]) {
            NSString *descripe = [NSString stringWithFormat:@"%@", [n_value class]];
            if ([descripe rangeOfString:@"Boolean"].location == NSNotFound) {
                _type = Plist.Number;
            } else {
                _type = Plist.Boolean;
            }
        } else if ([n_value isKindOfClass:[NSDate class]]) {
            _type = Plist.Date;
        } else if ([n_value isKindOfClass:[NSData class]]) {
            _type = Plist.Data;
        }
    }
    return self;
}

- (NSMutableArray <P_Config *>*)dealWithChildDatas:(id)contents defaultValue:(id)defaultValue
{
    NSMutableArray *childDatas = nil;
    NSString *desc = nil;
    NSString *d_key = nil;
    id value = nil;
    id d_value = nil;
    
    if ([contents isKindOfClass:[NSDictionary class]]) {
        childDatas = [NSMutableArray arrayWithCapacity:1];
        NSDictionary *plistData = (NSDictionary *)contents;
        for (NSString *key in plistData) {
            
            d_key = key;
            if ([key isEqualToString:@"AddBook_UpMenu"]) {
                
            }
            
            value = desc = plistData[key];
            
            if ([desc isKindOfClass:[NSDictionary class]] || [desc isKindOfClass:[NSArray class]]) {
                NSRange rang = [key rangeOfString:@"("];
                value = desc;
                if (rang.length > 0) {
                    desc = [key substringWithRange:NSMakeRange(rang.location, key.length-rang.location)];
                    d_key = [key stringByReplacingOccurrencesOfString:desc withString:@""];
                    desc = [desc substringWithRange:NSMakeRange(1, [desc length]-2)];
                } else {
                    desc = @"";
                }
            }
            
            d_value = defaultValue[d_key];
            
            if (d_value == nil) {
                if ([desc isKindOfClass:[NSString class]]) {
                    if ([[desc lowercaseString] containsString:@"type=dictionary"]) {
                        d_value = @{};
                    } else if ([[desc lowercaseString] containsString:@"type=Boolean"]) {
                        d_value = @NO;
                    } else {
                        d_value = @"";
                    }
                    value = d_value;
                }
            }
            
            P_Config *p = [[[self class] alloc] initWithPlistKey:d_key desc:desc value:value defaultValue:d_value];
            if (p) {
                [childDatas addObject:p];
            }
        }
    } else if ([contents isKindOfClass:[NSArray class]]) {
        childDatas = [NSMutableArray arrayWithCapacity:1];
        NSArray *plistData = (NSArray *)contents;
        for (NSInteger i=0; i<plistData.count; i++) {
            d_key = [NSString stringWithFormat:@"Item %lu", (unsigned long)i];
            id value = plistData[i];
            P_Config *p = [[[self class] alloc] initWithPlistKey:d_key desc:desc value:value defaultValue:defaultValue[i]];
            if (p) {
                [childDatas addObject:p];
            }
        }
    }
    return childDatas;
}

- (NSArray<P_Config *> *)childDatas
{
    return [_m_childDatas copy];
}

- (P_Data *)data
{
    P_Data *p = [[P_Data alloc] init];
    p.key = self.key;
    p.type = self.type;
    p.value = self.value;
    p.keyDesc = self.keyDesc;
    
    p.editable = P_Data_Editable_Value;
    p.operation = P_Data_Operation_All;
    
    return p;
}

- (NSString *)description
{
    NSMutableString* builder = [NSMutableString stringWithFormat:@"<%@ %p", self.className, self];
    
    [builder appendFormat:@" key: “%@”", self.key];
    [builder appendFormat:@" type: “%@”", self.type];
    [builder appendFormat:@" value: “%@”", self.value];
    [builder appendFormat:@" keyDesc: “%@”", self.keyDesc];
    [builder appendString:@">"];
    
    for (P_Config *c in self.m_childDatas) {
        NSLog(@"%@", [c description]);
    }
    
    return builder;
}

@end
