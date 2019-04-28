//
//  P_TypeHeader.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#ifndef P_TypeHeader_h
#define P_TypeHeader_h

#import <Cocoa/Cocoa.h>

struct PlistGlobalConfigType {
    /** 允许解析的文件后缀 bmp,jpg,xxxx */
    NSString *allowedFileTypes;
    /** 加密文件后缀 */
    NSString *encryptFileExtension;
    /** 仅支持指定key的输入 */
    BOOL onlySupportSpecifiedKey;
};

static struct PlistGlobalConfigType PlistGlobalConfig = {@"plist,mrlPlist", @"mrlPlist", NO};

typedef NSString *P_PlistColumnIdentifierName NS_EXTENSIBLE_STRING_ENUM;

struct PlistColumnIdentifierType {
    P_PlistColumnIdentifierName Key;
    P_PlistColumnIdentifierName Type;
    P_PlistColumnIdentifierName Value;
};

typedef NSString *P_PlistTypeName NS_EXTENSIBLE_STRING_ENUM;

struct PlistType {
    P_PlistTypeName Dictionary;
    P_PlistTypeName Array;
    
    P_PlistTypeName Boolean;
    
    P_PlistTypeName String;
    P_PlistTypeName Number;
    P_PlistTypeName Date;
    P_PlistTypeName Data;
};

typedef NSString *P_PlistBooleanName NS_EXTENSIBLE_STRING_ENUM;

struct PlistBooleanType {
    P_PlistBooleanName Y;
    P_PlistBooleanName N;
};

typedef NSString *P_PlistCellName NS_EXTENSIBLE_STRING_ENUM;

struct PlistCellType {
    
    P_PlistCellName KeyCell;
    P_PlistCellName TypeCell;
    P_PlistCellName ValueCell;
    P_PlistCellName ValueBoolCell;
    P_PlistCellName ValueDateCell;
};

static struct PlistColumnIdentifierType const PlistColumnIdentifier = {@"Key", @"Type", @"Value"};
static struct PlistType const Plist = {@"Dictionary", @"Array", @"Boolean", @"String", @"Number", @"Date", @"Data"};
static struct PlistBooleanType const PlistBoolean = {@"YES", @"NO"};
static struct PlistCellType const PlistCell = {@"P_KeyCell", @"P_TypeCell", @"P_ValueCell", @"P_ValueBoolCell", @"P_ValueDateCell"};

typedef NS_ENUM(NSUInteger, P_Data_EditableType) {
    /** 可编辑key */
    P_Data_Editable_Key = 1 << 0,
    /** 可编辑type */
    P_Data_Editable_Type = 1 << 1,
    /** 可编辑value */
    P_Data_Editable_Value = 1 << 2,
    /** 可编辑所有 */
    P_Data_Editable_All = ~0UL,
};

typedef NS_ENUM(NSUInteger, P_Data_OperationType) {
    /** 可新增行 */
    P_Data_Operation_Insert = 1 << 0,
    /** 可删除行 */
    P_Data_Operation_Delete = 1 << 1,
    /** 可移动行 */
    P_Data_Operation_Move = 1 << 2,
    /** 可编辑所有 */
    P_Data_Operation_All = ~0UL,
};

#endif /* P_TypeHeader_h */
