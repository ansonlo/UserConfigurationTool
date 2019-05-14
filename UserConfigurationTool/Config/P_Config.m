//
//  P_Config.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/28.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Config.h"
#import "P_Data+P_Exten.h"

int P_SortSpecialKey(NSString *key)
{
    int _sort = 0;
    /** 特别排序 */
    if ([key isEqualToString:@"host"]) {
        _sort = 999;
    } else if ([key isEqualToString:@"port"]) {
        _sort = 998;
    } else if ([key isEqualToString:@"webPort"]) {
        _sort = 997;
    } else if ([key isEqualToString:@"appInHost"]) {
        _sort = 996;
    } else if ([key isEqualToString:@"VPNFile"]) {
        _sort = 995;
    } else if ([key isEqualToString:@"VPNDefaultFile"]) {
        _sort = 994;
    } else if ([key isEqualToString:@"Server_Key"]) {
        _sort = 993;
    } else if ([key isEqualToString:@"Custom_Key"]) {
        _sort = 992;
    } else if ([key isEqualToString:@"Private_Key"]) {
        _sort = 991;
    } else if ([key isEqualToString:@"Theme"]) {
        _sort = 990;
    } else if ([key isEqualToString:@"Vendors_Key"]) {
        _sort = 989;
    }
    return _sort;
}

static P_Config *root_config;

@interface P_Config ()

@property (nonatomic, strong) NSMutableArray <P_Config *>*m_childDatas;

/** 排序 */
@property (nonatomic, assign) int sort;

@end

@implementation P_Config

+ (instancetype)config
{
    if (root_config == nil) {
        NSURL *configDescriptionListURL = [[NSBundle mainBundle] URLForResource:@"ConfigDescription" withExtension:@"plist"];
        NSData *data = [NSData dataWithContentsOfURL:configDescriptionListURL];
        NSDictionary *configPlist = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];
        NSURL *configDefaultListURL = [[NSBundle mainBundle] URLForResource:@"DefaultConfig" withExtension:@"plist"];
        data = [NSData dataWithContentsOfURL:configDefaultListURL];
        NSDictionary *defaultPlist = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];
        
        if (configPlist && defaultPlist) {
            root_config = [[[self class] alloc] initWithPlistKey:@"Root" desc:nil value:configPlist[@"Root"] defaultValue:defaultPlist];
        } else {
            NSLog(@"Configuration file could not be found.");
        }
    }
    return root_config;
}

- (instancetype)initWithPlistKey:(NSString *)key desc:(NSString *)desc value:(id)value defaultValue:(id)defaultValue
{
    self = [self init];
    if (self) {
        /** 特别排序 */
        _sort = P_SortSpecialKey(key);
        
        _key = key;
        _keyDesc = desc;
        _value = ([defaultValue isKindOfClass:[NSDictionary class]] || [defaultValue isKindOfClass:[NSArray class]]) ? nil : defaultValue;
        if ([desc containsString:PlistGlobalConfig.requestedName]) {
            _requested = YES;
        }
        
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
        
        /** 排序 */
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *sortKey = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [_m_childDatas sortUsingDescriptors:@[sort, sortKey]];
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
    
    p.editable = P_Data_Editable_Key | P_Data_Editable_Value;
    p.operation = P_Data_Operation_Insert | P_Data_Operation_Delete;
    p.requested = self.requested;
    
    return p;
}

- (P_Config *)configAtKey:(NSString *)key
{
    if (key) {
        if ([self.type isEqualToString:Plist.Dictionary] && [self.key isEqualToString:key]) {
            if (self.m_childDatas.count) {
                return self;
            }
        } else {
            P_Config *tmp = nil;
            for (P_Config *c in self.m_childDatas) {
                tmp = [c configAtKey:key];
                if (tmp) {
                    return tmp;
                }
            }
        }
    }
    return nil;
}

- (P_Config *)compareKey:(NSString *)key
{
    for (P_Config *c in self.m_childDatas) {
        if ([c.key isEqualToString:key]) {
            return c;
        }
    }
    return nil;
}

- (P_Config *)compareData:(P_Data *)p
{
    P_Config *c = [self configAtKey:p.parentData.key];
    for (P_Config *tmp_c in c.m_childDatas) {
        if ([tmp_c.key isEqualToString:p.key] && [tmp_c.type isEqualToString:p.type]) {
            return tmp_c;
        }
    }
    return nil;
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
