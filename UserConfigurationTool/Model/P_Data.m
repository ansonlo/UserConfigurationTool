//
//  P_Data.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_Data.h"
#import <AESCrypt/AESCrypt.h>
#import "P_Config.h"

@interface P_Data ()

@property (nullable, weak) P_Data *parentData;
@property (nonatomic, strong) NSMutableArray <P_Data *>*m_childDatas;

#pragma mark - extern

/** 编辑类型 */
@property (nonatomic, assign) P_Data_EditableType editable;
/** 操作类型 */
@property (nonatomic, assign) P_Data_OperationType operation;
/** 必填 */
@property (nonatomic, assign) BOOL requested;
/** 排序 */
@property (nonatomic, assign) int sort;

@end

@implementation P_Data

@synthesize value = _value;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _key = @"";
        _type = Plist.String;
        _editable = P_Data_Editable_All;
        _operation = P_Data_Operation_All;
    }
    return self;
}

+ (instancetype)rootWithPlistUrl:(NSURL *)plistUrl
{
    NSData *data = [NSData dataWithContentsOfURL:plistUrl];
    if (data) {    
        if ([plistUrl.lastPathComponent.pathExtension isEqualToString:PlistGlobalConfig.encryptFileExtension]) {
            data = [AESCrypt encrypt]->decrypt(data);
        }
    }
    id obj = nil;
    if (data) {
        obj = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:NULL];
    }
    P_Data *p = nil;
    if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
        p = [[[self class] alloc] initWithPlistKey:@"Root" value:obj];
        p.editable ^= P_Data_Editable_Key;
        p.operation = P_Data_Operation_Insert;
        
        /** 排序key */
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *sortKey = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [p sortWithSortDescriptors:@[sort, sortKey] recursively:YES];
        
    } else {
        NSLog(@"The plistUrl is not a plist file url.");
    }
    return p;
}

- (instancetype)initWithPlistKey:(NSString *)key value:(id)value
{
    self = [self init];
    if (self) {
        /** 特别排序 */
        _sort = P_SortSpecialKey(key);
        
        _key = key;
        _value = value;
        if ([value isKindOfClass:[NSDictionary class]]) {
            _type = Plist.Dictionary;
            _value = nil;
            _m_childDatas = [self dealWithChildDatas:value];
        } else if ([value isKindOfClass:[NSArray class]]) {
            _type = Plist.Array;
            _value = nil;
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
                [childDatas addObject:p];
                p.parentData = self;
                P_Config *c = [[P_Config config] compareData:p];
                if (c) {
                    P_Data *tmp_p = c.data;
                    p.operation = tmp_p.operation;
                    p.editable = tmp_p.editable;
                    p.requested = tmp_p.requested;
                }
            }
        }
    } else if ([contents isKindOfClass:[NSArray class]]) {
        childDatas = [NSMutableArray arrayWithCapacity:1];
        NSArray *plistData = (NSArray *)contents;
        for (NSInteger i=0; i<plistData.count; i++) {
            id value = plistData[i];
            P_Data *p = [[[self class] alloc] initWithPlistKey:@"" value:value];
            if (p) {
                [childDatas addObject:p];
                p.parentData = self;
                P_Config *c = [[P_Config config] compareData:p];
                if (c) {
                    P_Data *tmp_p = c.data;
                    p.operation = tmp_p.operation;
                    p.editable = tmp_p.editable;
                    p.requested = tmp_p.requested;
                }
            }
        }
    }
    return childDatas;
}

#pragma mark - setter
- (void)setType:(P_PlistTypeName)type
{
    if (_type != type) {
        _type = type;
        if (!([type isEqualToString:Plist.Dictionary] || [type isEqualToString:Plist.Array])) {
            /** 仅一层就够了 */
            for (P_Data *p in _m_childDatas) {
                p.parentData = nil;
            }
            _m_childDatas = nil;
        }
        /** 模拟触发setter */
        _value = [self _fixedValue:_value];
    }
}

- (void)setValue:(id)value
{
    if (_value != value) {
        _value = [self _fixedValue:value];
    }
}

