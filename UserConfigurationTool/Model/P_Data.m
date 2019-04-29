//
//  P_Data.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Data.h"
#import <AESCrypt/AESCrypt.h>

@interface P_Data ()

@property (nullable, weak) P_Data *parentData;
@property (nonatomic, strong) NSMutableArray <P_Data *>*m_childDatas;

#pragma mark - extern

/** 编辑类型 */
@property (nonatomic, assign) P_Data_EditableType editable;
/** 操作类型 */
@property (nonatomic, assign) P_Data_OperationType operation;

@end

@implementation P_Data

- (instancetype)init
{
    self = [super init];
    if (self) {
        _editable = P_Data_Editable_All;
        _operation = P_Data_Operation_All;
    }
    return self;
}

+ (instancetype)rootWithPlistUrl:(NSURL *)plistUrl
{
    NSData *data = [NSData dataWithContentsOfURL:plistUrl];
    if ([plistUrl.lastPathComponent.pathExtension isEqualToString:PlistGlobalConfig.encryptFileExtension]) {
        data = [AESCrypt encrypt]->decrypt(data);
    }
    id obj = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];
    P_Data *p = nil;
    if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
        p = [[[self class] alloc] initWithPlistKey:@"Root" value:obj];
        p.editable ^= P_Data_Editable_Key;
        p.operation = P_Data_Operation_Insert;
    } else {
        NSLog(@"The plistUrl is not a plist file url.");
    }
    return p;
}

- (instancetype)initWithPlistKey:(NSString *)key value:(id)value
{
    self = [self init];
    if (self) {
        _key = key;
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
            P_Data *p = [[[self class] alloc] initWithPlistKey:key value:value];
            if (p) {
                p.parentData = self;
                [childDatas addObject:p];
            }
        }
    } else if ([contents isKindOfClass:[NSArray class]]) {
        childDatas = [NSMutableArray arrayWithCapacity:1];
        NSArray *plistData = (NSArray *)contents;
        for (NSInteger i=0; i<plistData.count; i++) {
            NSString *key = [NSString stringWithFormat:@"Item %lu", (unsigned long)i];
            id value = plistData[i];
            P_Data *p = [[[self class] alloc] initWithPlistKey:key value:value];
            if (p) {
                p.parentData = self;
                [childDatas addObject:p];
            }
        }
    }
    return childDatas;
}

#pragma mark - getter
- (NSMutableArray<P_Data *> *)m_childDatas
{
    if (_m_childDatas == nil) {
        _m_childDatas = [NSMutableArray arrayWithCapacity:1];
    }
    return _m_childDatas;
}

- (id)value
{
    if (_value == nil) {
        if ([self.type isEqualToString: Plist.Dictionary]) {
            return @{};
        } else if ([self.type isEqualToString: Plist.Array]) {
            return @[];
        } else if ([self.type isEqualToString: Plist.String]) {
            return @"";
        } else if ([self.type isEqualToString: Plist.Number]) {
            return @(0);
        } else if ([self.type isEqualToString: Plist.Boolean]) {
            return @NO;
        } else if ([self.type isEqualToString: Plist.Data]) {
            return [NSData data];
        } else if ([self.type isEqualToString: Plist.Date]) {
            return [NSDate date];
        }
    }
    return _value;
}

- (NSString *)valueDesc
{
    if ([self.type isEqualToString: Plist.Dictionary]) {
        return [NSString stringWithFormat:@"(%lu items)",(unsigned long)[(NSDictionary *)self.value count]];
    } else if ([self.type isEqualToString: Plist.Array]) {
        return [NSString stringWithFormat:@"(%lu items)",(unsigned long)[(NSArray *)self.value count]];
    } else if ([self.type isEqualToString: Plist.String]) {
        return self.value;
    } else if ([self.type isEqualToString: Plist.Number]) {
        if ([self.value isKindOfClass:[NSNumber class]]) {
            return [self.value stringValue];
        } else {
            return @"0";
        }
    } else if ([self.type isEqualToString: Plist.Boolean]) {
        if ([self.value isKindOfClass:[NSNumber class]]) {
            return [self.value boolValue] ? PlistBoolean.Y : PlistBoolean.N;
        } else {
            return PlistBoolean.N;
        }
    } else if ([self.type isEqualToString: Plist.Date]) {
        return [self.value description];
    } else if ([self.type isEqualToString: Plist.Data]) {
        if ([self.value isKindOfClass:[NSData class]]) {
            return [self.value description];
        }
    }
    return @"";
}

