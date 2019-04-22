//
//  P_Data.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Data.h"
#import "P_TypeHeader.h"

@interface P_Data ()

@property (nonatomic, assign) int level;
@property (nonatomic, strong) NSMutableArray <P_Data *>*m_childDatas;

@end

@implementation P_Data

+ (instancetype)rootWithPlistUrl:(NSURL *)plistUrl
{
    NSDictionary *PlistDictionary = [NSDictionary dictionaryWithContentsOfURL:plistUrl];
    NSArray *PlistArray = [NSArray arrayWithContentsOfURL:plistUrl];
    if (PlistDictionary) {
        return [[[self class] alloc] initWithPlistName:@"Root" value:PlistDictionary];
    } else if (PlistArray) {
        return [[[self class] alloc] initWithPlistName:@"Root" value:PlistArray];
    } else {
        NSLog(@"The plistUrl is not a plist file url.");
    }
    return nil;
}

- (instancetype)initWithPlistName:(NSString *)name value:(id)value
{
    self = [super init];
    if (self) {
        _name = name;
        _value = value;
        if ([value isKindOfClass:[NSDictionary class]]) {
            _type = Plist.Dictionary;
            _m_childDatas = [self dealWithChildDatas:value];
        } else if ([value isKindOfClass:[NSArray class]]) {
            _type = Plist.Array;
            _m_childDatas = [self dealWithChildDatas:value];
        } else if ([value isKindOfClass:[NSString class]]) {
            _type = Plist.String;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            NSString *descripe = [NSString stringWithFormat:@"%@", [value class]];
            if ([descripe rangeOfString:@"Boolean"].location == NSNotFound) {
                _type = Plist.Number;
            } else {
                _type = Plist.Boolean;
            }
        } else if ([value isKindOfClass:[NSDate class]]) {
            _type = Plist.Date;
        } else if ([value isKindOfClass:[NSData class]]) {
            _type = Plist.Data;
        }
    }
    return self;
}

- (NSMutableArray <P_Data *>*)dealWithChildDatas:(id)contents
{
    NSMutableArray *childDatas = nil;
    if ([contents isKindOfClass:[NSDictionary class]]) {
        childDatas = [NSMutableArray arrayWithCapacity:1];
        NSDictionary *plistData = (NSDictionary *)contents;
        for (NSString *key in plistData) {
            id value = plistData[key];
            P_Data *p = [[[self class] alloc] initWithPlistName:key value:value];
            if (p) {
                p.level = self.level+1;
                [childDatas addObject:p];
            }
        }
    } else if ([contents isKindOfClass:[NSArray class]]) {
        childDatas = [NSMutableArray arrayWithCapacity:1];
        NSArray *plistData = (NSArray *)contents;
        for (NSInteger i=0; i<plistData.count; i++) {
            NSString *key = [NSString stringWithFormat:@"Item %lu", (unsigned long)i];
            id value = plistData[i];
            P_Data *p = [[[self class] alloc] initWithPlistName:key value:value];
            if (p) {
                p.level = self.level+1;
                [childDatas addObject:p];
            }
        }
    }
    return childDatas;
}

#pragma mark - getter
- (id)value
{
    return _value == nil ? @"" : _value;
}

- (NSString *)valueDesc
{
    if (self.type == Plist.Dictionary) {
        return [NSString stringWithFormat:@"(%lu items)",(unsigned long)[(NSDictionary *)self.value count]];
    } else if (self.type == Plist.Array) {
        return [NSString stringWithFormat:@"(%lu items)",(unsigned long)[(NSArray *)self.value count]];
    } else if (self.type == Plist.String) {
        return self.value;
    } else if (self.type == Plist.Number) {
        return [self.value stringValue];
    } else if (self.type == Plist.Boolean) {
        return [self.value boolValue] ? PlistBoolean.Y : PlistBoolean.N;
    } else if (self.type == Plist.Date) {
        return [self.value description];
    } else if (self.type == Plist.Data) {
        return [[NSString alloc] initWithData:self.value encoding:NSUTF8StringEncoding];
    }
    return @"";
}

- (BOOL)hasChild
{
    return _m_childDatas.count > 0;
}

- (BOOL)isExpandable
{
    return (self.type == Plist.Dictionary || self.type == Plist.Array);
}

- (NSArray<P_Data *> *)childDatas
{
    return [_m_childDatas copy];
}

- (NSMutableArray<P_Data *> *)m_childDatas
{
    if (_m_childDatas == nil) {
        _m_childDatas = [NSMutableArray arrayWithCapacity:1];
    }
    return _m_childDatas;
}

#pragma mark - conver to plist

- (id)plist
{
    id plist = nil;
    if (self.type == Plist.Dictionary) {
        NSMutableDictionary *tmpPlist = [NSMutableDictionary dictionary];
        for (P_Data *p in self.childDatas) {
            [tmpPlist setObject:p.plist forKey:p.name];
        }
        plist = tmpPlist;
    } else if (self.type == Plist.Array) {
        NSMutableArray *tmpPlist = [NSMutableArray array];
        for (P_Data *p in self.childDatas) {
            [tmpPlist addObject:p.plist];
        }
        plist = tmpPlist;
    } else {
        plist = self.value;
    }
    return plist;
}

@end