#pragma mark - getter
- (NSMutableArray<P_Data *> *)m_childDatas
{
    if (_m_childDatas == nil) {
        if ([self.type isEqualToString:Plist.Dictionary] || [self.type isEqualToString:Plist.Array]) {
            _m_childDatas = [NSMutableArray arrayWithCapacity:1];
        }
    }
    return _m_childDatas;
}

- (NSString *)key
{
    if ([self.parentData.type isEqualToString:Plist.Array]) {
        return [NSString stringWithFormat:@"Item %lu", (unsigned long)[self.parentData.m_childDatas indexOfObject:self]];
    }
    return _key;
}

- (id)value
{
    if (_value == nil) {
        if ([self.type isEqualToString: Plist.Dictionary]) {
            return nil;
        } else if ([self.type isEqualToString: Plist.Array]) {
            return nil;
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
        return [NSString stringWithFormat:@"(%lu items)",(unsigned long)[(NSDictionary *)_m_childDatas count]];
    } else if ([self.type isEqualToString: Plist.Array]) {
        return [NSString stringWithFormat:@"(%lu items)",(unsigned long)[(NSArray *)_m_childDatas count]];
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

- (NSString *)keyDesc
{
    if (_keyDesc == nil) {
        return self.key;
    }
    return _keyDesc;
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
        [self.m_childDatas setArray:childDatas];
        for (P_Data *subData in _m_childDatas) {
            subData.parentData = self;
        }
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
- (void)removeChildData:(P_Data *)data
{
    [_m_childDatas removeObject:data];
    data.parentData = nil;
}
- (BOOL)containsData:(P_Data *)p
{
    return [_m_childDatas containsObject:p];
}

- (BOOL)containsChildrenWithKey:(NSString*)key
{
    return [self.parentData.m_childDatas filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.key == %@", key]].count > 0;
}

- (BOOL)containsChildrenAndWithOutSelfWithKey:(NSString*)key
{
    return [self.parentData.m_childDatas filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.key == %@ && self != %@", key, self]].count > 0;
}

#pragma mark - conver to plist

- (id)plist
{
    id plist = nil;
    if ([self.type isEqualToString: Plist.Dictionary]) {
        NSMutableDictionary *tmpPlist = [NSMutableDictionary dictionary];
        for (P_Data *p in self.m_childDatas) {
            [tmpPlist setObject:p.plist forKey:p.key];
        }
        plist = tmpPlist;
    } else if ([self.type isEqualToString: Plist.Array]) {
        NSMutableArray *tmpPlist = [NSMutableArray array];
        for (P_Data *p in self.m_childDatas) {
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
    p.keyDesc = self.keyDesc;
    // exten
    p.editable = self.editable;
    p.operation = self.operation;
    p.requested = self.requested;
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
    self = [self init];
    
    if(self)
    {
        _key = [aDecoder decodeObjectForKey:@"key"];
        _type = [aDecoder decodeObjectForKey:@"type"];
        _value = [aDecoder decodeObjectForKey:@"value"];
        _keyDesc = [aDecoder decodeObjectForKey:@"keyDesc"];
        
        _m_childDatas = [aDecoder decodeObjectForKey:@"children"];
        
        _editable = [[aDecoder decodeObjectForKey:@"editable"] integerValue];
        _operation = [[aDecoder decodeObjectForKey:@"operation"] integerValue];
        _requested = [[aDecoder decodeObjectForKey:@"requested"] boolValue];
        
        [_m_childDatas enumerateObjectsUsingBlock:^(P_Data * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.parentData = self;
        }];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_type forKey:@"type"];
    [aCoder encodeObject:_value forKey:@"value"];
    [aCoder encodeObject:_keyDesc forKey:@"keyDesc"];
    
    [aCoder encodeObject:_m_childDatas forKey:@"children"];
    
    [aCoder encodeObject:@(self.editable) forKey:@"editable"];
    [aCoder encodeObject:@(self.operation) forKey:@"operation"];
    [aCoder encodeObject:@(self.requested) forKey:@"requested"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark - isEqualToP_Data

- (BOOL)isEqualToP_Data:(P_Data *)object
{
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[P_Data class]]) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    } else {
        BOOL haveEqualKey = (!self.key && !object.key) || [self.key isEqualToString:object.key];
        BOOL haveEqualType = (!self.type && !object.type) || [self.type isEqualToString:object.type];
        BOOL haveEqualValue = (self.value == object.value) || ((!self.value && !object.value) || [self.value isEqual:object.value]);
        
        NSArray *my_childDatas = self.m_childDatas;
        NSArray *obj_childDatas = object.m_childDatas;
        BOOL haveEqualChildren = (my_childDatas == obj_childDatas) || ((!my_childDatas && !obj_childDatas) || [my_childDatas isEqual:obj_childDatas]);
        
        // exten
        BOOL haveEqualEditable = self.editable == object.editable;
        BOOL haveEqualOperation = self.operation == object.operation;
        BOOL haveEqualRequested = self.requested == object.requested;
        
        return haveEqualKey && haveEqualType &&haveEqualValue && haveEqualChildren && haveEqualEditable && haveEqualOperation && haveEqualRequested;
    }
}

- (NSUInteger)hash
{
    return [self.key hash] ^ [self.type hash] ^ [self.value hash] ^ [_m_childDatas hash];
}

#pragma mark - copyP_Data
- (void)copyP_Data:(P_Data *)p
{
    self.key = p.key;
    self.type = p.type;
    self.value = p.value;
    self.keyDesc = p.keyDesc;
    // exten
    self.editable = p.editable;
    self.operation = p.operation;
    self.requested = p.requested;
    //children
    self.childDatas = p.childDatas;
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

#pragma mark - private

- (id)_fixedValue:(id)value
{
    id n_value = value;
    if ([self.type isEqualToString: Plist.Dictionary]) {
        if (![n_value isKindOfClass:[NSDictionary class]]) {
            n_value = nil;
        }
    } else if ([self.type isEqualToString: Plist.Array]) {
        if (![n_value isKindOfClass:[NSArray class]]) {
            n_value = nil;
        }
    } else if ([self.type isEqualToString: Plist.String]) {
        if ([n_value isKindOfClass:[NSNumber class]]) {
            n_value = [value description];
        } else if ([n_value isKindOfClass:[NSDate class]]) {
            n_value = [value description];
        } else if (![n_value isKindOfClass:[NSString class]]) {
            n_value = @"";
        }
    } else if ([self.type isEqualToString: Plist.Number]) {
        if ([n_value isKindOfClass:[NSString class]]) {
            // 准备对象
            NSString * searchStr = [n_value description];
            // 创建 NSRegularExpression 对象,匹配 正则表达式
            NSString * regExpStr = @"^[0-9]*";
            NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:regExpStr
                                                                               options:NSRegularExpressionDotMatchesLineSeparators
                                                                                 error:nil];
            NSRange range = [regExp rangeOfFirstMatchInString:searchStr options:NSMatchingAnchored range:NSMakeRange(0, searchStr.length)];
            NSString *result_string = [searchStr substringWithRange:range];
            static NSNumberFormatter* __numberFormatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                __numberFormatter = [NSNumberFormatter new];
            });
            n_value = [__numberFormatter numberFromString:result_string];
            if (n_value == nil) {
                n_value = @0;
            }
        } else if (![n_value isKindOfClass:[NSNumber class]]) {
            n_value = @0;
        }
    } else if ([self.type isEqualToString: Plist.Boolean]) {
        if ([n_value isKindOfClass:[NSString class]]) {
            n_value = @([value boolValue]);
        } else if (![n_value isKindOfClass:[NSNumber class]]) {
            n_value = @NO;
        }
    } else if ([self.type isEqualToString: Plist.Date]) {
        if (![n_value isKindOfClass:[NSDate class]]) {
            n_value = [NSDate date];
        }
    } else if ([self.type isEqualToString: Plist.Data]) {
        if (![n_value isKindOfClass:[NSData class]]) {
            n_value = [NSData data];
        }
        n_value = nil;
    }
    return n_value;
}



@end