- (BOOL)hasChild
{
    return _m_childDatas.count > 0;
}

- (BOOL)isExpandable
{
    return ([self.type isEqualToString: Plist.Dictionary] || [self.type isEqualToString: Plist.Array]);
}

- (int)level
{
    int level = 0;
    if (self.parentData) {
        level = self.parentData.level + 1;
    }
    return level;
}

- (NSArray<P_Data *> *)childDatas
{
    return [_m_childDatas copy];
}

- (void)setChildDatas:(NSArray<P_Data *> *)childDatas
{
    if (childDatas) {
        [_m_childDatas setArray:childDatas];
    } else {
        _m_childDatas = nil;
    }
}

- (void)sortWithSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors recursively:(BOOL)recursively
{
    [_m_childDatas sortUsingDescriptors:sortDescriptors];
    if (recursively) {
        for (P_Data *p in _m_childDatas) {
            [p sortWithSortDescriptors:sortDescriptors recursively:recursively];
        }
    }
}

- (void)insertChildData:(P_Data *)data atIndex:(NSUInteger)idx
{
    [self.m_childDatas insertObject:data atIndex:idx];
    data.parentData = self;
}
- (void)removeChildDataAtIndex:(NSUInteger)idx
{
    P_Data *p = [_m_childDatas objectAtIndex:idx];
    [_m_childDatas removeObjectAtIndex:idx];
    p.parentData = nil;
}

- (BOOL)containsChildrenWithKey:(NSString*)key
{
    return [self.parentData.m_childDatas filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.key == %@ && self != %@", key, self]].count > 0;
}

#pragma mark - conver to plist

- (id)plist
{
    id plist = nil;
    if ([self.type isEqualToString: Plist.Dictionary]) {
        NSMutableDictionary *tmpPlist = [NSMutableDictionary dictionary];
        for (P_Data *p in self.childDatas) {
            [tmpPlist setObject:p.plist forKey:p.key];
        }
        plist = tmpPlist;
    } else if ([self.type isEqualToString: Plist.Array]) {
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

- (NSData *)data
{
    id plist = self.plist;
    if (plist) {
        NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                                 options:0
                                                                   error:nil];
        if (data) {
            return [AESCrypt encrypt]->encrypt(data);
        }
    }
    return nil;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    P_Data *p = [[[self class] allocWithZone:zone] init];
    // basic
    p.key = self.key;
    p.type = self.type;
    p.value = self.value;
    // exten
    p.editable = self.editable;
    p.operation = self.operation;
    // child
    P_Data *c_subData = nil;
    for (P_Data *subData in _m_childDatas) {
        c_subData = [subData copy];
        [p.m_childDatas addObject:c_subData];
        c_subData.parentData = p;
    }
    
    return p;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self)
    {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.keyDesc = [aDecoder decodeObjectForKey:@"keyDesc"];
        
        self.m_childDatas = [aDecoder decodeObjectForKey:@"children"];
        
        self.editable = [[aDecoder decodeObjectForKey:@"editable"] integerValue];
        self.operation = [[aDecoder decodeObjectForKey:@"operation"] integerValue];
        
        [self.m_childDatas enumerateObjectsUsingBlock:^(P_Data * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.parentData = self;
        }];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.keyDesc forKey:@"keyDesc"];
    
    [aCoder encodeObject:self.m_childDatas forKey:@"children"];
    
    [aCoder encodeObject:@(self.editable) forKey:@"editable"];
    [aCoder encodeObject:@(self.operation) forKey:@"operation"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - description
- (NSString *)description
{
    NSMutableString* builder = [NSMutableString stringWithFormat:@"<%@ %p", self.className, self];
    
    [builder appendFormat:@" key: “%@”", self.key];
    [builder appendFormat:@" type: “%@”", self.type];
    [builder appendFormat:@" value: “%@”", self.valueDesc];
    [builder appendString:@">"];
    
    return builder;
}

@end
